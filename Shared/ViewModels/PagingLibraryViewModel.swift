//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Defaults
import Foundation
import JellyfinAPI
import OrderedCollections
import UIKit

class PagingLibraryViewModel: ViewModel {

    @Default(.Customization.Library.gridPosterType)
    private var libraryGridPosterType

    @Published
    var items: OrderedSet<BaseItemDto> = []
    @Published
    var filterLetter: String = ""
    @Published
    var filterLetterEnd: String = ""
    
    var currentPage = 0
    var hasNextPage = true

    var pageItemSize: Int {
        let height = libraryGridPosterType == .portrait ? libraryGridPosterType.width * 1.5 : libraryGridPosterType.width / 1.77
        return UIScreen.main.maxChildren(width: libraryGridPosterType.width, height: height)
    }

    @Published var letteredScrollbarLetter: [String: Bool] = [:]
    
    internal func updateActiveFilterLetter() {
        for letter in LetteredScrollbar.letters {
            letteredScrollbarLetter[letter] = LetteredScrollbar.validateActivatedLetter(letter: letter, filterLetter: filterLetter, filterLetterEnd: filterLetterEnd)
        }
    }
    
    internal func getFilterVariables(letter: String, filterLetter: String = "", filterLetterEnd: String = "") -> [String: String] {
        var filterLetterResult = ""
        var filterLetterEndResult = ""

        if filterLetter == letter || (filterLetterEnd == "A" && filterLetter == "" && letter == "#") {
            filterLetterResult = ""
            filterLetterEndResult = ""
        } else if letter != "#" {
            filterLetterResult = letter
            filterLetterEndResult = ""
        } else {
            filterLetterResult = ""
            filterLetterEndResult = "A"
        }

        let letteredFilterVariables: [String: String] = [
            "filterLetter": filterLetterResult,
            "filterLetterEnd": filterLetterEndResult
        ]

        return letteredFilterVariables
    }

    
    func refresh() {
        currentPage = 0
        hasNextPage = true

        items = []

        requestNextPage()
    }

    func requestNextPage() {
        guard hasNextPage else { return }
        currentPage += 1
        _requestNextPage()
    }
    
    func _requestNextPage() {}
    
    func filterOnLetter(_ letter: String) {
        _filterOnLetter(letter: letter)
    }
    
    func _filterOnLetter(letter: String) {}
}
