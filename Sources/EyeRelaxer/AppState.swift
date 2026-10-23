import Foundation
import Combine
import ServiceManagement

enum TimerState {
    case idle
    case working
    case breaking
}

class AppState: ObservableObject {
    @Published var timerState: TimerState = .idle
    @Published var timeRemaining: TimeInterval = 0
    
    // Settings
    @Published var workInterval: TimeInterval {
        didSet { UserDefaults.standard.set(workInterval, forKey: "workInterval") }
    }
    @Published var breakDuration: TimeInterval {
        didSet { UserDefaults.standard.set(breakDuration, forKey: "breakDuration") }
    }
    @Published var notificationMessage: String {
        didSet { UserDefaults.standard.set(notificationMessage, forKey: "notificationMessage") }
    }
    @Published var showBreakOverlay: Bool {
        didSet { UserDefaults.standard.set(showBreakOverlay, forKey: "showBreakOverlay") }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLaunchAtLogin()
        }
    }
    
    @Published var isPaused: Bool = false
    
    private var timer: Timer?
    private let soundManager = SoundManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        let storedWorkInterval = UserDefaults.standard.double(forKey: "workInterval")
        self.workInterval = storedWorkInterval == 0 ? 20 * 60 : storedWorkInterval
        
        let storedBreakDuration = UserDefaults.standard.double(forKey: "breakDuration")
        self.breakDuration = storedBreakDuration == 0 ? 20 : storedBreakDuration
        
        self.notificationMessage = UserDefaults.standard.string(forKey: "notificationMessage") ?? "Time to relax your eyes! Look at something 20 feet away."
        
        self.showBreakOverlay = UserDefaults.standard.object(forKey: "showBreakOverlay") as? Bool ?? true
        
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        
        // Start in a sane state. Don’t trigger break sounds on launch.
        startWorkTimer()
    }
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startWorkTimer() {
        BreakOverlayManager.shared.hide()
        timerState = .working
        timeRemaining = workInterval
        isPaused = false
        startTimer()
    }
    
    func startBreakTimer() {
        timerState = .breaking
        timeRemaining = breakDuration
        isPaused = false
        startTimer()
        
        // Trigger effects
        soundManager.playBreakStartSound()
        notificationManager.sendNotification(title: "Eye Relaxer", body: notificationMessage)
        if showBreakOverlay {
            BreakOverlayManager.shared.show(appState: self)
        }
    }
    
    func skipBreak() {
        startWorkTimer()
    }
    
    func togglePause() {
        if isPaused {
            isPaused = false
            startTimer()
            timer?.fire()
        } else {
            isPaused = true
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerFinished()
            }
        }
    }
    
    private func timerFinished() {
        timer?.invalidate()
        if timerState == .working {
            startBreakTimer()
        } else if timerState == .breaking {
            // Break finished
            soundManager.playBreakEndSound() // Beep to signal end of break
            startWorkTimer()
        }
    }
    
    func resetTimer() {
        startWorkTimer()
    }
    
    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}
