//
//  SettingViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import Foundation
import SwiftUI
import Factory

@MainActor
@Observable
final class SettingViewModel {
    @ObservationIgnored @Injected(\.userService) private var userService
    @ObservationIgnored @Injected(\.authService) private var authService
    
    @ObservationIgnored @Injected(\.appState) private var appState
    @ObservationIgnored @Injected(\.navigationState) private var navigation
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    var isLoading: Bool = false
    
    //MARK: - 로그아웃
    func logout() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await authService.logout()
        
        switch result {
        case .success:
            appState.initialize()
            
            navigation.reset()
            navigation.push(to: .root)
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 회원탈퇴
    func withdrawal(email: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await userService.withdrawal(email: email)
        
        switch result {
        case .success:
            appState.initialize()
            
            navigation.reset()
            navigation.push(to: .root)
            
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    //MARK: - 닉네임 재설정
    func setNickname(nickname: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await userService.changeNickname(nickname: nickname)
        
        switch result {
        case .success:
            navigation.pop()
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
    
    var isValidLength: Bool = false
    var isValidPasswordFormat: Bool = false
    
    //MARK: - 비밀번호 변경
    ///정규식으로 비밀번호 형식 검사
    func checkPasswordValidity(password: String) {
        let containsUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let containsLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let containsNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let containsSpecialCharacter = password.range(of: "[!@#$%^&*?_+=-]", options: .regularExpression) != nil
        
        isValidLength = password.count >= 8 && password.count <= 16
        isValidPasswordFormat = containsUppercase && containsLowercase && containsNumber && containsSpecialCharacter
    }
    
    func changePassword(currentPassword: String, newPassword: String, newPasswordRepeat: String) async {
        guard !isLoading else { return }
        
        checkPasswordValidity(password: newPassword)
        
        guard isValidLength && isValidPasswordFormat else {
            alert.alert(error: ChangePasswordError.invalidPassword)
            return
        }
        
        guard newPassword == newPasswordRepeat else {
            alert.alert(error: ChangePasswordError.passwordNotMatch)
            return
        }
        
        isLoading = true
        
        let result = await userService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
        
        switch result {
        case .success:
            navigation.pop()
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
}

extension Container {
    @MainActor
    var settingViewModel: Factory<SettingViewModel> {
        self { @MainActor in SettingViewModel() }.cached
    }
}
