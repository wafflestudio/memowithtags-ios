//
//  KeyboardState.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/13/25.
//

import SwiftUI
import Combine

@MainActor
final class KeyboardManager: ObservableObject {
    
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        DispatchQueue.main.async {
            self.currentHeight = 0
        }
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
