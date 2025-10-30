//
//  Shell.swift
//  Focora
//
//  Created by Alexandra Lazareva on 23.10.2025.
//

import SwiftUI

struct LauncherView: View {
    @Binding var isVisible: Bool
    @StateObject private var viewModel = LauncherViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            searchField
    
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.query.isEmpty {
                        ForEach(viewModel.commands) { item in
                            commandRow(for: item)
                        }
                    } else {
                        if viewModel.filteredApps.isEmpty {
                            Text("No matching apps found")
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                        } else {
                            ForEach(viewModel.filteredApps) { item in
                                commandRow(for: item)
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
        .background(background)
        .cornerRadius(16)
        .frame(width: 600, height: 500)
    }
    
    // MARK: - Search field
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white)
            ZStack(alignment: .leading) {
                if viewModel.query.isEmpty {
                    Text("Search apps…")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 22, weight: .medium))
                }
                TextField("", text: $viewModel.query)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .medium))
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if let first = viewModel.filteredApps.first {
                            first.run()
                            isVisible = false
                        }
                    }
            }
            if !viewModel.query.isEmpty {
                Button {
                    withAnimation { viewModel.query = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    // MARK: - Command row
    private func commandRow(for item: CommandItem) -> some View {
        Button {
            item.run()
            isVisible = false
        } label: {
            HStack(spacing: 12) {
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .cornerRadius(6)
                Text(item.title)
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Background
    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.67, green: 0.78, blue: 0.87),
                Color(red: 0.80, green: 0.75, blue: 0.90)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.95)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.8), lineWidth: 8)
        )
        .shadow(color: .black.opacity(0.2), radius: 18, y: 2)
    }
}
