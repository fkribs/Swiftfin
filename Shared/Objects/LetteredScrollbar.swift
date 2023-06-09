//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

// Joe Kribs: joseph@kribs.net 02/06/2023
// Sits horizontal to the LibraryView to filter results by letter
// Similar to alphaPicker in Jellyfin-Web

import Defaults
import SwiftUI

struct LetteredScrollbar: View {
    
    static let letters: [String] = [
        "#", "A", "B", "C", "D", "E", "F",
        "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z"
    ]
    
    @Binding var activatedLetters: [String: Bool]
    var viewModel: PagingLibraryViewModel
    var onSelect: (String) -> Void
    
    init(viewModel: PagingLibraryViewModel, activatedLetters: Binding<[String: Bool]>, onSelect: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self._activatedLetters = activatedLetters
        self.onSelect = onSelect
        updateActivatedLetter()
    }
    
    private func updateActivatedLetter() {
        DispatchQueue.main.async {
            for letter in LetteredScrollbar.letters {
                activatedLetters[letter] = LetteredScrollbar.validateActivatedLetter(letter: letter, filterLetter: viewModel.filterLetter, filterLetterEnd: viewModel.filterLetterEnd)
            }
        }
    }
    
    static func validateActivatedLetter(letter: String, filterLetter: String = "", filterLetterEnd: String = "") -> Bool {
        return filterLetter == letter || (filterLetterEnd == "A" && filterLetter == "" && letter == "#")
    }
    
    var body: some View {
        #if os(tvOS)
        VStack(spacing: 0) {
            ForEach(LetteredScrollbar.letters, id: \.self) { letter in
                if let activated = activatedLetters[letter] {
                    LetteredScrollbarButton(
                        letter: letter,
                        viewModel: viewModel,
                        activated: activated,
                        onSelect: { activated in
                            activatedLetters[letter] = activated
                            onSelect(letter)
                        }
                    )
                    .id(letter)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 5)
        .onAppear {
            updateActivatedLetter()
        }
        #else
        ScrollView {
            VStack(spacing: 0) {
                ForEach(LetteredScrollbar.letters, id: \.self) { letter in
                    if let activated = activatedLetters[letter] {
                        LetteredScrollbarButton(
                            letter: letter,
                            viewModel: viewModel,
                            activated: activated,
                            onSelect: { activated in
                                activatedLetters[letter] = activated
                                onSelect(letter)
                            }
                        )
                        .id(letter)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 5)
            .padding(.trailing, 5)
            .frame(width: 35)
        }
        .introspectScrollView { scrollView in
            scrollView.showsVerticalScrollIndicator = false
        }
        .onAppear {
            updateActivatedLetter()
        }
        #endif
    }
}

