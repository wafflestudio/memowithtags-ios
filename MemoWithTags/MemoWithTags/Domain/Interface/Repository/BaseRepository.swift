//
//  BaseRepository.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/3/25.
//

import Foundation
import Alamofire

protocol BaseRepository {
    ///base error handiling을 위한 함수, Dto로 디코딩할 필요가 없는 경우
    func handleError<T>(response: DataResponse<T, AFError>) throws
    ///base error handiling을 위한 함수, Dto로 디코딩하는 경우
    func handleErrorDecodable<T>(response: DataResponse<T, AFError>) throws -> T
}

extension BaseRepository {
    func handleError<T>(response: DataResponse<T, AFError>) throws {
        switch response.result {
        case .success:
            print("🎉 success: \(response.response?.statusCode ?? -1)")
            return
            
        case .failure(let error):
            //서버로부터 받은 데이터가 있는 경우
            if let data = response.data {
                do {
                    throw try JSONDecoder().decode(BaseError.self, from: data)
                } catch let baseError as BaseError {
                    throw baseError // 이미 BaseError라면 다시 throw
                } catch {
                    if let status = response.response?.statusCode {
                        throw BaseError(status: status, code: "CANT_DECODE_ERROR", message: "에러 디코딩에 실패하였습니다.")
                    }
                    throw BaseError(status: -1, code: "CANT_DECODE_ERROR", message: "에러 디코딩에 실패하였습니다.")
                }
            }
            
            //없는 경우
            if let afError = error.asAFError {
                switch afError {
                case .sessionTaskFailed:
                    throw BaseError(status: -1, code: "CONNECT_FAILED", message: "서버에 연결할 수 없습니다.")
                default:
                    break
                }
            }
            
            
            if let status = response.response?.statusCode {
                throw BaseError(status: status, code: "UNKNOWN_ERROR", message: "알 수 없는 에러가 발생하였습니다.")
            }
            
            throw BaseError(status: -1, code: "UNKNOWN_ERROR", message: "알 수 없는 에러가 발생하였습니다.")
        }
    }
    
    func handleErrorDecodable<T>(response: DataResponse<T, AFError>) throws -> T {
        switch response.result {
        case .success:
            if let dto = response.value {
                print("🎉 success: \(response.response?.statusCode ?? -1)")
                return dto
            } else {
                if let status = response.response?.statusCode {
                    throw BaseError(status: status, code: "CANT_DECODE", message: "디코딩에 실패하였습니다.")
                }
                throw BaseError(status: 500, code: "CANT_DECODE", message: "디코딩에 실패하였습니다.")
            }
    
        case .failure(let error):
            //서버로부터 받은 데이터가 있는 경우
            if let data = response.data {
                do {
                    throw try JSONDecoder().decode(BaseError.self, from: data)
                } catch let baseError as BaseError {
                    throw baseError
                } catch {
                    if let status = response.response?.statusCode {
                        print(error)
                        throw BaseError(status: status, code: "CANT_DECODE_ERROR", message: "에러 디코딩에 실패하였습니다.")
                    }
                    throw BaseError(status: -1, code: "CANT_DECODE_ERROR", message: "에러 디코딩에 실패하였습니다.")
                }
            }
            
            //없는 경우
            if let afError = error.asAFError {
                switch afError {
                case .sessionTaskFailed:
                    throw BaseError(status: -1, code: "CONNECT_FAILED", message: "서버에 연결할 수 없습니다.")
                default:
                    break
                }
            }
            
            if let status = response.response?.statusCode {
                throw BaseError(status: status, code: "UNKNOWN_ERROR", message: "알 수 없는 에러가 발생하였습니다.")
            }
            
            throw BaseError(status: -1, code: "UNKNOWN_ERROR", message: "알 수 없는 에러가 발생하였습니다.")
        }
    }
}
