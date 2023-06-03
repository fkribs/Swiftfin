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
        private let onSelect: (String) -> Void
        
        @State private var activated: Bool = false
        
        init(letter: String, activated: Bool, onSelect: @escaping (String) -> Void) {
            self.letter = letter
            self.activated = activated
            self.onSelect = onSelect
        }
        
        var body: some View {
            Button(action: {
                selectLetter()
            }) {
                Text(letter)
                    .font(.system(size: 14))
                    .frame(width: 20, height: 20)
                    .padding(7.5)
                    .background {
                        Circle()
                            .foregroundColor(activated ? accentColor : Color(UIColor.secondarySystemFill))
                            .opacity(activated ? 1.0 : 0.0)
                    }
                    .overlay {
                        Circle()
                            .stroke(activated ? accentColor : Color(UIColor.secondarySystemFill), lineWidth: 1)
                            .opacity(activated ? 1.0 : 0.0)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onTapGesture {
                activated.toggle()
            }
        }
        
        private func selectLetter() {
            activated.toggle()
            onSelect(letter)
        }
    }
}

extension LetteredScrollbar.LetteredScrollbarLetter {
    init(selectedLetter: String, activated: Bool, onSelect: @escaping (String) -> Void) {
        self.init(letter: selectedLetter, activated: activated, onSelect: onSelect)
    }
}


