//
//  WithdrawalUseCase.swift
//  MemoWithTags
//
//  Created by 최진모 on 2/1/25.
//

protocol WithdrawalUseCase {
    func execute(email: String) async -> Result<Void, WithdrawalError>
}

final class DefaultWithdrawalUseCase: WithdrawalUseCase {
    let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(email: String) async -> Result<Void, WithdrawalError> {
        do {
            try await authRepository.withdrawal(email: email)
            return .success(())
        } catch {
            ///error 맵핑 구현
            return .failure(.from(baseError: error as! BaseError))
        }
    }
}
