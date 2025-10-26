import SwiftUI

struct LauncherView: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var catalog: CommandCatalog
    @State private var query = ""

    /// Поиск ТОЛЬКО по приложениям
    var filteredApps: [CommandItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }

        return catalog.apps
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
                        Text("Search apps…")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .medium))
                    }

                    TextField("", text: $query)
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .medium))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            if let first = filteredApps.first {
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

            // MARK: - Static commands (always visible)
            if query.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(catalog.commands.enumerated()), id: \.1.id) { index, item in
                        buttonRow(for: item)
                        if index < catalog.commands.count - 1 {
                            Divider().background(Color.white.opacity(0.2))
                                .padding(.leading, 15).padding(.trailing, 15)
                        }
                    }
                }
            }

            // MARK: - Apps search results
            if !query.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(filteredApps.prefix(15).enumerated()), id: \.1.id) { index, item in
                        buttonRow(for: item)
                        if index < filteredApps.prefix(15).count - 1 {
                            Divider().background(Color.white.opacity(0.2))
                                .padding(.leading, 15).padding(.trailing, 15)
                        }
                    }

                    if filteredApps.isEmpty {
                        Text("No matching apps found")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 16, weight: .regular))
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                    }
                }
            }

            Spacer(minLength: 8)
        }
        .padding(.bottom, 20)
        .background(background)
        .cornerRadius(16)
    }

    // MARK: - Button builder
    private func buttonRow(for item: CommandItem) -> some View {
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

                Text(item.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background
    private var background: some View {
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
    }

    // MARK: - Fuzzy search
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
}
