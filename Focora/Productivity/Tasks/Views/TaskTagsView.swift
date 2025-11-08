//
//  TaskTagsView.swift
//  Focora
//
//  Created by Karabelnikov Stepan on 08.11.2025.
//

internal import SwiftUI

struct TaskTagsView: View {
    let tags: [String]
    let allTags: [TagModel]

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(tags, id: \.self) { tagName in
                if let tag = allTags.first(where: { $0.name == tagName }) {
                    Text(tag.name)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tag.color.opacity(0.2))
                        .foregroundColor(tag.color)
                        .cornerRadius(4)
                } else {
                    Text(tagName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
