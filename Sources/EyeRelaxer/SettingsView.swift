import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var soundManager = SoundManager.shared
    @State private var showNotificationAlert = false
    
    // Local State for deferred saving
    @State private var tempWorkInterval: Double = 20
    @State private var tempWorkIntervalInSeconds: Bool = false
    @State private var tempBreakDuration: Double = 20
    @State private var tempBreakStartSound: String = "Ping"
    @State private var tempBreakEndSound: String = "Basso"
    @State private var tempNotificationMessage: String = ""
    @State private var tempShowBreakOverlay: Bool = true
    @State private var tempLaunchAtLogin: Bool = false
    
    @State private var permissionStatus: String = "Checking..."
    @State private var permissionColor: Color = .gray
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Eye Relaxer")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Timer Settings
            VStack(alignment: .leading, spacing: 10) {
                Text("TIMER")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Work Interval")
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    TextField("20", value: $tempWorkInterval, formatter: NumberFormatter())
                    .textFieldStyle(.plain)
                    .frame(width: 40)
                    .padding(5)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    Picker("", selection: $tempWorkIntervalInSeconds) {
                        Text("min").tag(false)
                        Text("sec").tag(true)
                    }
                    .labelsHidden()
                    .frame(width: 70)
                }
                
                HStack {
                    Text("Break Duration")
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    TextField("20", value: $tempBreakDuration, formatter: NumberFormatter())
                        .textFieldStyle(.plain)
                        .frame(width: 40)
                        .padding(5)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                    Text("sec")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            
            // Sound Settings
            VStack(alignment: .leading, spacing: 10) {
                Text("SOUND")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Break Start Sound")
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Picker("", selection: $tempBreakStartSound) {
                        ForEach(soundManager.availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 120)
                }
                .onChange(of: tempBreakStartSound) { newValue in
                    soundManager.playPreview(soundName: newValue)
                }
                
                HStack {
                    Text("Break End Sound")
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Picker("", selection: $tempBreakEndSound) {
                        ForEach(soundManager.availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 120)
                }
                .onChange(of: tempBreakEndSound) { newValue in
                    soundManager.playPreview(soundName: newValue)
                }
                
                HStack(spacing: 10) {
                    Button(action: {
                        soundManager.playPreview(soundName: tempBreakStartSound)
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Test Start")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        soundManager.playPreview(soundName: tempBreakEndSound)
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Test End")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            
            // Notification Settings
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("NOTIFICATIONS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(permissionStatus)
                        .font(.caption)
                        .foregroundColor(permissionColor)
                }
                
                TextField("Notification Message", text: $tempNotificationMessage)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Button(action: {
                        NotificationManager.shared.requestAuthorizationIfNeeded { _ in
                            checkPermissions()
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("Request Permission")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                    }
                    .buttonStyle(.plain)

                    Button(action: openNotificationSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: {
                    NotificationManager.shared.sendNotification(title: "Test Notification", body: "This is a test notification.")
                    showNotificationAlert = true
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Test Notification")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .alert("Notification Sent", isPresented: $showNotificationAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("If you didn't see it, check Notification Center or System Settings > Notifications.")
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            
            // System
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Full-Screen Break Overlay", isOn: $tempShowBreakOverlay)
                    .toggleStyle(.switch)
                    .foregroundColor(.white.opacity(0.9))
                Toggle("Launch at Login", isOn: $tempLaunchAtLogin)
                    .toggleStyle(.switch)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: resetToDefaults) {
                    Text("Reset to Defaults")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.red.opacity(0.6))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: saveSettings) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 400, height: 700)
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
        .onAppear {
            loadSettings()
            checkPermissions()
        }
    }
    
    private func loadSettings() {
        // Show whole minutes as minutes; anything else in seconds.
        tempWorkIntervalInSeconds = appState.workInterval.truncatingRemainder(dividingBy: 60) != 0
        tempWorkInterval = tempWorkIntervalInSeconds ? appState.workInterval : appState.workInterval / 60
        tempBreakDuration = appState.breakDuration
        tempBreakStartSound = soundManager.breakStartSound
        tempBreakEndSound = soundManager.breakEndSound
        tempNotificationMessage = appState.notificationMessage
        tempShowBreakOverlay = appState.showBreakOverlay
        tempLaunchAtLogin = appState.launchAtLogin
    }
    
    private func resetToDefaults() {
        tempWorkInterval = 20
        tempWorkIntervalInSeconds = false
        tempBreakDuration = 20
        tempBreakStartSound = "Ping"
        tempBreakEndSound = "Basso"
        tempNotificationMessage = "Time to relax your eyes! Look at something 20 feet away."
        tempShowBreakOverlay = true
        tempLaunchAtLogin = false
    }
    
    private func saveSettings() {
        appState.workInterval = max(1, tempWorkIntervalInSeconds ? tempWorkInterval : tempWorkInterval * 60)
        appState.breakDuration = tempBreakDuration
        soundManager.breakStartSound = tempBreakStartSound
        soundManager.breakEndSound = tempBreakEndSound
        appState.notificationMessage = tempNotificationMessage
        appState.showBreakOverlay = tempShowBreakOverlay
        appState.launchAtLogin = tempLaunchAtLogin
        
        // Reset timer with new settings
        appState.resetTimer()
        
        // Close window
        NSApp.keyWindow?.close()
    }
    
    private func checkPermissions() {
        NotificationManager.shared.checkPermission { status in
            switch status {
            case .authorized:
                permissionStatus = "Authorized"
                permissionColor = .green
            case .denied:
                permissionStatus = "Denied"
                permissionColor = .red
            case .notDetermined:
                permissionStatus = "Not Determined"
                permissionColor = .orange
            case .provisional:
                permissionStatus = "Provisional"
                permissionColor = .yellow
            case .ephemeral:
                permissionStatus = "Ephemeral"
                permissionColor = .yellow
            @unknown default:
                permissionStatus = "Unknown"
                permissionColor = .gray
            }
        }
    }

    private func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
}
