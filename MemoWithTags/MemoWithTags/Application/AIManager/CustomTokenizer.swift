//
//  Tokenizer.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/29/25.
//

import Foundation

class CustomTokenizer {
    
    private var tokenizerJSON: [String: Any] = [:]
    private var tokenizerConfig: [String: Any] = [:]
    private var specialTokensMap: [String: Any] = [:]
    
    private var tokenToID: [String: Int] = [:]
    private var idToToken: [Int: String] = [:]
    private var vocab: [[Any]] = []
    
    private var specialTokens: [String: String] = [:]
    
    private var preTokenizer: [String: Any] = [:]
    private var postProcessor: [String: Any] = [:]
    private var decoderConfig: [String: Any] = [:]
    
    private var modelType: String = ""
    private var unkTokenID: Int = 0
    private var unkToken: String = "<unk>"
    
    private var bosToken: String = "<s>"
    private var eosToken: String = "</s>"
    private var bosTokenIDValue: Int?
    private var eosTokenIDValue: Int?
    
    private var cleanUpSpaces: Bool = true
    
    /// Updated initializer to accept URLs instead of String paths
    init(tokenizerJSONURL: URL, tokenizerConfigURL: URL, specialTokensMapURL: URL) {
        do {
            // Load and parse tokenizer.json
            let tokenizerData = try Data(contentsOf: tokenizerJSONURL)
            if let json = try JSONSerialization.jsonObject(with: tokenizerData, options: []) as? [String: Any] {
                self.tokenizerJSON = json
            }
            
            // Load and parse tokenizer_config.json
            let tokenizerConfigData = try Data(contentsOf: tokenizerConfigURL)
            if let json = try JSONSerialization.jsonObject(with: tokenizerConfigData, options: []) as? [String: Any] {
                self.tokenizerConfig = json
            }
            
            // Load and parse special_tokens_map.json
            let specialTokensData = try Data(contentsOf: specialTokensMapURL)
            if let json = try JSONSerialization.jsonObject(with: specialTokensData, options: []) as? [String: Any] {
                self.specialTokensMap = json
            }
            
            // Build Vocabulary
            if let model = tokenizerJSON["model"] as? [String: Any],
               let vocabArray = model["vocab"] as? [[Any]] {
                self.vocab = vocabArray
                for (idx, tokenPair) in vocabArray.enumerated() {
                    if let token = tokenPair[0] as? String {
                        self.tokenToID[token] = idx
                        self.idToToken[idx] = token
                    }
                }
            }
            
            // Handle Special Tokens
            for (tokenName, tokenInfo) in specialTokensMap {
                if let tokenInfoDict = tokenInfo as? [String: Any],
                   let tokenContent = tokenInfoDict["content"] as? String {
                    self.specialTokens[tokenName] = tokenContent
                    if self.tokenToID[tokenContent] == nil {
                        let newID = self.tokenToID.count
                        self.tokenToID[tokenContent] = newID
                        self.idToToken[newID] = tokenContent
                    }
                }
            }
            
            // Preprocessor, Postprocessor, Decoder
            if let preTokenizerConfig = tokenizerJSON["pre_tokenizer"] as? [String: Any] {
                self.preTokenizer = preTokenizerConfig
            }
            
            if let postProcessorConfig = tokenizerJSON["post_processor"] as? [String: Any] {
                self.postProcessor = postProcessorConfig
            }
            
            if let decoderConfig = tokenizerJSON["decoder"] as? [String: Any] {
                self.decoderConfig = decoderConfig
            }
            
            // Model Settings
            if let model = tokenizerJSON["model"] as? [String: Any] {
                if let type = model["type"] as? String {
                    self.modelType = type
                }
                if let unkID = model["unk_id"] as? Int {
                    self.unkTokenID = unkID
                }
                if let unkTokenStr = self.idToToken[self.unkTokenID] {
                    self.unkToken = unkTokenStr
                }
            }
            
            // Special Tokens IDs
            self.bosToken = self.specialTokens["bos_token"] ?? "<s>"
            self.eosToken = self.specialTokens["eos_token"] ?? "</s>"
            self.bosTokenIDValue = self.tokenToID[self.bosToken]
            self.eosTokenIDValue = self.tokenToID[self.eosToken]
            
            // Clean Up Spaces
            if let cleanUp = tokenizerConfig["clean_up_tokenization_spaces"] as? Bool {
                self.cleanUpSpaces = cleanUp
            }
            
        } catch {
            print("Error initializing CustomTokenizer: \(error)")
        }
    }
    
    
    private func preprocess(text: String) -> String {
        let tokens = text.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").map { "▁\($0)" }
        return tokens.joined()
    }
    
    func tokenize(text: String) -> [String] {
        let preprocessedText = preprocess(text: text)
        var tokens: [String] = []
        var i = preprocessedText.startIndex
        let end = preprocessedText.endIndex
        
        while i < end {
            var match: String? = nil
            var j = end
            while j > i {
                let substring = String(preprocessedText[i..<j])
                if let _ = tokenToID[substring] {
                    match = substring
                    break
                }
                j = preprocessedText.index(before: j)
            }
            if let matchedToken = match {
                tokens.append(matchedToken)
                i = preprocessedText.index(i, offsetBy: matchedToken.count)
            } else {
                // Use <unk> token
                tokens.append(self.unkToken)
                i = preprocessedText.index(after: i)
            }
        }
        
        return tokens
    }
    
    func encode(text: String) -> [Int] {
        var tokens: [String] = []
        
        // Add BOS token
        tokens.append(self.bosToken)
        
        // Tokenize the text
        let tokenized = tokenize(text: text)
        tokens.append(contentsOf: tokenized)
        
        // Add EOS token
        tokens.append(self.eosToken)
        
        print(tokens)
        
        // Map tokens to IDs
        let ids = tokens.map { tokenToID[$0] ?? self.unkTokenID }
        
        print(ids)
        return ids
    }
    
    /// 배치 텍스트를 인코딩하여 input_ids 배열을 반환합니다.
    func encodeBatch(texts: [String]) -> [[Int]] {
        return texts.map { encode(text: $0) }
    }
    
    /// 인코딩된 input_ids를 기반으로 attention_mask를 생성합니다.
    func createAttentionMasks(encodedIDs: [[Int]]) -> [[Int]] {
        return encodedIDs.map { ids in
            ids.map { _ in 1 }
        }
    }
}


func tryTokenizer() {
    
    // Retrieve URLs from the main bundle
    guard let tokenizerJsonURL = Bundle.main.url(forResource: "tokenizer", withExtension: "json"),
          let tokenizerConfigURL = Bundle.main.url(forResource: "tokenizer_config", withExtension: "json"),
          let specialTokensMapURL = Bundle.main.url(forResource: "special_tokens_map", withExtension: "json") else {
        print("One or more tokenizer JSON files not found in the bundle.")
        return
    }

    // Create an instance of CustomTokenizer using URLs
    let customTokenizer = CustomTokenizer(tokenizerJSONURL: tokenizerJsonURL,
                                          tokenizerConfigURL: tokenizerConfigURL,
                                          specialTokensMapURL: specialTokensMapURL)

    // Example sentence
    let sentence = "잽, 스트레이트"

    // Encode the sentence
    let encodedIDs = customTokenizer.encode(text: sentence)
    print("Encoded IDs: \(encodedIDs)")
}
