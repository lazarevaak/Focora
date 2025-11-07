//
//  TagPicker.swift
//  Focora
//
//  Created by Alexandra Lazareva on 07.11.2025.
//

internal import SwiftUI

struct TagPicker: View {
    @Binding var selectedTag: TagModel?
    let tags: [TagModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Filter by tag")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.65))

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(FocoraGradients.primary, lineWidth: 1.2)
                    )

                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(Color(red: 0.78, green: 0.86, blue: 0.96))
                        .font(.system(size: 12, weight: .semibold))

                    Picker("", selection: $selectedTag) {
                        Text("All").tag(TagModel?.none)
                        ForEach(tags, id: \.id) { tag in
                            Text(tag.name).tag(TagModel?.some(tag))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(height: 26)
                    .colorScheme(.dark)
                    .tint(Color(red: 0.75, green: 0.80, blue: 0.94))
                }
                .padding(.horizontal, 8)
            }
            .frame(width: 180, height: 35)
        }
    }
}



