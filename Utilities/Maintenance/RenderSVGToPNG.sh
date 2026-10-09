#!/bin/sh
# Render an SVG to a PNG with macOS AppKit. No third-party renderer is required.
set -eu

svg=$1
png=${2:-${svg%.svg}.png}
size=${3:-2400}
module_cache=$(mktemp -d)
trap 'rm -rf "$module_cache"' EXIT

swift -module-cache-path "$module_cache" - "$svg" "$png" "$size" <<'SWIFT'
import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 4, let targetWidth = Int(arguments[3]) else {
    fatalError("usage: RenderSVGToPNG.sh input.svg [output.png] [width]")
}

let inputURL = URL(fileURLWithPath: arguments[1])
let outputURL = URL(fileURLWithPath: arguments[2])
guard let image = NSImage(contentsOf: inputURL) else {
    fatalError("could not load \(inputURL.path)")
}

let aspectRatio = image.size.height / image.size.width
let targetHeight = max(1, Int((CGFloat(targetWidth) * aspectRatio).rounded()))
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: targetWidth,
    pixelsHigh: targetHeight,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("could not create bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor.white.setFill()
NSRect(x: 0, y: 0, width: targetWidth, height: targetHeight).fill()
image.draw(in: NSRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
NSGraphicsContext.restoreGraphicsState()

guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("could not encode PNG")
}
try data.write(to: outputURL)
print(outputURL.path)
SWIFT
