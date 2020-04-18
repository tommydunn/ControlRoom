//
//  Flow.swift
//  ControlRoom
//
//  Created by Dave DeLong on 2/19/20.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

// Thank you @Zef! https://gist.github.com/zef/e48e44a3a673c36b5a0c3d0eefb676ce

import SwiftUI

struct CollectionView<Items, Content>: View where Items: RandomAccessCollection, Items.Element: Identifiable, Content: View {
    var items: Items
    var content: (Items.Element) -> Content

    var horizontalSpacing: CGFloat
    var horizontalAlignment: HorizontalAlignment
    var verticalSpacing: CGFloat

    init(_ items: Items, horizontalSpacing: CGFloat = 8, horizontalAlignment: HorizontalAlignment, verticalSpacing: CGFloat = 8, content: @escaping (Items.Element) -> Content) {
        self.items = items
        self.content = content
        self.horizontalSpacing = horizontalSpacing
        self.horizontalAlignment = horizontalAlignment
        self.verticalSpacing = verticalSpacing
    }

    @State private var itemSizes = [SizePreference]()
    @State private var width: CGFloat = 0

    struct Row: Identifiable {
        let id: Int
        var items: [Items.Element]
    }

    func rows(width: CGFloat) -> [Row] {
        guard itemSizes.count == items.count else {
            // if itemSizes isn't yet set, return a row for each item.
            return items.enumerated().map { index, item in
                return Row(id: index, items: [item])
            }
        }

        var currentRowIndex = 0
        var rowWidth: CGFloat = 0
        var rows = [Row]()

        for (item, size) in zip(items, itemSizes) {
            let thisWidth = size.size.width
            if (width - rowWidth - horizontalSpacing - thisWidth) >= 0, rows.isNotEmpty {
                var row = rows.removeLast()
                row.items.append(item)
                rows.append(row)
                rowWidth += horizontalSpacing + thisWidth
            } else {
                rows.append(Row(id: currentRowIndex, items: [item]))
                currentRowIndex += 1
                rowWidth = thisWidth
            }
        }

        return rows
    }

    var unsizedItems: [Items.Element] {
        itemSizes.count == items.count ? [] : Array(items)
    }

    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: self.verticalSpacing) {
            ForEach(self.rows(width: width)) { row in
                HStack(alignment: .top, spacing: self.horizontalSpacing) {
                    ForEach(row.items) { element in
                        self.content(element)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GeometryReader { proxy in
            // this is a phantom view that is used to calculate the item sizes,
            // once calculated, they disappear from this collection and will be split into `rows` that are used above.
            ZStack {
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)

                ForEach(self.unsizedItems) { element in
                    SizePreferenceReader(id: element.id, content: self.content(element))
                }
            }
            .onPreferenceChange(SizePreferenceListKey.self) { sizes in
                if sizes.count == self.items.count {
                    // wait until all sizes are calculated before assigning itemSizes
                    self.itemSizes = sizes
                }
            }
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.width = size.width
            }
        })
    }
}

// used for storing the list of item sizes needed to display the items in rows
struct SizePreference: Equatable {
    let id: AnyHashable
    let size: CGSize
}

struct SizePreferenceListKey: PreferenceKey {
    static var defaultValue = [SizePreference]()

    static func reduce(value: inout [SizePreference], nextValue: () -> [SizePreference]) {
        value.append(contentsOf: nextValue())
    }
}

// used to store the overall width available to the CollectionView
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizePreferenceReader<ID: Hashable, V: View>: View {
    var id: ID
    var content: V

    var body: some View {
        content.background(GeometryReader { proxy in
            Color.clear.preference(key: SizePreferenceListKey.self, value: [SizePreference(id: self.id, size: proxy.size)])
        })
    }
}
