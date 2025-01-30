//
//  test.swift
//  MemoWithTags
//
//  Created by 최진모 on 1/24/25.
//
import SwiftUI
import RichTextKit
import Flow

struct MemoEditorView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @State var text = NSAttributedString(string: "")
    @StateObject var context = RichTextContext()
    
    @StateObject private var keyboardManager = KeyboardManager()

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                RichTextEditor(text: $text, context: context)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .overlay(Group { // placeholder
                        if !context.isEditingText && text.string.isEmpty {
                            Text("메모를 작성해보세요.")
                                .foregroundStyle(Color.dividerGray)
                                .offset(x: 5, y: 8)
                        }
                    }, alignment: .topLeading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.memoBackgroundWhite)
            
            Spacer()
            
            HStack {
                ForEach(viewModel.editorTags, id: \.id) { tag in
                    TagView(viewModel: viewModel, tag: tag) {
                        
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            Divider()
            
            // 텍스트 편집기
            HStack(spacing: 10) {
                EditIcon(icon: "textformat", selected: false) {
                    
                }
                    
                EditIcon(icon: "bold", selected: context.hasStyle(.bold)) {
                    context.toggleStyle(.bold)
                }
                
                EditIcon(icon: "italic", selected: context.hasStyle(.italic)) {
                    context.toggleStyle(.italic)
                }
                
                EditIcon(icon: "underline", selected: context.hasStyle(.underlined)) {
                    context.toggleStyle(.underlined)
                }
                
                EditIcon(icon: "strikethrough", selected: context.hasStyle(.strikethrough)) {
                    context.toggleStyle(.strikethrough)
                }
                
                EditIcon(icon: "increase.indent", selected: true) {
                    context.handle(.stepIndent(points: 20))
                }
                
                EditIcon(icon: "decrease.indent", selected: true) {
                    context.handle(.stepIndent(points: -20))
                }
                
                EditIcon(icon: "text.alignleft", selected: context.textAlignment == .left) {
                    context.textAlignment = .left
                }
                
                EditIcon(icon: "text.aligncenter", selected: context.textAlignment == .center) {
                    context.textAlignment = .center
                }
                
                EditIcon(icon: "text.alignright", selected: context.textAlignment == .right) {
                    context.textAlignment = .right
                }
                
                EditIcon(icon: "text.justify", selected: context.textAlignment == .justified) {
                    context.textAlignment = .justified
                }

            }
            .padding(.horizontal, 24)
            .padding(.vertical, 15)
            .background(Color.memoBackgroundWhite)
            
            if keyboardManager.currentHeight > 0 {
                EditingTagListView(viewModel: viewModel)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18))
                    .onTapGesture {
                        Task {
//                            await viewModel.submit()
                            viewModel.appState.navigation.pop()
                        }
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder private func EditIcon(icon: String, selected: Bool, click: @escaping () -> Void) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(selected ? .black : .tabBarNotSelectecdIconGray)
            .onTapGesture {
                click()
            }
    }
}

