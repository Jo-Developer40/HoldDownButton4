# HoldDownButton4 Demo App
A SwiftUI demo app for a customizable “Hold Down Button” with status and progress bar
New in version 4 is the additional external control of the ButtonStatus.

<p align="center">
  <img src="HoldDownButton4/docs.docc/Resources/HoldDownButton4.gif" width="300">
</p>

## Features
- **HoldDownButton4**: A button that displays different statuses (Start, Pause, Stop, Ready) and provides a progress bar when pressed and held.
- **Colors**: Customizable colors and texts**: Default values for status texts and colors can be changed centrally or overwritten on the button.
- **Navigation**: NavigationStack with sample pages (demo, settings) and toolbar buttons.
- **NEW Extern control**: External control of button status
  
## Main components
- `ContentView`: Start view with navigation and example of button usage.
- `DemoView 1` and `DemoView 2`: Example pages for Buttons. For example, resetting the HoldDownButton to “ready” by another trigger.

## How to use
The button returns the status with onStateChange:
```swift
HoldDownButton(
    externalStatus: .constant(nil),
    duration: 2,
    onStateChange: { status in
        // your action here
        print("Status geändert: \(status)")
    }
)
```

You can customize the colors and text of the HoldDownButton:
```swift
HoldDownButton(
    externalStatus: .constant(nil),
    duration: 2,
    statusTextColor: .white,
    onStateChange: { status in
        // your action here
        print("Status geändert: \(status)")
    },
statusTexts: [
        .start: "Run",
        .pause: "Pause",
        .stop:  "Stop",
        .ready: "Ready!"
    ],
statusColors: [
        .start: .indigo,
        .pause: .mint,
        .stop:  .pink,
        .ready: .cyan
    ]
)
```

## Requirements
- macOS 15
- Xcode 16
- SwiftUI 15

## Getting started
1. clone from GitHub
2. Open the project in Xcode.
3. Run (`Cmd+R`).

## License
Apache License
Version 2.0, January 2004
