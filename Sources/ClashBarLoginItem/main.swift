import AppKit
import Foundation

let appURL = Bundle.main.bundleURL
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()

_ = NSWorkspace.shared.open(appURL)
