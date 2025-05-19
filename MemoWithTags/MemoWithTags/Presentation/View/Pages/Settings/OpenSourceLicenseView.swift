//
//  OpenSourceLicenseView.swift
//  MemoWithTags
//
//  Created by Swimming Ryu on 5/19/25.
//

import SwiftUI

struct OpenSourceLicenseView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Navigation Bar
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19))
                        .foregroundStyle(Color.soft)
                        .padding(12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Navigation pop action 필요시 여기에 추가
                        }
                    Text("오픈소스 라이센스")
                        .font(.pretendard(.semibold, size: 18))
                        .foregroundStyle(Color.basicText)
                    Spacer()
                }
                .padding(.vertical, 8)
                ScrollView {
                    Text(openSourceText)
                        .font(.pretendard(.regular, size: 13))
                        .foregroundStyle(Color.basicText)
                        .padding(16)
                }
                .background(Color.memoBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 12)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var openSourceText: String {
        """
Copyright (c) 2014-2022 Alamofire Software Foundation (http://alamofire.org/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""
    }
}
