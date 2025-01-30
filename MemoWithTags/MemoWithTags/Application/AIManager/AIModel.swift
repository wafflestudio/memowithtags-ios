//
//  Model.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//

import Foundation
import onnxruntime_objc
import Accelerate

enum AIModelError: Error {
    case modelFileNotFound
    case modelInferenceFailed(String)
    case tokenizingFailed
    case encodingFailed
    case similarityCalculationFailed
    case initializationFailed(String)
}

class AIModel {
    
    /// Singleton 인스턴스
    static let shared: AIModel = {
        do {
            // 번들에서 필요한 파일들의 URL을 가져옵니다.
            guard let tokenizerJsonURL = Bundle.main.url(forResource: "tokenizer", withExtension: "json"),
                  let tokenizerConfigURL = Bundle.main.url(forResource: "tokenizer_config", withExtension: "json"),
                  let specialTokensMapURL = Bundle.main.url(forResource: "special_tokens_map", withExtension: "json"),
                  let modelURL = Bundle.main.url(forResource: "Model", withExtension: "onnx") else {
                fatalError("필요한 파일들을 번들에서 찾을 수 없습니다.")
            }
            
            // CustomTokenizer 인스턴스 생성
            let customTokenizer = CustomTokenizer(tokenizerJSONURL: tokenizerJsonURL,
                                                  tokenizerConfigURL: tokenizerConfigURL,
                                                  specialTokensMapURL: specialTokensMapURL)
            
            // AIModel 인스턴스 생성
            return try AIModel(modelURL: modelURL, tokenizer: customTokenizer)
            
        } catch {
            fatalError("AIModel 초기화에 실패했습니다: \(error)")
        }
    }()
    
    private let session: ORTSession
    private let tokenizer: CustomTokenizer
    private let hiddenSize: Int = 768
    
    private init(modelURL: URL, tokenizer: CustomTokenizer) throws {
        do {
            let ortEnv = try ORTEnv(loggingLevel: ORTLoggingLevel.warning)
            self.session = try ORTSession(env: ortEnv, modelPath: modelURL.path, sessionOptions: nil)
        } catch {
            throw AIModelError.modelInferenceFailed("모델 로드에 실패했습니다: \(error)")
        }
        self.tokenizer = tokenizer
    }
    
