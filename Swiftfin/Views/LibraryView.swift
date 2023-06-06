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

    @Default(.Customization.Library.viewType)
    private var libraryViewType

    @EnvironmentObject
    private var router: LibraryCoordinator.Router

    @ObservedObject
    var viewModel: LibraryViewModel
    
    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
    }

    @State private var activatedFlags: [String: Bool] = [:]
    
    @ViewBuilder
    private var noResultsView: some View {
        // Joe Kribs: Start -->
        // Changed to include the LetteredScrollbar. This allows users to remove a letter filter when there is no content found.
        HStack(spacing: 0) {
            Spacer()
            L10n.noResults.text
            Spacer()
            LetteredScrollbar(viewModel: viewModel, activatedFlags: $activatedFlags, onSelect: { letter in
                viewModel.filterOnLetter(letter)
            })
        }
        // <-- End: joseph@kribs.net 02/06/2023
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
            // Joe Kribs: Start -->
            // Added to allow for the LetteredScrollbar to filter the items returned down to the letter/symbol selected
                .padding(.trailing, 25)
                .ignoresSafeArea()
                .overlay(
                    LetteredScrollbar(viewModel: viewModel, activatedFlags: $activatedFlags, onSelect: { letter in
                        viewModel.filterOnLetter(letter)
                    }),
                    alignment: .trailing)
            // <-- End: joseph@kribs.net 02/06/2023
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                loadingView
            } else if viewModel.items.isEmpty {
                noResultsView
            } else {
                libraryItemsView
            }
        }
        .navigationTitle(viewModel.parent?.displayTitle ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navBarDrawer {
            ScrollView(.horizontal, showsIndicators: false) {
                FilterDrawerHStack(viewModel: viewModel.filterViewModel)
                    .onSelect { filterCoordinatorParameters in
                        router.route(to: \.filter, filterCoordinatorParameters)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 1)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {

                if viewModel.isLoading && !viewModel.items.isEmpty {
                    ProgressView()
                }

                LibraryViewTypeToggle(libraryViewType: $libraryViewType)
            }
        }
    }
}
