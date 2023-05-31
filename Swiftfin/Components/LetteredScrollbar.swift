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
    var viewModel: FilterViewModel
    var onSelect: (FilterCoordinator.Parameters) -> Void

    let letters: [String] = (0..<26).map { index in
        String(UnicodeScalar("A".unicodeScalars.first!.value + index)!)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                ForEach(letters, id: \.self) { letter in
                    Button(action: {
                        print(letter) // Print the letter when pressed
                    }) {
                        Text(letter)
                            .font(.system(size: 14))
                            .padding(.vertical, 2.3)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.trailing, 10)
            .frame(width: 25)
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
}

extension LetteredScrollbar {
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        self.onSelect = { _ in }
    }

    func onSelect(_ action: @escaping (FilterCoordinator.Parameters) -> Void) -> Self {
        copy(modifying: \.onSelect, with: action)
    }
}