    /// 텍스트 리스트를 인코딩하여 임베딩 벡터를 반환합니다.
    func encode(texts: [String]) throws -> [[Float]] {
        // 텍스트를 인코딩하여 input_ids와 attention_mask를 생성
        let inputIDs = tokenizer.encodeBatch(texts: texts)
        let attentionMasks = tokenizer.createAttentionMasks(encodedIDs: inputIDs)
        
        //print("inputIDs: " ,inputIDs)
        //print("attentionMasks: ", attentionMasks)
        
        // Tensor 변환
        guard let inputIDsTensor = try? createTensor(from: inputIDs),
              let attentionMaskTensor = try? createTensor(from: attentionMasks) else {
            throw AIModelError.encodingFailed
        }
        
        let inputs: [String: ORTValue] = [
            "input_ids": inputIDsTensor,
            "attention_mask": attentionMaskTensor
        ]
        
        // 추론 실행
        let outputs: [String: ORTValue]
        do {
            outputs = try session.run(withInputs: inputs, outputNames: ["last_hidden_state"], runOptions: nil)
        } catch {
            throw AIModelError.modelInferenceFailed("추론 실행에 실패했습니다: \(error)")
        }
        
        //print("outputs: ", outputs)
        
        // 출력 처리
        guard let outputValue = outputs["last_hidden_state"],
              let outputData = try? outputValue.tensorData() as Data else {
            throw AIModelError.modelInferenceFailed("모델 출력 데이터를 가져오는 데 실패했습니다.")
        }
        
        //print("outputData: ", outputData)
        
        // Float 배열로 변환
        let predictions = outputData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Float] in
            let bufferPointer = pointer.bindMemory(to: Float.self)
            return Array(bufferPointer)
        }
        
        //print("predictions: ", predictions)
        
        // 배치 크기, 시퀀스 길이, hidden_size로 재구성
        let batchSize = texts.count
        let sequenceLength = inputIDs.first?.count ?? 0
        let totalSize = batchSize * sequenceLength * hiddenSize
        guard predictions.count == totalSize else {
            throw AIModelError.modelInferenceFailed("예상된 출력 크기와 실제 출력 크기가 다릅니다.")
        }
        
        //print("batchSize: ", batchSize)
        //print("sequenceLength: ", sequenceLength)
        //print("hiddenSize: ", hiddenSize)
        
        // [batch_size, sequence_length, hidden_size] 형태로 변환
        var reshapedPredictions: [[[Float]]] = []
        for b in 0..<batchSize {
            var batchItem: [[Float]] = []
            for s in 0..<sequenceLength {
                let start = b * sequenceLength * hiddenSize + s * hiddenSize
                let end = start + hiddenSize
                let hidden = Array(predictions[start..<end])
                batchItem.append(hidden)
            }
            reshapedPredictions.append(batchItem)
        }
        
        //print("reshapedPredictions: ", reshapedPredictions)
        
        // CLS 토큰(첫 번째 토큰)의 임베딩을 추출하고 L2 정규화
        var clsEmbeddings: [[Float]] = []
        for batchItem in reshapedPredictions {
            if let cls = batchItem.first {
                let norm = l2Norm(vector: cls)
                let normalized = cls.map { $0 / norm }
                clsEmbeddings.append(normalized)
            } else {
                throw AIModelError.modelInferenceFailed("배치 아이템에 CLS 토큰이 없습니다.")
            }
        }
        
        //print("clsEmbeddings: ", clsEmbeddings)
        
        return clsEmbeddings
    }
    
    /// 두 벡터 간의 코사인 유사도를 계산합니다.
    func cosineSimilarity(vectorA: [Float], vectorB: [Float]) throws -> Float {
        guard vectorA.count == vectorB.count else {
            throw AIModelError.similarityCalculationFailed
        }
        
        var dotProduct: Float = 0.0
        var normA: Float = 0.0
        var normB: Float = 0.0
        
        vDSP_dotpr(vectorA, 1, vectorB, 1, &dotProduct, vDSP_Length(vectorA.count))
        vDSP_svesq(vectorA, 1, &normA, vDSP_Length(vectorA.count))
        vDSP_svesq(vectorB, 1, &normB, vDSP_Length(vectorB.count))
        
        if normA == 0 || normB == 0 {
            return 0.0
        }
        
        return dotProduct / (sqrt(normA) * sqrt(normB))
    }
    
    /// 태그 추천을 수행하고 결과를 출력합니다.
    func tagRecommendation(content: String, tags: [String]) throws {
        // 컨텐츠와 태그를 인코딩
        let contentEmbedding = try encode(texts: [content]).first!
        let tagsEmbeddings = try encode(texts: tags)
        
        // 각 태그와의 유사도 계산
        var similarities: [(String, Float)] = []
        for (tag, tagEmbedding) in zip(tags, tagsEmbeddings) {
            let similarity = try cosineSimilarity(vectorA: contentEmbedding, vectorB: tagEmbedding)
            similarities.append((tag, similarity))
        }
        
        // 유사도 기준으로 정렬
        let sortedTags = similarities.sorted { $0.1 > $1.1 }
        
        // 결과 출력
        print("=== ONNX Model with CustomTokenizer ===")
        print("컨텐츠에 대해 태그를 유사도 순으로 정렬한 결과:")
        for (tag, score) in sortedTags {
            print("\(tag): \(String(format: "%.4f", score))")
        }
        print("\n")
    }
    
    // MARK: - Helper Methods
    
    /// 2차원 Int 배열을 ORTTensor로 변환합니다.
    private func createTensor(from array: [[Int]]) throws -> ORTValue {
        // Flatten the 2D array
        let flattened = array.flatMap { $0 }
        var int64Array = flattened.map { Int64($0) }
        let data = Data(bytes: &int64Array, count: int64Array.count * MemoryLayout<Int64>.size)
        
        // Shape: [batch_size, sequence_length]
        let shape: [NSNumber] = [NSNumber(value: array.count), NSNumber(value: array.first?.count ?? 0)]
        
        return try ORTValue(tensorData: NSMutableData(data: data),
                            elementType: ORTTensorElementDataType.int64,
                            shape: shape)
    }
    
    /// L2 정규화를 위한 함수
    private func l2Norm(vector: [Float]) -> Float {
        var sum: Float = 0.0
        vDSP_svesq(vector, 1, &sum, vDSP_Length(vector.count))
        return sqrt(sum)
    }
}


func tryAIModel() {
    // 예제 문장
    //let content = "할 일: 바지 뒤에 들어가는 부분 컨트롤하기 -> 뭘 덧대? 아니야 손바느질을 더 하자"
    //let content = "what is the capital of China?"
    // let content = "8월 21일 수요일 2일차: 아침 빵집 빵 먹자 에펠탑 앞에서 눕기 오르세"
    //let content = "악은 존재하지 않는다 후기 극단적으로 정적인 연출. 한 숏이 매우 길다. 그렇다고 카메라의 움직임이 크지도 않다. 그냥 삼각대 위에 아이폰을 올려놓고 찍어서 나올 수 있는 정도다. 카메라는 멀리서 일어나는 일을 관조할 뿐이다. 지루하다."
    //let content = "Rust 튜토리얼 공부하기, Scala로 PS 연습하기"
    let content = "잽, 스트레이트"
    
    
    // 예제 태그 리스트
    let tags = ["겨울", "계절", "학기", "일정", "복싱", "exercise", "fashion", "show", "패션쇼", "준비", "인공지능", "베이징", "북경", "서울", "도쿄", "일본", "Beijing", "Peking", "Qinghua", "유럽", "여행", "여름", "악은 존재하지 않는다", "후기", "영화", "movie", "방학", "계획"]
    
    do {
        // 태그 추천 수행 시간 측정 시작
        let startTime = DispatchTime.now()
        
        // 싱글톤 인스턴스를 사용하여 태그 추천 수행
        try AIModel.shared.tagRecommendation(content: content, tags: tags)
        
        // 태그 추천 수행 시간 측정 종료
        let endTime = DispatchTime.now()
        
        // 걸린 시간 계산 (밀리초 단위)
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000 // 밀리초 단위로 변환
        
        print("태그 추천 수행 시간: \(timeInterval) ms")
        
    } catch {
        print("AIModel 사용 중 오류가 발생했습니다: \(error)")
    }
}
