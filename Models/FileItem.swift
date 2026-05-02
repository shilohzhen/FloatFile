import Foundation
import AppKit
import UniformTypeIdentifiers

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: URL
    let isDirectory: Bool
    let fileSize: Int64?
    let modifiedDate: Date?
    let icon: NSImage

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FileItem {
    static let imageExtensions: Set<String> = [
        "png", "jpg", "jpeg", "gif", "bmp", "tiff", "tif", "webp", "heic", "heif", "ico", "svg"
    ]

    var isImage: Bool {
        let ext = path.pathExtension.lowercased()
        return Self.imageExtensions.contains(ext)
    }

    func thumbnail(size: CGFloat) -> NSImage {
        if isImage, let img = NSImage(contentsOf: path) {
            img.size = NSSize(width: size, height: size)
            return img
        }
        let icon = NSWorkspace.shared.icon(forFile: path.path)
        icon.size = NSSize(width: size, height: size)
        return icon
    }

    static func loadContents(of directory: URL) -> [FileItem] {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return items.compactMap { url -> FileItem? in
            guard let resourceValues = try? url.resourceValues(
                forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
            ) else { return nil }

            let isDir = resourceValues.isDirectory ?? false
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = NSSize(width: 18, height: 18)

            return FileItem(
                name: url.lastPathComponent,
                path: url,
                isDirectory: isDir,
                fileSize: resourceValues.fileSize.map(Int64.init),
                modifiedDate: resourceValues.contentModificationDate,
                icon: icon
            )
        }
        .sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    var formattedSize: String {
        guard let size = fileSize else { return "--" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var formattedDate: String {
        guard let date = modifiedDate else { return "--" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
