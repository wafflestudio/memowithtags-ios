//
//  NicknameSettingViewModel.swift
//  MemoWithTags
//
//  Created by 최진모 on 6/21/25.
//

import SwiftUI
import Factory

@MainActor
@Observable
final class NicknameSettingViewModel {
    @ObservationIgnored @Injected(\.userService) private var userService
    @ObservationIgnored @Injected(\.navigationState) private var navigation
    @ObservationIgnored @Injected(\.alertState) private var alert
    
    var isLoading = false
    
    func setNickname(nickname: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let result = await userService.changeNickname(nickname: nickname)
        
        switch result {
        case .success:
            navigation.push(to: .signupSuccess)
        case .failure(let error):
            alert.alert(error: error)
        }
        
        isLoading = false
    }
}

extension Container {
    @MainActor
    var nicknameSettingViewModel: Factory<NicknameSettingViewModel> {
        self { @MainActor in NicknameSettingViewModel() }.cached
    }
}
