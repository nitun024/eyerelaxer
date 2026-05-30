import SwiftUI
import AppKit

class WindowManager: NSObject {
    static let shared = WindowManager()
    
    private var settingsWindow: NSWindow?
    
    func openSettings(appState: AppState) {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let settingsView = SettingsView(appState: appState)
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Settings"
        window.contentViewController = hostingController
        
        // Position window on the left side to avoid overlapping with menu bar popover
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowWidth: CGFloat = 400
            let windowHeight: CGFloat = 700 // Updated height
            
            let xPos = screenRect.midX - (windowWidth / 2) // Center horizontally
            let yPos = screenRect.midY - (windowHeight / 2) // Center vertically
            
            window.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        } else {
            window.center()
        }
        
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension WindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        self.settingsWindow = nil
    }
}
