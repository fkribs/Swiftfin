//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

// Joe Kribs: joseph@kribs.net 02/06/2023
// Used in the tvOS portions of Swiftfin.
// Formats the Letters in the LetteredScrollbar

import Defaults
import SwiftUI

struct LetteredScrollbarButton: View {

    @Default(.accentColor) private var accentColor
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
                .shadow(color: Color.black.opacity(activated ? 0.0 : 1.0), radius: 1, x: 1, y: 1)
                .foregroundColor(activated ? Color.white : accentColor)
                .padding(10)
                .padding(.horizontal, 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: 1, height: 35)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 32.5, height: 32.5)
                                .foregroundColor(activated ? accentColor.opacity(1.0) : Color(UIColor.clear).opacity(0.0))
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
