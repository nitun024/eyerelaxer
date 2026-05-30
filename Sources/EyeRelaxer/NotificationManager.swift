import UserNotifications
import AppKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    /// Call this at app launch and/or before first notification.
    func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        center.getNotificationSettings { settings in
            print("[Notifications] status=\(settings.authorizationStatus) alerts=\(settings.alertSetting) sound=\(settings.soundSetting)")

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion?(true) }
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("[Notifications] requestAuthorization error: \(error)")
                    }
                    print("[Notifications] requestAuthorization granted=\(granted)")
                    DispatchQueue.main.async { completion?(granted) }
                }
            case .denied:
                print("[Notifications] Permission denied in System Settings")
                DispatchQueue.main.async { completion?(false) }
            @unknown default:
                DispatchQueue.main.async { completion?(false) }
            }
        }
    }

    func sendNotification(title: String, body: String) {
        requestAuthorizationIfNeeded { granted in
            guard granted else {
                print("[Notifications] Not sending; permission not granted.")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default

            // NOTE: Do NOT set `content.interruptionLevel = .timeSensitive` here.
            // Time-sensitive notifications require the
            // `com.apple.developer.usernotifications.time-sensitive` entitlement,
            // which an ad-hoc-signed app does not have. The system silently rejects
            // the delivery in that case ("missing authorization" in usernoted logs).
            // The default `.active` level is the right choice for this menu bar app.

            // Using a short time trigger tends to be more reliable than an immediate (nil) trigger
            // for menu bar (LSUIElement) apps.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // For menu bar apps, briefly show in dock so the app icon appears in notifications
            let wasHidden = NSApp.isHidden
            NSApp.unhide(nil)

            self.center.add(request) { error in
                if let error = error {
                    print("[Notifications] Error adding request: \(error)")
                } else {
                    print("[Notifications] Scheduled notification: \(title)")
                }

                // Hide the app after notification is sent
                if wasHidden {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NSApp.hide(nil)
                    }
                }
            }

            self.center.getPendingNotificationRequests { reqs in
                print("[Notifications] pendingRequests=\(reqs.count)")
            }
        }
    }

    func checkPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // Show notification even if app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
