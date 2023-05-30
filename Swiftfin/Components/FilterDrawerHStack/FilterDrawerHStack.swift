//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct FilterDrawerHStack: View {

    @ObservedObject
    var viewModel: FilterViewModel
    private var onSelect: (FilterCoordinator.Parameters) -> Void
    
    let letters: [String] = (0..<26).map { index in
        String(UnicodeScalar("A".unicodeScalars.first!.value + index)!)
    }

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                if viewModel.currentFilters.hasFilters {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.currentFilters = .init()
                        } label: {
                            L10n.reset.text
                        }
                    } label: {
                        FilterDrawerButton(systemName: "line.3.horizontal.decrease.circle.fill", activated: true)
                    }
                }
                
                FilterDrawerButton(title: L10n.genres, activated: viewModel.currentFilters.genres != [])
                    .onSelect {
                        onSelect(.init(
                            title: L10n.genres,
                            viewModel: viewModel,
                            filter: \.genres,
                            selectorType: .multi
                        ))
                    }
                
                FilterDrawerButton(title: L10n.filters, activated: viewModel.currentFilters.filters != [])
                    .onSelect {
                        onSelect(.init(
                            title: L10n.filters,
                            viewModel: viewModel,
                            filter: \.filters,
                            selectorType: .multi
                        ))
                    }
                
                // TODO: Localize
                FilterDrawerButton(title: "Order", activated: viewModel.currentFilters.sortOrder != [APISortOrder.ascending.filter])
                    .onSelect {
                        onSelect(.init(
                            title: "Order",
                            viewModel: viewModel,
                            filter: \.sortOrder,
                            selectorType: .single
                        ))
                    }
                
                // TODO: Localize
                FilterDrawerButton(title: "Sort", activated: viewModel.currentFilters.sortBy != [SortBy.name.filter])
                    .onSelect {
                        onSelect(.init(
                            title: "Sort",
                            viewModel: viewModel,
                            filter: \.sortBy,
                            selectorType: .single
                        ))
                    }
            }
            .padding(.horizontal, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            // TODO: Handle selection of letter
                        }) {
                            Text(letter)
                                .font(.system(size: 12))
                                .padding(.vertical, 4)
                        }
                        .frame(width: 30, height: 30)
                        .background {
                            Capsule()
                                .foregroundColor(Color(UIColor.secondarySystemFill))
                            //.foregroundColor(activated ? accentColor : Color(UIColor.secondarySystemFill))
                                .opacity(0.5)
                        }
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

extension FilterDrawerHStack {
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        self.onSelect = { _ in }
    }

    func onSelect(_ action: @escaping (FilterCoordinator.Parameters) -> Void) -> Self {
        copy(modifying: \.onSelect, with: action)
    }
}
