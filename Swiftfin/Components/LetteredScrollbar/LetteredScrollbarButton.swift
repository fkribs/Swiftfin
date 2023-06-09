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

struct LetteredScrollbarButton: View {

    @Default(.accentColor) private var accentColor
    @Environment(\.colorScheme) var colorScheme
    private let letter: String
    private let viewModel: PagingLibraryViewModel
    private let onSelect: (Bool) -> Void
    
    @Binding private var activated: Bool
    
    init(letter: String, viewModel: PagingLibraryViewModel, activated: Bool, onSelect: @escaping (Bool) -> Void) {
        self.letter = letter
        self.viewModel = viewModel
        self._activated = .constant(activated)
        self.onSelect = onSelect
    }
    
    var body: some View {
        Button(action: {
            activated.toggle()
            viewModel.filterOnLetter(letter)
        }) {
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
                        .frame(width: 30, height: 30)
                        .foregroundColor(activated ? accentColor.opacity(0.5) : Color(UIColor.clear).opacity(0.0))
                }
        }
    }
}

