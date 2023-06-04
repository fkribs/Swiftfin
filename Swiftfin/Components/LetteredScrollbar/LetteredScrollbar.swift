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
    
    @ObservedObject
    var viewModel: LibraryViewModel
    var onSelect: ((String) -> Void)

    // TODO: Localization? I'm not totally sure what that looks like for non-Romanic lettering
    let letters: [String] = (0..<27).map { index in
        if index == 0 {
            return "#"
        } else {
            let scalarValue = UnicodeScalar(Int("A".unicodeScalars.first!.value) + index - 1)!
            return String(scalarValue)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(letters, id: \.self) { letter in
                    LetteredScrollbarLetter(letter: letter, viewModel: viewModel, activated: false)
                        .onSelect {}
                        .id(letter)
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
    }
}
