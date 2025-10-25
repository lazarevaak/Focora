//
//  LauncherView.swift
//  Focora
//
//  Created by MacBoock on 23.10.2025.
//

import SwiftUI

struct LauncherView: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var catalog: CommandCatalog
    @State private var query = ""

    var filtered: [CommandItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return catalog.items }

        return catalog.items
            .compactMap { item -> (CommandItem, Int)? in
                let title = item.title.lowercased()
                let keywords = item.keywords.map { $0.lowercased() }
                let score = fuzzyScore(for: q, in: [title] + keywords)
                return score > 0 ? (item, score) : nil
            }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .bold))
                    .shadow(color: .white, radius: 1, y: 1)

                ZStack(alignment: .leading) {
                    if query.isEmpty {
                        Text("Search apps or commands…")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .medium))
                    }

                    TextField("", text: $query)
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .medium))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            if let first = filtered.first {
                                first.run()
                                isVisible = false
                            }
                        }
                }

                if !query.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            query = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .imageScale(.large)
                            .transition(.opacity.combined(with: .scale))
                            .help("Clear")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // MARK: - Results list
            VStack(alignment: .leading, spacing: 10) {
                ForEach(filtered.prefix(10), id: \.id) { item in
                    Button(action: {
                        item.run()
                        isVisible = false
                    }) {
                        HStack(spacing: 12) {
                            Image(item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .cornerRadius(6)
                                .shadow(radius: 2, y: 1)

                            highlightMatchedText(in: item.title, query: query)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }

                if filtered.isEmpty {
                    Text("No matches found")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 16, weight: .regular))
                        .padding(.horizontal)
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.bottom, 20)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.67, green: 0.78, blue: 0.87),
                        Color(red: 0.80, green: 0.75, blue: 0.90)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.95)
                Color.white.opacity(0.05)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.8), lineWidth: 15)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 20, y: 1)
        )
        .cornerRadius(16)
    }

    // MARK: - Fuzzy matching
    private func fuzzyScore(for query: String, in texts: [String]) -> Int {
        var best = 0
        for text in texts {
            var score = 0
            var index = text.startIndex
            for char in query {
                if let found = text[index...].firstIndex(of: char) {
                    score += 1
                    index = text.index(after: found)
                } else {
                    score = 0
                    break
                }
            }
            best = max(best, score)
        }
        return best
    }

    // MARK: - Highlight matched text
    private func highlightMatchedText(in text: String, query: String) -> Text {
        guard !query.isEmpty else { return Text(text) }

        let lower = text.lowercased()
        let q = query.lowercased()

        if let range = lower.range(of: q) {
            let prefix = String(text[..<range.lowerBound])
            let match = String(text[range])
            let suffix = String(text[range.upperBound...])
            return Text(prefix)
                + Text(match).bold().foregroundColor(.accentColor)
                + Text(suffix)
        } else {
            return Text(text)
        }
    }
}
