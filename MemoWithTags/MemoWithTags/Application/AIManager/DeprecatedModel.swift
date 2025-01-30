//
//  DeprecatedModel.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//
/*

import Foundation
import onnxruntime_objc

// MARK: - TrainerError 열거형

enum TrainerError: Error {
    case modelFileNotFound
    case tokenizerFileNotFound
    case modelInferenceFailed(String)
}

// MARK: - EncodedOutputs 구조체

struct EncodedOutputs {
    let dense: [Float]
}

// MARK: - GTEOnnxModel 클래스

class GTEOnnxModel {
    private let ortEnv: ORTEnv
    private let ortSession: ORTSession
    private let tokenizer: Tokenizer
    private let hiddenSize: Int

    init(modelName: String, tokenizerPath: String) throws {
        // 모델 파일 경로 확인
        guard let modelPath = Bundle.main.path(forResource: modelName, ofType: "onnx") else {
            throw TrainerError.modelFileNotFound
        }
        
        // ORT 환경 초기화
        ortEnv = try ORTEnv(loggingLevel: .warning)
        
        // ORT 세션 초기화
        ortSession = try ORTSession(env: ortEnv, modelPath: modelPath, sessionOptions: nil)
        
        // Tokenizer 초기화
        tokenizer = Tokenizer(tokenizerFilePath: tokenizerPath)
        
        // hidden_size 설정 (Netron 등을 통해 확인한 값으로 변경)
        hiddenSize = 768 // 실제 모델의 hidden_size로 변경
    }
    
    /// 텍스트를 인코딩하고 임베딩을 반환합니다.
    /// - Parameter text: 인코딩할 텍스트
    /// - Returns: EncodedOutputs 구조체 (dense 벡터)
    func encode(text: String) throws -> EncodedOutputs {
        // 텍스트 인코딩
        let encodedInputs = tokenizer.encode(text: text, addSpecialTokens: true)
        
        // 입력 텐서 생성
        let inputIds = encodedInputs.inputIDs
        let attentionMask = encodedInputs.attentionMask
        
        // ORTValue 생성 (int64 타입 사용)
        let inputIdsData = inputIds.withUnsafeBufferPointer { buffer -> Data in
            return Data(buffer: buffer)
        }
        let attentionMaskData = attentionMask.withUnsafeBufferPointer { buffer -> Data in
            return Data(buffer: buffer)
        }
        
        let inputIdsMutableData = NSMutableData(data: inputIdsData)
        let inputIdsTensor = try ORTValue(tensorData: inputIdsMutableData, elementType: .int64, shape: [NSNumber(value: 1), NSNumber(value: inputIds.count)])
        
        let attentionMaskMutableData = NSMutableData(data: attentionMaskData)
        let attentionMaskTensor = try ORTValue(tensorData: attentionMaskMutableData, elementType: .int64, shape: [NSNumber(value: 1), NSNumber(value: attentionMask.count)])
        
        // 입력 사전 구성
        let inputs: [String: ORTValue] = [
            "input_ids": inputIdsTensor,
            "attention_mask": attentionMaskTensor
        ]
        
        // 출력 텐서 이름 지정 (고유한 출력 이름 사용)
        let outputNames: Set<String> = ["last_hidden_state"]
        
        // 추론 실행
        let outputs = try ortSession.run(withInputs: inputs, outputNames: outputNames, runOptions: nil)
        
        // 디버깅: 출력 이름들 로그 출력
        print("모델의 출력 이름들: \(outputs.keys)")
        
        // 출력 텐서 추출
        guard let lastHiddenStateValue = outputs["last_hidden_state"] else {
            throw TrainerError.modelInferenceFailed("Failed to get 'last_hidden_state' from model outputs.")
        }
        
        // 출력 텐서 형상에 따라 처리
        let outputArray: [Float] = try lastHiddenStateValue.toArray()
        print("Output array count: \(outputArray.count)")
        print("Output array first 5 values: \(outputArray.prefix(5))")
        
        // [CLS] 임베딩 추출
        // [CLS] 임베딩은 시퀀스의 마지막 토큰의 임베딩이라고 가정
        // hidden_size = 768
        guard outputArray.count >= hiddenSize else {
            throw TrainerError.modelInferenceFailed("Output array size (\(outputArray.count)) is smaller than expected hidden size (\(hiddenSize)).")
        }
        
        // 마지막 hidden_size 만큼의 값을 추출
        let clsStartIndex = outputArray.count - hiddenSize
        let clsEmbedding = Array(outputArray[clsStartIndex..<outputArray.count])
        print("CLS Embedding extracted: \(clsEmbedding.prefix(5))") // 임베딩의 일부 값 출력
        
        let normalizedDense = normalize(vector: clsEmbedding)
        
        return EncodedOutputs(dense: normalizedDense)
    }
    
    /// 두 벡터 간의 코사인 유사도를 계산합니다.
    /// - Parameters:
    ///   - vec1: 첫 번째 벡터
    ///   - vec2: 두 번째 벡터
    /// - Returns: 코사인 유사도 (Float) 또는 nil (벡터 길이가 다를 경우)
    func cosineSimilarity(vec1: [Float], vec2: [Float]) -> Float? {
        guard vec1.count == vec2.count else {
            print("Dot Product Failed: Different Length. vec1.count=\(vec1.count), vec2.count=\(vec2.count)")
            return nil
        }
        
        let dotProduct = zip(vec1, vec2).map(*).reduce(0, +)
        let norm1 = sqrt(vec1.map { $0 * $0 }.reduce(0, +))
        let norm2 = sqrt(vec2.map { $0 * $0 }.reduce(0, +))
        
        guard norm1 > 0, norm2 > 0 else {
            print("One of the vectors has zero norm: norm1=\(norm1), norm2=\(norm2)")
            return nil
        }
        
        return dotProduct / (norm1 * norm2)
    }
    
    // MARK: - 유틸리티 메서드
    
    /// 벡터를 정규화합니다.
    /// - Parameter vector: 정규화할 벡터
    /// - Returns: 정규화된 벡터
    private func normalize(vector: [Float]) -> [Float] {
        let norm = sqrt(vector.map { $0 * $0 }.reduce(0, +))
        guard norm > 0 else {
            print("Normalization failed: norm is zero.")
            return vector
        }
        return vector.map { $0 / norm }
    }
}

// MARK: - ORTValue 확장

extension ORTValue {
    /// ORTValue를 Swift 배열로 변환합니다.
    /// - Throws: 변환 중 발생한 오류
    /// - Returns: 변환된 Swift 배열
    func toArray() throws -> [Float] {
        guard let nsData = try? self.tensorData() else {
            throw TrainerError.modelInferenceFailed("Failed to extract tensor data.")
        }
        
        let data = nsData as Data  // NSMutableData를 Data로 캐스팅
        
        return data.withUnsafeBytes { buffer -> [Float] in
            // Float 타입으로 바인딩하고 배열로 변환
            let floatBuffer = buffer.bindMemory(to: Float.self)
            return Array(floatBuffer)
        }
    }
}

*/
