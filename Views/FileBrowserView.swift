import SwiftUI

struct FileBrowserView: View {
    @StateObject var viewModel: FileBrowserViewModel
    @ObservedObject var settings = AppSettings.shared
    @State private var showSettings = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                SidebarView(viewModel: viewModel, showSettings: $showSettings)

                VStack(spacing: 0) {
                    BreadcrumbView(viewModel: viewModel)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        TextField("Search...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                    }
                    .padding(6)
                    .background(.quaternary.opacity(0.5))
                    .cornerRadius(6)
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                    Divider()

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Spacer()
                    } else if viewModel.filteredItems.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "folder")
                                .font(.system(size: 28))
                                .foregroundStyle(.tertiary)
                            Text(viewModel.searchText.isEmpty ? "Empty folder" : "No matches")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    } else {
                        if settings.displayMode == .icons {
                            iconGridView
                        } else {
                            listView
                        }
                    }

                    // Status bar
                    HStack {
                        Text("\(viewModel.filteredItems.count) items")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()

                        // Display mode toggle
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                settings.displayMode = settings.displayMode == .list ? .icons : .list
                            }
                        } label: {
                            Image(systemName: settings.displayMode == .list ? "square.grid.2x2" : "list.bullet")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help(settings.displayMode == .list ? "Switch to icon view" : "Switch to list view")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05 * settings.panelOpacity))
                }
            }

            if showSettings {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showSettings = false
                    }

                SettingsView()
                    .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .frame(minWidth: 280, minHeight: 300)
        .onAppear {
            viewModel.loadContents()
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeSettings)) { _ in
            withAnimation {
                showSettings = false
            }
        }
    }

    // MARK: - List View
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredItems) { item in
                    FileRowView(
                        item: item,
                        isSelected: viewModel.selectedItem?.id == item.id,
                        onSelect: { viewModel.selectedItem = $0 },
                        onNavigate: { viewModel.navigate(to: $0) }
                    )

                    Divider()
                        .padding(.leading, 30)
                }
            }
        }
    }

    // MARK: - Icon Grid View
    private var iconGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80, maximum: 90), spacing: 8)
            ], spacing: 8) {
                ForEach(viewModel.filteredItems) { item in
                    FileIconView(
                        item: item,
                        isSelected: viewModel.selectedItem?.id == item.id,
                        onSelect: { viewModel.selectedItem = $0 },
                        onNavigate: { viewModel.navigate(to: $0) }
                    )
                }
            }
            .padding(8)
        }
    }
}
