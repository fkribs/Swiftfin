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
    
    @Binding var activatedFlags: [String: Bool]
    var viewModel: PagingLibraryViewModel
    var onSelect: (String) -> Void
    
    init(viewModel: PagingLibraryViewModel, activatedFlags: Binding<[String: Bool]>, onSelect: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self._activatedFlags = activatedFlags
        self.onSelect = onSelect
        updateActivatedFlags()
    }
    
    private func updateActivatedFlags() {
        for letter in letteredScrollbarLetters {
            let isActive = viewModel.filterLetter == letter || (viewModel.filterLetterEnd == "A" && viewModel.filterLetter == "" && letter == "#")
            activatedFlags[letter] = isActive
        }
    }
    
    var body: some View {
            VStack(spacing: 0) {
                ForEach(letteredScrollbarLetters, id: \.self) { letter in
                    if let activated = activatedFlags[letter] {
                        LetteredScrollbarButton(
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
