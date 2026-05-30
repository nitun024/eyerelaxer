# Eye Relaxer App - Walkthrough

## Overview
The Eye Relaxer App is a macOS Menu Bar application designed to help you prevent eye strain by reminding you to take breaks.

## Installation & Usage

1.  **Locate the App**: The app is built and located at `EyeRelaxer/EyeRelaxer.app`.
2.  **Launch**: Double-click `EyeRelaxer.app` to start.
3.  **Menu Bar Icon**: You will see an "eye" icon in the menu bar.
    -   **Click**: Opens a custom popover window with a large countdown timer.
    -   **Break State**: The icon turns green during a break.

## Features

### 1. Timer
-   **Work Interval**: Defaults to 20 minutes. Configurable in Settings.
-   **Break Duration**: Defaults to 20 seconds. Configurable in Settings.
-   **Behavior**:
    -   **Sound on Launch**: A beep plays immediately when the app starts.
    -   After the work interval, the **Break Start Sound** plays, and a notification appears.
    -   The break timer starts.
    -   After the break duration, the **Break End Sound** plays to signal the end of the break.

### 2. UI Design
-   **Glam Look**: Dark, modern interface with gradients and large typography.
-   **App Name**: "Eye Relaxer" is clearly visible at the top.
-   **Countdown**: A large circular timer shows the remaining time.

### 3. Controls
Inside the popover window:
-   **Reset**: Restart the work interval immediately.
-   **Settings**: Open the configuration window.
-   **Quit**: Exit the application.

### 4. Settings
The Settings window has been redesigned for a cleaner look:
-   **Header**: Now titled "Eye Relaxer".
-   **Position**: Opens in the **center** of the screen.
-   **Timer Settings**: Adjust Work Interval and Break Duration.
-   **Sound Settings**:
    -   **Break Start Sound**: Choose the sound to play when a break begins.
    -   **Break End Sound**: Choose the sound to play when a break ends.
    -   **Test Buttons**: Preview each sound.
-   **Notification Settings**:
    -   **Status**: Shows if notifications are Authorized or Denied.
    -   **Test Notification**: Button to verify notifications work (uses AppleScript fallback).
-   **System**: Toggle "Launch at Login".
-   **Actions**:
    -   **Reset to Defaults**: Restores 20/20 settings.
    -   **Save**: Applies changes, resets the timer, and closes the window.

## Verification Results
-   [x] **Build**: Successfully built `EyeRelaxer.app`.
-   [x] **Launch**: App launches and plays a sound.
-   [x] **UI**: Verified the new "glam" popover design.
-   [x] **Settings Window**:
    -   Verified only one Settings window opens at a time.
    -   Verified it opens in the center.
    -   Verified header text is "Eye Relaxer".
-   [x] **Notifications**:
    -   Added permission status indicator.
    -   **Added AppleScript Fallback**: Ensures notifications appear even if the app is unsigned or permissions are tricky.
-   [x] **Timer Logic**: Verified code logic for 20-20-20 rule.

## Troubleshooting
-   **Notifications not showing**:
    1.  Open **Settings**.
    2.  Click **Test Notification**.
    3.  You should see a notification appear (either a system alert or a banner).
    4.  If "Status" says "Denied", check System Settings, but the new fallback should work regardless.
-   **Sound not playing**: Check system volume.
