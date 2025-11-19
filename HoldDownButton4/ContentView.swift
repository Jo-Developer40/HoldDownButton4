//
//  ContentView.swift
//  HoldDownButton4
//
//  Created by Juergen Schulz on 18.11.25.
//  
//

import SwiftUI

// MARK: -  App Views Enumeration
enum AppView: Hashable {
    case demoView
    case settingsView
}

// MARK: -  Content View
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var path: [AppView] = []
    @State private var isButtonEnabled: Bool = true
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 45) {
                    HoldDownButtonView(path: $path, isButtonEnabled: $isButtonEnabled)
                }
                .navigationTitle("Demo 1")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationButton(path: $path,title: "Demo 2", icon: "chevron.right", destination: .demoView)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationButton(path: $path,icon: "gearshape", destination: .settingsView)
                    }
                }
                .navigationDestination(for: AppView.self) { view in
                    switch view {
                    case .demoView:
                        DemoView_(path: $path, isButtonEnabled: $isButtonEnabled)
                    case .settingsView:
                        SettingsView_(path: $path)
                    }
                }
            }
        }
    }
    // MARK: - Handle Button Status Change
    func handleButtonStatus(_ status: ButtonStatus) {
        // Here you can perform any actions you like.
        print("Status geändert: \(status.rawValue)")
    }
}
// MARK: -  Helper
struct NavigationButton: View {
    @Binding var path: [AppView]
    
    var title: String? = nil
    var icon: String
    var destination: AppView

    var body: some View {
        Button {
            path.append(destination)
        } label: {
            HStack {
                if let title = title { Text(title) }
                Image(systemName: icon)
            }
        }
    }
}

// MARK: -  Demo View
struct DemoView_: View {
    @Binding var path: [AppView]
    @Binding var isButtonEnabled: Bool
    @State private var showArrow = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                SimpleHoldDownButtonSection()
                Divider()
                ColoredHoldDownButtonSection(isButtonEnabled: $isButtonEnabled)
                Toggle(isOn: $isButtonEnabled) {
                    Text("HoldDownButton is " + (isButtonEnabled ? "free" : "Blocked"))
                }
                .padding(1)
                .tint(.blue)
                Divider()
                 VStack(alignment: .leading, spacing: 20) {
                 Text("You can use all colors provided by SwiftUI as colors. These include:")
                 .padding(10)
                 Text("Predefined System Colors:")
                 .font(.headline)
                 Text(".red, .green, .blue, .yellow, .orange, .purple,\n.pink, .gray, .black, .white, .brown, .mint, .teal,\n.indigo, .cyan.")
                 //.font(.footnote)
                 .padding([.leading, .bottom], 10)
                 Text("System colors:")
                 .font(.headline)
                 Text("Color.primary, Color.accentColor Color.secondary, Color.accentColor, Color.background, etc.")
                 //.font(.footnote)
                 .padding(.leading, 10)
                 Text("These colors automatically adjust to Light/Dark Mode and the system display.")
                 .font(.caption2)
                 Text("Custom colors:")
                 .font(.headline)
                 Text("Color(red: 0.5, green: 0.2, blue: 0.7) oder    Color(hex: FF5733)")
                 //.font(.footnote)
                 .padding([.leading, .bottom], 10)
                 }
            }
            .padding()
            .navigationTitle("Demo 2")
            .toolbar {
                /* // Activate button if required
                 ToolbarItem(placement: .navigationBarTrailing) {
                 NavigationButton(
                 path: $path,
                 title: "Weiter",
                 icon: "chevron.right",
                 destination: .settingsView)
                 } */
            }
        }
    }
}

// MARK: -  Settings View
struct SettingsView_: View {
    @Binding var path: [AppView]
    
    var body: some View {
        VStack {
            Text("Settings View Content")
        }
        .navigationTitle("Settings")
        /* // Activate button if required
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    path.removeAll()
                } label: {
                    HStack {
                        Text("Anfang")
                        Image(systemName: "chevron.right")
                    }
                }
            }
        } */
    }
}

// MARK: -  HoldDownButton View with External Control
struct HoldDownButtonView: View {
    @Binding var path: [AppView]
    @Binding var isButtonEnabled: Bool
    @State private var extStatus: ButtonStatus? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Text("NEW!")
                .padding(20
                )
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text("HoldDownButton \nwith additional external control:")
                .multilineTextAlignment(.center)
            Spacer()
            Divider()
            Text("Normal control:")
            HoldDownButton(
                externalStatus: $extStatus,
                duration: 2,
                /* statusTexts: [
                 .start: "Start",
                 .pause: "Pause",
                 .stop:  "Stop",
                 .ready: "Bereit"
                 ],
                 statusColors: [
                 .start: .green,
                 .pause: .orange,
                 .stop:  .red,
                 .ready: .gray
                 ], */
                //statusTextColor: .white,
                onStateChange: { status in
                    print("Status changed: \(status)")
                }
            )
            .disabled(!isButtonEnabled)
            
            Divider()
            
            Text("External control:")
            HStack {
                ForEach(ButtonStatus.allCases, id: \.self) { status in
                    Button(status.rawValue.capitalized) {
                        extStatus = status
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            Toggle(isOn: $isButtonEnabled) {
                Text("HoldDownButton is " + (isButtonEnabled ? "free" : "Blocked"))
            }
            .padding(35)
            .tint(.blue)
            
            Divider()
            Spacer()
        }
    }
}

// Ausgelagerte Funktionen
private struct SimpleHoldDownButtonSection: View {
    var body: some View {
        VStack {
            Text("Simple HoldDownButton:")
            HoldDownButton(
                externalStatus: .constant(nil),
                duration: 2,
                onStateChange: { status in
                    print("Status geändert: \(status)")
                }
            )
        }
    }
}

private struct ColoredHoldDownButtonSection: View {
    @Binding var isButtonEnabled: Bool
    var body: some View {
        VStack {
            Text("HoldDownButton colored:")
            HoldDownButton(
                externalStatus: .constant(nil),
                duration: 2,
                statusTexts: [
                    .start: "Run!",
                    .pause: "Pause",
                    .stop:  "Stop",
                    .ready: "Ready!"
                ],
                statusColors: [
                    .start: .purple,
                    .pause: .mint,
                    .stop:  .pink,
                    .ready: .cyan
                ],
                statusTextColor: .white,
                onStateChange: { status in
                    print("Status geändert: \(status)")
                }
            )
            .disabled(!isButtonEnabled)
        }
    }
}


// MARK: -  Preview
struct ContentView_Previews: PreviewProvider {
    @State static var isButtonEnabled: Bool = true
    
    static var previews: some View {
        ContentView()
    }
}
