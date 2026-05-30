import SwiftUI

struct PopoverView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Eye Relaxer")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Timer Display
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 0)
                
                VStack(spacing: 5) {
                    Text(appState.isPaused ? "Paused" : (appState.timerState == .breaking ? "Break Time" : "Focus Time"))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(appState.timeString)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
            }
            .padding(.vertical, 10)
            
            // Controls
            HStack(spacing: 15) {
                Button(action: {
                    appState.togglePause()
                }) {
                    VStack {
                        Image(systemName: appState.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 20))
                        Text(appState.isPaused ? "Resume" : "Pause")
                            .font(.caption2)
                    }
                    .frame(width: 60, height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(action: {
                    appState.resetTimer()
                }) {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                        Text("Reset")
                            .font(.caption2)
                    }
                    .frame(width: 60, height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    openSettings()
                }) {
                    VStack {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                        Text("Settings")
                            .font(.caption2)
                    }
                    .frame(width: 60, height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    VStack {
                        Image(systemName: "power")
                            .font(.system(size: 20))
                            .foregroundColor(.red.opacity(0.8))
                        Text("Quit")
                            .font(.caption2)
                    }
                    .frame(width: 60, height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }

            Button(action: {
                NotificationManager.shared.sendNotification(
                    title: "Eye Relaxer",
                    body: "Test notification: if you see this banner, notifications are working."
                )
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                    Text("Test Notification")
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(width: 350)
        .background(
            ZStack {
                Color.black
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
    }
    
    private func openSettings() {
        WindowManager.shared.openSettings(appState: appState)
    }
}
