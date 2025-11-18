//
//  HoldDownButton.swift
//  HoldDownButton4
//
//  Created by Juergen Schulz on 18.11.25.
//  Special Thanks for the template from Akbarshah Jumanazarov on 3/21/24. (KS_LongPressButtpn)
//
//  A button with start/pause/stop status and a loading bar.
//  A short tap starts/pauses, a long press stops and triggers an action.


import SwiftUI
import Combine

// Button status enumeration
public enum ButtonStatus: String, CaseIterable {
    case start, pause, stop, ready

    public var isActive: Bool {
        switch self {
        case .start, .pause: return true
        case .stop, .ready: return false
        }
    }
}


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

    func stop() {
        isActive = false
        timer?.cancel()
        timer = nil
    }

    func reset() {
        stop()
        progress = 0
        elapsed = 0
    }
}

struct HoldDownButton: View {
    @Binding var externalStatus: ButtonStatus?
    @State private var internalStatus: ButtonStatus = .ready
    @State private var isHolding = false /// hold Button (for Animation)
    @StateObject private var holdTimer = HoldTimer() /// Timer for Progress bar
    
    var duration: CGFloat = 3
    var paddingVertical: CGFloat = 12
    var paddingHorizontal: CGFloat = 25
    var loadingTint: Color = .gray
    var statusTextColor: Color = .white
    var onStateChange: (ButtonStatus) -> Void = { _ in }
    
    var statusTexts: [ButtonStatus: String]? = nil
    var statusColors: [ButtonStatus: Color]? = nil
    
    private let defaultStatusTexts: [ButtonStatus: String] = [
        .start: "run",
        .pause: "pause",
        .stop:  "stop",
        .ready: "ready",
    ]
    private let defaultStatusColors: [ButtonStatus: Color] = [
        .start: .green,
        .pause: .yellow,
        .stop:  .red,
        .ready: .blue,
    ]
    
    // Berechneter Status (extern oder intern)
    private var effectiveStatus: ButtonStatus {
        externalStatus ?? internalStatus
    }
    
    // Benutzerdefinierte Texte
    private func text(for status: ButtonStatus) -> String {
        statusTexts?[status] ?? defaultStatusTexts[status] ?? ""
    }
    
    // Benutzerdefinierte Farben
    private func color(for status: ButtonStatus) -> Color {
        statusColors?[status] ?? defaultStatusColors[status] ?? .gray
    }
    
    
    var body: some View {
        VStack {
            Text(text(for: effectiveStatus)) // Button
                .foregroundColor(statusTextColor)
                .padding(.vertical, paddingVertical)
                .padding(.horizontal, paddingHorizontal)
                .frame(width: 150, height: 40)
                .background {
                    ZStack(alignment: .leading) {
                        Rectangle() // Button Background
                            .fill(color(for: effectiveStatus))
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
                .gesture(tapGesture.exclusively(before: longPressGesture))
            
            // Statusanzeige unterhalb des Buttons (optional)
            /*
            Text("Status: \(effectiveStatus.rawValue)")
                .font(.headline)
                .foregroundStyle(.red)
                .background(.white)
                .padding(.top, 8)
            */
        }
        // Initialisierung beim Anzeigen
        .onAppear {
            holdTimer.reset()
            internalStatus = .ready
        }
        .onChange(of: effectiveStatus) {
            onStateChange(effectiveStatus)
        }
    }
    
    /// Tap-Geste: Start/Pause switching
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                if effectiveStatus == .start {
                    internalStatus = .pause
                    holdTimer.reset()
                } else {
                    internalStatus = .start
                    holdTimer.reset()
                }
            }
    }
    
    /// LongPress-Geste: Set stop
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged { _ in
                isHolding = true
                holdTimer.start(duration: duration)
            }
            .onEnded { success in
                isHolding = false
                holdTimer.reset()
                internalStatus = .stop
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    internalStatus = .ready
                }
            }
    }
}


