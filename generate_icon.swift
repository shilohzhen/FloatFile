import AppKit
import Foundation

func generateIcon(size: Int, outputPath: String) {
    let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    bitmapRep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)

    guard let ctx = NSGraphicsContext.current?.cgContext else { return }

    let s = CGFloat(size)

    // Background: rounded rect gradient
    let cornerRadius = s * 0.22
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.2, green: 0.45, blue: 0.95, alpha: 1.0),
        CGColor(red: 0.5, green: 0.25, blue: 0.9, alpha: 1.0),
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])
    ctx.restoreGState()

    // Folder body
    let folderSize = s * 0.5
    let folderX = (s - folderSize) / 2
    let folderY = s * 0.28

    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
    let folderRect = CGRect(x: folderX, y: folderY, width: folderSize, height: folderSize * 0.72)
    let folderPath = CGPath(roundedRect: folderRect, cornerWidth: folderSize * 0.08, cornerHeight: folderSize * 0.08, transform: nil)
    ctx.addPath(folderPath)
    ctx.fillPath()

    // Folder tab
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.85))
    let tabWidth = folderSize * 0.4
    let tabHeight = folderSize * 0.12
    let tabRect = CGRect(x: folderX, y: folderRect.maxY - tabHeight, width: tabWidth, height: tabHeight)
    let tabPath = CGPath(roundedRect: tabRect, cornerWidth: tabHeight * 0.3, cornerHeight: tabHeight * 0.3, transform: nil)
    ctx.addPath(tabPath)
    ctx.fillPath()

    // Pin / always-on-top indicator
    let arrowSize = s * 0.18
    let arrowX = folderX + folderSize - arrowSize * 0.3
    let arrowY = folderY - arrowSize * 0.4
    let pinCenterX = arrowX + arrowSize / 2
    let pinBottom = arrowY + arrowSize * 0.15
    let pinTop = arrowY + arrowSize * 0.85
    let pinWidth = arrowSize * 0.45

    ctx.setFillColor(CGColor(red: 1, green: 0.85, blue: 0.2, alpha: 1.0))

    // Triangle pointing up
    ctx.beginPath()
    ctx.move(to: CGPoint(x: pinCenterX, y: pinTop))
    ctx.addLine(to: CGPoint(x: pinCenterX - pinWidth, y: pinBottom))
    ctx.addLine(to: CGPoint(x: pinCenterX + pinWidth, y: pinBottom))
    ctx.closePath()
    ctx.fillPath()

    // Circle base
    let dotRadius = pinWidth * 0.45
    ctx.fillEllipse(in: CGRect(
        x: pinCenterX - dotRadius,
        y: pinBottom - dotRadius * 0.6,
        width: dotRadius * 2,
        height: dotRadius * 2
    ))

    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for \(outputPath)")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("Generated: \(outputPath) (\(size)x\(size))")
    } catch {
        print("Error: \(error)")
    }
}

let iconDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

for (size, filename) in sizes {
    generateIcon(size: size, outputPath: "\(iconDir)/\(filename)")
}

print("Done!")
