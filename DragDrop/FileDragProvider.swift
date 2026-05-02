import AppKit
import UniformTypeIdentifiers

class FileDragProvider: NSObject, NSFilePromiseProviderDelegate {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }

    func filePromiseProvider(
        _ filePromiseProvider: NSFilePromiseProvider,
        fileNameForType fileType: String
    ) -> String {
        fileURL.lastPathComponent
    }

    func filePromiseProvider(
        _ filePromiseProvider: NSFilePromiseProvider,
        writePromiseTo url: URL,
        completionHandler: @escaping (Error?) -> Void
    ) {
        do {
            try FileManager.default.copyItem(at: fileURL, to: url)
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    static func createDragSession(for url: URL, event: NSEvent, source: NSView) {
        let provider = NSFilePromiseProvider(fileType: UTType.fileURL.identifier, delegate: FileDragProvider(fileURL: url))

        let item = NSDraggingItem(pasteboardWriter: provider)
        item.setDraggingFrame(source.bounds, contents: NSImage())

        source.beginDraggingSession(with: [item], event: event, source: source as! NSDraggingSource)
    }
}
