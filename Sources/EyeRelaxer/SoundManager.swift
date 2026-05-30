import AppKit
import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var breakStartSound: String {
        didSet {
            UserDefaults.standard.set(breakStartSound, forKey: "breakStartSound")
        }
    }
    
    @Published var breakEndSound: String {
        didSet {
            UserDefaults.standard.set(breakEndSound, forKey: "breakEndSound")
        }
    }
    
    let availableSounds = ["Ping", "Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]
    
    init() {
        self.breakStartSound = UserDefaults.standard.string(forKey: "breakStartSound") ?? "Ping"
        self.breakEndSound = UserDefaults.standard.string(forKey: "breakEndSound") ?? "Basso"
    }
    
    func playBreakStartSound() {
        playSound(name: breakStartSound)
    }
    
    func playBreakEndSound() {
        playSound(name: breakEndSound)
    }
    
    private func playSound(name: String) {
        if let sound = NSSound(named: name) {
            sound.play()
        } else {
            // Fallback
            NSSound.beep()
        }
    }
    
    func playPreview(soundName: String) {
        if let sound = NSSound(named: soundName) {
            sound.play()
        }
    }
}
