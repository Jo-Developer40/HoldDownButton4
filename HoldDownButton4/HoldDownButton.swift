//
//  HoldDownButton.swift
//  HoldDownButton4
//
//  Created by Juergen Schulz on 20.11.25.
//  Special Thanks for the template from Akbarshah Jumanazarov on 3/21/24. (KS_LongPressButtpn)
//
//  A button with start/pause/stop status and a loading bar.
//  A short tap starts/pauses, a long press stops and triggers an action.
//  A external binding allows control from outside.


import SwiftUI
import Combine

// MARK: -  Button status enumeration
public enum ButtonStatus: String, CaseIterable {
    case start
    case pause
    case stop
    case ready
    case blocked

    public var isActive: Bool {
        switch self {
        case .start, .pause: return true
        case .stop, .ready, .blocked: return false
        }
    }
}

// MARK: -  Hold Timer for progress bar
class HoldTimer: ObservableObject {
    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var isActive = false

    private var timer: AnyCancellable?
    private var duration: CGFloat = 2
    private var elapsed: CGFloat = 0

    func start(duration: CGFloat) {
        self.duration = duration
        self.elapsed = 0
        self.progress = 0
        self.isActive = true
        timer?.cancel()
        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isActive else { return }
                self.elapsed += 0.01
                self.progress = min(self.elapsed / self.duration, 1)
                if self.progress >= 1 {
                    self.stop()
                }
            }
    }
    // MARK: -  Stop the timer
    func stop() {
        isActive = false
        timer?.cancel()
        timer = nil
    }
    // MARK: -
    func reset() {
        stop()
        progress = 0
        elapsed = 0
    }
    deinit { //* NEU ab V4.1.x
            timer?.cancel()
        }
}

// MARK: - HoldDownButton View
public struct HoldDownButton: View {
    @State private var internalStatus: ButtonStatus = .ready
    @State private var isHolding = false /// hold Button (for Animation)
    @StateObject private var holdTimer = HoldTimer() /// Timer for Progress bar
    @Environment(\.isEnabled) private var isEnabled //* NEU ab V4.1.x
    
    // MARK: -  External specifications, Please note the order!
    @Binding public var externalStatus: ButtonStatus?
    public var duration: CGFloat = 3
    public var statusTexts: [ButtonStatus: String]? = nil
    public var statusColors: [ButtonStatus: Color]? = nil
    public var statusTextColor: Color = .white
    public var onStateChange: (ButtonStatus) -> Void = { _ in }
    
    // MARK: -  Initializer for external specifications
    public init( //* NEU ab V4.1.x
        externalStatus: Binding<ButtonStatus?>,
        duration: CGFloat = 3,
        statusTexts: [ButtonStatus: String]? = nil,
        statusColors: [ButtonStatus: Color]? = nil,
        statusTextColor: Color = .white,
        onStateChange: @escaping (ButtonStatus) -> Void = { _ in }
    ) {
        self._externalStatus = externalStatus
        self.duration = duration
        self.statusTexts = statusTexts
        self.statusColors = statusColors
        self.statusTextColor = statusTextColor
        self.onStateChange = onStateChange
    }
    
    private var paddingVertical: CGFloat = 12
    private var paddingHorizontal: CGFloat = 25
    private var loadingTint: Color = .gray
    
    // MARK: -  Default texts and colors
    private let defaultStatusTexts: [ButtonStatus: String] = [
        .start: "run",
        .pause: "pause",
        .stop:  "stop",
        .ready: "ready",
        .blocked: "blocked" //* NEU ab V4.1.x
    ]
    private let defaultStatusColors: [ButtonStatus: Color] = [
        .start: .green,
        .pause: .yellow,
        .stop:  .red,
        .ready: .blue,
        .blocked: .gray //* NEU ab V4.1.x
    ]
    
    // MARK: -  Helper
    // Calculated status (external or internal)
    private var effectiveStatus: ButtonStatus {
        if !isEnabled { //* NEU ab V4.1.x
            return .blocked
        }
        return externalStatus ?? internalStatus
    }
    
    // Custom texts
    private func text(for status: ButtonStatus) -> String {
        statusTexts?[status] ?? defaultStatusTexts[status] ?? ""
    }
    
    // Custom colors
    private func color(for status: ButtonStatus) -> Color {
        statusColors?[status] ?? defaultStatusColors[status] ?? .gray
    }
    
    // MARK: - Body
    public var body: some View {
        VStack {
            Text(text(for: effectiveStatus)) // Button
                .foregroundColor(statusTextColor)
                .padding(.vertical, paddingVertical)
                .padding(.horizontal, paddingHorizontal)
                .frame(width: 150, height: 40)
                .background {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(isEnabled ? color(for: effectiveStatus) : Color.gray) // background color oder gray //* NEU ab V4.1.x
                        if effectiveStatus == .start || effectiveStatus == .pause || effectiveStatus == .ready {
                            Rectangle() // progress bar
                                .fill(loadingTint)
                                .frame(width: 150 * holdTimer.progress, height: 40, alignment: .leading)
                                .opacity(0.5)
                                .animation(.linear(duration: 0.1), value: holdTimer.progress)
                                .transition(.opacity)
                        }
                    }
                }
                .clipShape(Capsule())
                .contentShape(Capsule())
                .scaleEffect(isHolding ? 0.95 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHolding)
                .opacity(isEnabled ? 1.0 : 0.6) //* NEU ab V4.1.x
                .gesture(tapGesture.exclusively(before: longPressGesture))
            
            // Status display below the button (optional)
            Text("Status: \(effectiveStatus.rawValue)")
                .font(.headline)
                .foregroundStyle(.red)
                .background(.white)
                .padding(.top, 8)
            
        }
        // Initialization during display
        .onAppear {
            holdTimer.reset()
            internalStatus = .ready
        }
        .onChange(of: effectiveStatus) {
            onStateChange(effectiveStatus)
        }
    }
    
    // MARK: -  Tap gesture: Start/Pause switching
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                if isEnabled { //* NEU ab V4.1.x
                    if effectiveStatus == .start {
                        internalStatus = .pause
                    } else {
                        internalStatus = .start
                    }
                    externalStatus = nil
                    holdTimer.reset()
                }
            }
    }
    
    // MARK: -  LongPress gesture: Set stop
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged { _ in
                if isEnabled { //* NEU ab V4.1.x
                    isHolding = true
                    holdTimer.start(duration: duration)
                }
            }
            .onEnded { success in
                if isEnabled { //* NEU ab V4.1.x
                    isHolding = false
                    holdTimer.reset()
                    internalStatus = .stop
                    externalStatus = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        internalStatus = .ready
                    }
             
                }
            }
    }
}


