import Foundation
import Combine

class FileBrowserViewModel: ObservableObject {
    @Published var currentPath: URL
    @Published var items: [FileItem] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedItem: FileItem?

    var filteredItems: [FileItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var pathComponents: [(name: String, path: URL)] {
        let homePath = FileManager.default.homeDirectoryForCurrentUser
        var components: [(String, URL)] = []

        var current = currentPath
        while current.path.hasPrefix(homePath.path) && current != homePath {
            components.insert((current.lastPathComponent, current), at: 0)
            current = current.deletingLastPathComponent()
        }
        components.insert(("~", homePath), at: 0)
        return components
    }

    init(path: URL? = nil) {
        let fallback = AppSettings.shared.defaultFolderURL ?? FileManager.default.homeDirectoryForCurrentUser
        self.currentPath = path ?? fallback
        loadContents()
    }

    func loadContents() {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let loaded = FileItem.loadContents(of: self.currentPath)

            DispatchQueue.main.async {
                self.items = loaded
                self.isLoading = false
            }
        }
    }

    func navigate(to item: FileItem) {
        guard item.isDirectory else { return }
        currentPath = item.path
        searchText = ""
        loadContents()
    }

    func navigate(to url: URL) {
        currentPath = url
        searchText = ""
        loadContents()
    }

    func goUp() {
        let parent = currentPath.deletingLastPathComponent()
        if parent.path != currentPath.path {
            navigate(to: parent)
        }
    }

    var canGoUp: Bool {
        currentPath != FileManager.default.homeDirectoryForCurrentUser
    }
}
