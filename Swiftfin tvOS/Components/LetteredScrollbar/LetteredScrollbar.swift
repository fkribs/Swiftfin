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
        "#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    ]
    
    @Binding var activatedFlags: [String: Bool]
    var viewModel: LibraryViewModel
    var onSelect: (String) -> Void
    
    init(viewModel: LibraryViewModel, activatedFlags: Binding<[String: Bool]>, onSelect: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self._activatedFlags = activatedFlags
        self.onSelect = onSelect
        updateActivatedFlags()
    }
    
    private func updateActivatedFlags() {
        for letter in Self.letters {
            let isActive = viewModel.filterLetter == letter || (viewModel.filterLetterEnd == "A" && viewModel.filterLetter == "" && letter == "#")
            activatedFlags[letter] = isActive
        }
    }
    
    var body: some View {
            VStack(spacing: 0) {
                ForEach(Self.letters, id: \.self) { letter in
                    if let activated = activatedFlags[letter] {
                        LetteredScrollbarLetter(
                            letter: letter,
                            viewModel: viewModel,
                            activated: activated,
                            onSelect: { activated in
                                activatedFlags[letter] = activated
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
                updateActivatedFlags()
        }
    }
}
