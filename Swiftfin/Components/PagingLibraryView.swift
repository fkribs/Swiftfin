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

struct PagingLibraryView: View {
    
    @Default(.Customization.Library.gridPosterType)
    private var libraryGridPosterType
    @Default(.Customization.Library.viewType)
    private var libraryViewType
    
    @ObservedObject
    var viewModel: PagingLibraryViewModel
    
    private var onSelect: (BaseItemDto) -> Void
    
    private var gridLayout: NSCollectionLayoutSection.GridLayoutMode {
        if libraryGridPosterType == .landscape && UIDevice.isPhone {
            return .fixedNumberOfColumns(2)
        } else {
            return .adaptive(withMinItemSize: libraryGridPosterType.width + (UIDevice.isIPad ? 10 : 0))
        }
    }
    
    struct ScrollBarPreferenceKey: PreferenceKey {
        static var defaultValue: CGRect = .zero
        
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
            value = nextValue()
        }
    }
    
    @State private var selectedLetter: String = ""
    
    var body: some View {
        let letters: [String] = (0..<26).map { index in
            String(UnicodeScalar("A".unicodeScalars.first!.value + index)!)
        }
        
        HStack(spacing: 0) {
            CollectionView(items: viewModel.items.elements) { _, item, _ in
                PosterButton(state: .item(item), type: libraryGridPosterType)
                    .scaleItem(libraryGridPosterType == .landscape && UIDevice.isPhone ? 0.85 : 1)
                    .onSelect {
                        onSelect(item)
                    }
            }
            .layout { _, layoutEnvironment in
                .grid(
                    layoutEnvironment: layoutEnvironment,
                    layoutMode: gridLayout,
                    sectionInsets: .init(top: 0, leading: 10, bottom: 0, trailing: 10)
                )
            }
            .willReachEdge(insets: .init(top: 0, leading: 0, bottom: 200, trailing: 0)) { edge in
                if !viewModel.isLoading && edge == .bottom {
                    viewModel.requestNextPage()
                }
            }
            .onEdgeReached { edge in
                if viewModel.hasNextPage, !viewModel.isLoading, edge == .bottom {
                    viewModel.requestNextPage()
                }
            }
            
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(letters, id: \.self) { letter in
                            Button(action: {
                                withAnimation {
                                    scrollViewProxy.scrollTo(letter, anchor: .top)
                                }
                            }) {
                                Text(letter)
                                    .font(.system(size: 12))
                                    .padding(.vertical, 4)
                            }
                            .id(letter)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: ScrollBarPreferenceKey.self, value: proxy.frame(in: .global))
                    }
                    .onPreferenceChange(ScrollBarPreferenceKey.self) { frame in
                        let minY = frame.minY
                        let maxY = frame.maxY
                        let scrollHeight = maxY - minY
                        let scrollPosition = minY + (scrollHeight / CGFloat(letters.count)) * CGFloat(letters.firstIndex(of: selectedLetter) ?? 0)
                        let contentOffset = CGPoint(x: 0, y: scrollPosition)
                    }
                )
            }
            .onChange(of: selectedLetter) { newValue in
                // Handle scroll to specific section
                // Add your code to scroll to the desired section
            }
            .onAppear {
                if let firstLetter = letters.first {
                    selectedLetter = firstLetter
                }
            }
        }
        .introspectScrollView { scrollView in
            scrollView.showsVerticalScrollIndicator = false
        }
    }
    
    init(viewModel: PagingLibraryViewModel) {
        self.viewModel = viewModel
        self.onSelect = { _ in }
    }
    
    func onSelect(_ action: @escaping (BaseItemDto) -> Void) -> PagingLibraryView {
        var updatedView = self
        updatedView.onSelect = action
        return updatedView
    }
}

