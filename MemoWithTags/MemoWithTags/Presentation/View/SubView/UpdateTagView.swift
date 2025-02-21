//
//  UpdateTagView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 1/10/25.
//

import SwiftUI

struct UpdateTagView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: MainViewModel

    let tag: Tag
    @State private var updatedName: String
    @State private var selectedColor: Color.TagColor

    init(viewModel: MainViewModel, tag: Tag) {
        self.viewModel = viewModel
        self.tag = tag
        updatedName = tag.name
        selectedColor = tag.color
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("태그 이름")) {
                    TextField("새로운 이름", text: $updatedName)
                }

                Section(header: Text("태그 색상")) {
                    Picker("태그 색상을 고르세요", selection: $selectedColor) {
                        ForEach(Color.TagColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.rawValue)
                            }
                            .tag(color)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }
            .navigationBarTitle("태그 수정하기", displayMode: .inline)
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    Task {
                        await viewModel.updateTag(tagId: tag.id, name: updatedName, color: selectedColor)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(updatedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
}
