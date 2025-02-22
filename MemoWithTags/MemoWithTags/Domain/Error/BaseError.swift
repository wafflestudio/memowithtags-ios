//
//  BaseError.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/12/25.
//

import Foundation

enum BaseError: Int, Error {
    case BAD_REQUEST = 400        // 잘못된 요청
    case UNAUTHORIZED = 401       // 인증 실패 (Unauthorized)
    case FORBIDDEN = 403          // 접근 금지 (Forbidden)
    case NOT_FOUND = 404          // 요청한 리소스가 없음 (Not Found)
    case METHOD_NOT_ALLOWED = 405 // 허용되지 않은 HTTP 메서드 (Method Not Allowed)
    case NOT_ACCEPTABLE = 406     // 요청된 자원이 허용되지 않음 (Not Acceptable)
    case PROXY_AUTHENTICATION_REQUIRED = 407 // 프록시 인증 필요 (Proxy Authentication Required)
    case REQUEST_TIMEOUT = 408    // 요청 시간 초과 (Request Timeout)
    case CONFLICT = 409           // 요청 충돌 (Conflict)
    case GONE = 410               // 리소스가 더 이상 존재하지 않음 (Gone)
    case LENGTH_REQUIRED = 411   // 길이 필요 (Length Required)
    case PRECONDITION_FAILED = 412 // 전제 조건 실패 (Precondition Failed)
    case PAYLOAD_TOO_LARGE = 413 // 요청 페이로드가 너무 큼 (Payload Too Large)
    case URI_TOO_LONG = 414      // URI가 너무 길음 (URI Too Long)
    case UNSUPPORTED_MEDIA_TYPE = 415 // 지원되지 않는 미디어 타입 (Unsupported Media Type)
    case RANGE_NOT_SATISFIABLE = 416 // 범위가 만족되지 않음 (Range Not Satisfiable)
    case EXPECTATION_FAILED = 417 // 예상 실패 (Expectation Failed)
    
    case INTERNAL_SERVER_ERROR = 500 // 서버 내부 오류 (Internal Server Error)
    case NOT_IMPLEMENTED = 501       // 기능 미구현 (Not Implemented)
    case BAD_GATEWAY = 502           // 잘못된 게이트웨이 (Bad Gateway)
    case SERVICE_UNAVAILABLE = 503   // 서비스 불가 (Service Unavailable)
    case GATEWAY_TIMEOUT = 504       // 게이트웨이 타임아웃 (Gateway Timeout)
    case VERSION_NOT_SUPPORTED = 505 // HTTP 버전 지원하지 않음 (HTTP Version Not Supported)
    
    case UNKNOWN = 999  //알 수 없는 에러
    case CANT_DECODE = -1 //서버에서 받은 정보를 DTO로 변환할 수 없음
}
