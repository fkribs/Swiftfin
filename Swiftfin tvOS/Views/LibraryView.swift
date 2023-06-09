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

struct LibraryView: View {

    @EnvironmentObject
    private var router: LibraryCoordinator.Router

    @ObservedObject
    var viewModel: LibraryViewModel

    @State private var activeScrollbarLetterStatus: [String: Bool] = [:]

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
            LetteredScrollbar(viewModel: viewModel, activatedLetters: $activeScrollbarLetterStatus, onSelect: { letter in
                viewModel.filterOnLetter(letter)
            })
        }
    }
    
    private func baseItemOnSelect(_ item: BaseItemDto) {
        if let baseParent = viewModel.parent as? BaseItemDto {
            if baseParent.collectionType == "folders" {
                router.route(to: \.library, .init(parent: item, type: .folders, filters: .init()))
            } else if item.type == .folder {
                router.route(to: \.library, .init(parent: item, type: .library, filters: .init()))
            } else {
                router.route(to: \.item, item)
            }
        } else {
            router.route(to: \.item, item)
        }
    }

    @ViewBuilder
    var libraryItemsView: some View {
        HStack(spacing: 0) {
            PagingLibraryView(viewModel: viewModel)
                .onSelect { item in
                    baseItemOnSelect(item)
                }
                .padding(.trailing, 25)
                .ignoresSafeArea()
                .overlay(
                    LetteredScrollbar(viewModel: viewModel, activatedLetters: $activeScrollbarLetterStatus, onSelect: { letter in
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
