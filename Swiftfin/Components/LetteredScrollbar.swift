//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct LetteredScrollbar: View {
    
    @ObservedObject
    var viewModel: LibraryViewModel

    var onSelect: ((String) -> Void)

    //TODO: Locationalization? I'm not totally sure what that looks like for non-Romanic lettering
    let letters: [String] = (0..<27).map { index in
        if index == 0 {
            return "#"
        } else {
            let scalarValue = UnicodeScalar(Int("A".unicodeScalars.first!.value) + index - 1)!
            return String(scalarValue)
        }
    }

    @State private var selectedLetter: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                ForEach(letters, id: \.self) { letter in
                    Button(action: {
                        selectLetter(letter)
                        selectedLetter = letter
                    }) {
                        Text(letter)
                            .font(.system(size: 14))
                            .padding(.vertical, 2.3)
                            .background(
                                Circle()
                                    .strokeBorder(Color.clear, lineWidth: 2)
                                    .background(letter == selectedLetter ? Color(UIColor.secondarySystemFill) : Color.clear)
                                    .clipShape(Circle())
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.trailing, 10)
            .frame(width: 30)
        }
        .onAppear {
            // Disable vertical scroll indicator appearance for the current view hierarchy
            UIScrollView.appearance().showsVerticalScrollIndicator = false
        }
        .onDisappear {
            // Enable vertical scroll indicator appearance when the view disappears
            UIScrollView.appearance().showsVerticalScrollIndicator = true
        }
    }

    private func selectLetter(_ letter: String) {
        onSelect(letter)
    }
}

