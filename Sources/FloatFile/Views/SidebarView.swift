import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    @ObservedObject var settings = AppSettings.shared
    @Binding var showSettings: Bool

    private let quickLocations: [(name: String, icon: String, path: URL)] = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return [
            ("Home", "house", home),
            ("Desktop", "desktopcomputer", home.appendingPathComponent("Desktop")),
            ("Downloads", "arrow.down.circle", home.appendingPathComponent("Downloads")),
            ("Documents", "doc.text", home.appendingPathComponent("Documents")),
        ]
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Quick Access")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 4)

            ForEach(quickLocations, id: \.path) { location in
                Button {
                    viewModel.navigate(to: location.path)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: location.icon)
                            .frame(width: 16)
                            .foregroundStyle(.secondary)
                        Text(location.name)
                            .font(.system(size: 12))
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(
                    viewModel.currentPath == location.path
                        ? Color.accentColor.opacity(0.15)
                        : Color.clear
                )
                .cornerRadius(4)
            }

            Divider()
                .padding(.vertical, 6)

            Button {
                viewModel.goUp()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up")
                        .frame(width: 16)
                        .foregroundStyle(.secondary)
                    Text("Go Up")
                        .font(.system(size: 12))
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoUp)
            .opacity(viewModel.canGoUp ? 1.0 : 0.5)

            Spacer()

            Divider()

            Button {
                showSettings.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                        .frame(width: 16)
                        .foregroundStyle(.secondary)
                    Text("Settings")
                        .font(.system(size: 12))
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 140)
        .background(Color.white.opacity(0.05 * settings.panelOpacity))
    }
}
