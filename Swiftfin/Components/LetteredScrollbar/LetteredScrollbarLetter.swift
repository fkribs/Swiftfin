//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

// Joe Kribs: joseph@kribs.net 02/06/2023
// Used in the iOS & iPadOS portions of Swiftfin.
// Formats the Letters in the LetteredScrollbar

import Defaults
import SwiftUI

extension LetteredScrollbar {
    
    struct LetteredScrollbarLetter: View {
        
        @Default(.accentColor)
        private var accentColor
        
        private let letter: String
        private var viewModel: LibraryViewModel
        private var onSelect: () -> Void
        
        @State private var activated: Bool
        
        init(letter: String, viewModel: LibraryViewModel, activated: Bool, onSelect: @escaping () -> Void) {
            self.letter = letter
            self.viewModel = viewModel
            self.activated = activated
            self.onSelect = onSelect
        }
        
        var body: some View {
            Button {
                onSelect()
                viewModel.filterOnLetter(letter)
                activated.toggle()
            } label: {
                Text(letter)
                    .font(.footnote.weight(.semibold))
                    .frame(width: 15, height: 15)
                    .padding(5)
                    .foregroundColor(activated ? Color(UIColor.white) : accentColor)
                    .opacity(1.0)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 20, height: 20)
                            .foregroundColor(accentColor)
                            .opacity(activated ? 0.5 : 0.0)
                    }
            }
        }
    }
}

extension LetteredScrollbar.LetteredScrollbarLetter {
    init(letter: String, viewModel: LibraryViewModel, activated: Bool) {
        self.init(
            letter: letter,
            viewModel: viewModel,
            activated: activated,
            onSelect: {}
        )
    }

    func onSelect(_ action: @escaping () -> Void) -> Self {
        return self
    }
}
