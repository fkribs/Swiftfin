//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Combine
import Defaults
import Factory
import JellyfinAPI
import SwiftUI
import UIKit

// TODO: Look at refactoring
final class LibraryViewModel: PagingLibraryViewModel {

    let filterViewModel: FilterViewModel

    let parent: LibraryParent?
    let type: LibraryParentType
    private let saveFilters: Bool
    var filterLetter: String
    var filterLetterEnd: String
    
    var libraryCoordinatorParameters: LibraryCoordinator.Parameters {
        if let parent = parent {
            return .init(parent: parent, type: type, filters: filterViewModel.currentFilters)
        } else {
            return .init(filters: filterViewModel.currentFilters)
        }
    }

    convenience init(filters: ItemFilters, saveFilters: Bool = false) {
        self.init(parent: nil, type: .library, filters: filters, saveFilters: saveFilters)
    }

    init(
        parent: LibraryParent?,
        type: LibraryParentType,
        filters: ItemFilters = .init(),
        saveFilters: Bool = false
    ) {
        self.parent = parent
        self.type = type
        self.filterViewModel = .init(parent: parent, currentFilters: filters)
        self.saveFilters = saveFilters
        self.filterLetter = ""
        self.filterLetterEnd = ""
        super.init()

        filterViewModel.$currentFilters
            .sink { newFilters in
                self.requestItems(with: newFilters, replaceCurrentItems: true)

                if self.saveFilters, let id = self.parent?.id {
                    Defaults[.libraryFilterStore][id] = newFilters
                }
            }
            .store(in: &cancellables)
    }

    private func requestItems(with filters: ItemFilters, replaceCurrentItems: Bool = false) {

        if replaceCurrentItems {
            self.items = []
            self.currentPage = 0
            self.hasNextPage = true
        }

        var libraryID: String?
        var personIDs: [String]?
        var studioIDs: [String]?

        if let parent = parent {
            switch type {
            case .library, .folders:
                libraryID = parent.id
            case .person:
                personIDs = [parent].compactMap(\.id)
            case .studio:
                studioIDs = [parent].compactMap(\.id)
            }
        }

        var recursive = true
        let includeItemTypes: [BaseItemKind]

        if filters.filters.contains(ItemFilter.isFavorite.filter) {
            includeItemTypes = [.movie, .boxSet, .series, .season, .episode]
        } else if type == .folders {
            recursive = false
            includeItemTypes = [.movie, .boxSet, .series, .folder, .collectionFolder]
        } else {
            includeItemTypes = [.movie, .boxSet, .series]
        }

        var excludedIDs: [String]?

        if filters.sortBy.first == SortBy.random.filter {
            excludedIDs = items.compactMap(\.id)
        }

        let genreIDs = filters.genres.compactMap(\.id)
        let sortBy: [String] = filters.sortBy.map(\.filterName).appending("IsFolder")
        let sortOrder = filters.sortOrder.map { SortOrder(rawValue: $0.filterName) ?? .ascending }
        let itemFilters: [ItemFilter] = filters.filters.compactMap { .init(rawValue: $0.filterName) }

        Task {
            await MainActor.run {
                self.isLoading = true
            }

            let parameters = Paths.GetItemsParameters(
                userID: userSession.user.id,
                excludeItemIDs: excludedIDs,
                startIndex: currentPage * pageItemSize,
                limit: pageItemSize,
                isRecursive: recursive,
                sortOrder: sortOrder,
                parentID: libraryID,
                fields: ItemFields.allCases,
                includeItemTypes: includeItemTypes,
                filters: itemFilters,
                sortBy: sortBy,
                enableUserData: true,
                personIDs: personIDs,
                // Joe Kribs: Start -->
                // Added to allow for the LetteredScrollbar to filter the items returned down to the letter/symbol selected
                nameStartsWith: filterLetter,
                nameLessThan: filterLetterEnd,
                // <-- End: joseph@kribs.net 02/06/2023
                studioIDs: studioIDs,
                genreIDs: genreIDs,
                enableImages: true
            )
            let request = Paths.getItems(parameters: parameters)
            let response = try await userSession.client.send(request)

            guard let items = response.value.items, !items.isEmpty else {
                self.hasNextPage = false
                
                // Joe Kribs: Start -->
                // This prevents the perpetual loading bar when there is no more content in a letter filtered view
                if filterLetter != "" || (filterLetterEnd == "A" && filterLetter == "") {
                    self.isLoading = false
                }
                // <-- End: joseph@kribs.net 02/06/2023
                
                return
            }

            await MainActor.run {
                self.isLoading = false
                self.items.append(contentsOf: items)
            }
        }
    }

    // Joe Kribs: Start -->
    // Function to filter based on a letter selected from the LetteredScrollbar
    func filterOnLetter(_ letter: String) {
        
        // If the letter is already selected as a filter, reset the filterLetter to empty
        if filterLetter == letter || (filterLetterEnd == "A" && filterLetter == "") {
            filterLetter = ""
        } else {
            // Otherwise, set the filterLetter to the letter selected
            filterLetter = letter
        }
        
        // If the # Symbol was selected we want to return all content that starts with a number or symbol. This means we leave the filterLetter blank
        // and instead use the filterLetterEnd for an /items call using the nameLessThan fitler to return all values before A.
        if filterLetter == "#" {
            
            filterLetter = ""
            filterLetterEnd = "A"
        }else {
            // Otherwise, the filterLetterEnd should ALWAYS be blank
            filterLetterEnd = ""

        }
        // Call to the API to replace all existing items with only items that start with the seleted letter or, if selected, don't exceed A.
        requestItems(with: filterViewModel.currentFilters, replaceCurrentItems: true)
    }
    // <-- End: joseph@kribs.net 02/06/2023
    
    override func _requestNextPage() {
        requestItems(with: filterViewModel.currentFilters)
    }
}
