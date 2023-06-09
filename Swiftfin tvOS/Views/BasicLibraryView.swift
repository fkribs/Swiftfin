//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import CollectionView
import Defaults
import JellyfinAPI
import SwiftUI

struct BasicLibraryView: View {

    @EnvironmentObject
    private var router: BasicLibraryCoordinator.Router

    @ObservedObject
    var viewModel: PagingLibraryViewModel

    @State private var activatedLetters: [String: Bool] = [:]
    
    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
    }

    // TODO: add retry
    @ViewBuilder
    private var noResultsView: some View {
        HStack(spacing: 0) {
            Spacer()
            L10n.noResults.text
            Spacer()
            LetteredScrollbar(viewModel: viewModel, activatedLetters: $activatedLetters, onSelect: { letter in
                viewModel.filterOnLetter(letter)
            })
        }
    }

    @ViewBuilder
    private var libraryItemsView: some View {
        HStack(spacing: 0) {
            PagingLibraryView(viewModel: viewModel)
                .onSelect { item in
                    router.route(to: \.item, item)
                }
                .ignoresSafeArea()
                .overlay(
                    LetteredScrollbar(viewModel: viewModel, activatedLetters: $activatedLetters, onSelect: { letter in
                        viewModel.filterOnLetter(letter)
                    }),
                    alignment: .trailing)
        }
    }

    var body: some View {
        if viewModel.isLoading && viewModel.items.isEmpty {
            loadingView
        } else if viewModel.items.isEmpty {
            noResultsView
        } else {
            libraryItemsView
        }
    }
}
