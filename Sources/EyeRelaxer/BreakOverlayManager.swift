import SwiftUI
import AppKit

// Borderless windows refuse key status by default; we need it for the Skip button and Esc.
private class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class BreakOverlayManager {
    static let shared = BreakOverlayManager()

    private var windows: [NSWindow] = []

    func show(appState: AppState) {
        guard windows.isEmpty else { return }

        for screen in NSScreen.screens {
            let window = OverlayWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: BreakOverlayView(appState: appState))
            window.setFrame(screen.frame, display: true)
            window.alphaValue = 0
            window.orderFrontRegardless()
            windows.append(window)
        }

        windows.first?.makeKey()
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.6
            windows.forEach { $0.animator().alphaValue = 1 }
        }
    }

    func hide() {
        guard !windows.isEmpty else { return }
        let closing = windows
        windows = []

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            closing.forEach { $0.animator().alphaValue = 0 }
        }, completionHandler: {
            closing.forEach { $0.close() }
        })
    }
}

struct BreakOverlayView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "eye")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white.opacity(0.8))

                Text(appState.notificationMessage)
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)

                Text(appState.timeString)
                    .font(.system(size: 72, weight: .thin, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))

                Button(action: {
                    appState.skipBreak()
                }) {
                    Text("Skip Break")
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
            }
            .padding(40)
        }
    }
}
