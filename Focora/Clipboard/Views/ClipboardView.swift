//
//  ClipboardView.swift
//  Focora
//
//  Created by MacBoock on 29.10.2025.
//

import SwiftUI

struct ClipboardView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Clipboard History")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 4)

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.history) { item in
                        Button {
                            viewModel.paste(item)
                            viewModel.isVisible = false
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.content)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                    .lineLimit(2)
                                Text(item.date.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 500, height: 360)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
