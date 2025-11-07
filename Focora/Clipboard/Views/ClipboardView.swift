//
//  ClipboardView.swift
//  Focora
//
//  Created by Alexandra Lazareva on 29.10.2025.
//

internal import SwiftUI

struct ClipboardView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            topBar
            historyList
        }
        .frame(width: 500, height: 360)
        .background(FocoraGradients.windowBackground )
        .cornerRadius(18)
        .overlay(borderOverlay)
        .shadow(color: .black.opacity(0.4), radius: 25, y: 4)
    }
}

// MARK: - Subviews
private extension ClipboardView {
    var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Clipboard History")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(FocoraGradients.primary)
                Spacer()
            }
            
            TextField("Search...", text: $viewModel.searchText)
                .padding(6)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(FocoraGradients.topBarBackground)
    }

    var historyList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                if viewModel.filteredHistory.isEmpty && !viewModel.searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(.white.opacity(0.6))
                        .padding()
                } else {
                    ForEach(viewModel.filteredHistory) { item in
                        historyItem(item)
                    }
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - History Item View
    struct HistoryItemView: View {
        let item: ClipboardItem
        let searchText: String
        let topBarGradient: LinearGradient
        @ObservedObject var viewModel: ClipboardViewModel
        
        @State private var isHovered = false
        
        var body: some View {
            Button {
                viewModel.paste(item)
                viewModel.isVisible = false
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    highlightedText(item.content, searchText: searchText)
                        .font(.system(size: 15))
                        .lineLimit(2)
                        .foregroundColor(.white)
                    Text(item.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.2))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isHovered
                            ? Color(red: 0.70, green: 0.80, blue: 0.92).opacity(0.15)
                            : Color.white.opacity(0.05)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isHovered ? AnyShapeStyle(topBarGradient) : AnyShapeStyle(Color.clear),
                                    lineWidth: 1.5
                                )
                        )
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }

    func historyItem(_ item: ClipboardItem) -> some View {
        HistoryItemView(
            item: item,
            searchText: viewModel.searchText,
            topBarGradient: FocoraGradients.primary,
            viewModel: viewModel
        )
    }
}

// MARK: - Highlighted Text
func highlightedText(_ text: String, searchText: String) -> some View {
    if searchText.isEmpty {
        return AnyView(Text(text))
    }
    
    let lowercasedText = text.lowercased()
    let lowercasedQuery = searchText.lowercased()
    
    guard let range = lowercasedText.range(of: lowercasedQuery) else {
        return AnyView(Text(text))
    }
    
    let beforeMatch = String(text[..<range.lowerBound])
    let match = String(text[range])
    let afterMatch = String(text[range.upperBound...])
    
    return AnyView(
        HStack(spacing: 0) {
            Text(beforeMatch)
            Text(match)
                .foregroundColor(.yellow)
                .fontWeight(.bold)
            Text(afterMatch)
        }
    )
}

// MARK: - Styles
private extension ClipboardView {
    var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color(red: 0.72, green: 0.82, blue: 0.93),
                        Color(red: 0.80, green: 0.75, blue: 0.90)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 4
            )
            .opacity(0.9)
    }
}
