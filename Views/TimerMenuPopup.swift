//
//
// TimerMenuPopup.swift
//
// Bartłomiej Kuś


import SwiftUI
import SwiftData

struct TimerMenuPopup: View {
    @ObservedObject var vm: TimerViewModel
    @Environment(\.openWindow) var openWindow
    @Environment(\.modelContext) private var context
    @State private var isHoveringOpenApp = false
    @State private var isHoveringQuit = false
    @State private var spin = 0.0
    @State private var showNoTimerPopup = false;
    

    // MARK: - Full popup view
    var body: some View {
        VStack(spacing: 12) {
            
            // LOGIC:
            if vm.showCompletionPrompt {
                completionView
            } else {
                standardTimerView
            }

            Divider().padding(.bottom, -10)

            // Footer
            HStack {
                Button("Open App") {
                    openWindow(id: "main-window")
                }
                .font(.caption)
                .buttonStyle(.link)
                .foregroundColor(.gray)
                .focusable(false)
                .contentShape(Rectangle())
                .onHover { isHoveringOpenApp = $0 }
                .scaleEffect(isHoveringOpenApp ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: isHoveringOpenApp)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
                .buttonStyle(.link)
                .foregroundColor(.gray)
                .focusable(false)
                .contentShape(Rectangle())
                .onHover { isHoveringQuit = $0 }
                .scaleEffect(isHoveringQuit ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.12), value: isHoveringQuit)
            }
            
            if (vm.showSummaryInPopup) {
                summaryPopup
            }
        }
        .padding()
        .frame(width: 220)
    }
    // MARK: - View after stop -> saving, isCompleted? (y/n)
    var completionView: some View {
        VStack(spacing: 10) {
            Text("Is task completed?")
                .font(.headline)
            
            HStack {
                Button("Yes") {
                    vm.saveAndReset(context: context, isCompleted: true)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorApp1)
                
                Button("No") {
                    vm.saveAndReset(context: context, isCompleted: false)
                }
                .buttonStyle(.bordered)
            }
            
            Button("Cancel") {
                vm.showCompletionPrompt = false
            }
            .buttonStyle(.plain)
            .font(.caption)
            .padding(.top, 5)
        }
        .padding(.vertical, 26)
    }
    
    // MARK: - Standard View
    var standardTimerView: some View {
        VStack(spacing: 12) {
            
            // SECTION 1: Timer and buttons +/-
            HStack(spacing: 15) {
                // -5m
                if (!vm.isRunning){
                    Button(action: { vm.adjustTargetDuration(by: -300) }) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .opacity(vm.isSetupMode ? 1.0 : 0.0)
                    .focusable(false)
                    
                }

                // Time
                Text(vm.timeString(time: vm.isWorkTurn ? vm.workTimeLeft : vm.distractionTimeElapsed))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.isWorkTurn ? .primary : .red)
                    .contentTransition(.numericText())
                    .frame(minWidth: 110)

                // +5m
                if (!vm.isRunning){
                    Button(action: { vm.adjustTargetDuration(by: +300) }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .opacity(vm.isSetupMode ? 1.0 : 0.0)
                    .focusable(false)
                }
            }
            .animation(.easeInOut, value: vm.isWorkTurn)

            // Status text
            Text(vm.isSetupMode ? "Ready" : (vm.isRunning ? (vm.isWorkTurn ? "Focus" : "Distractions") : "Pause"))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.top, -10)
            
            // SECTION 2: Focus/Distraction 00:00
            // POPRAWKA 1: Zamiast if() używamy opacity, żeby nie skakało
            HStack {
                Text(vm.isWorkTurn ? "Distractions" : "Focus")
                Spacer()
                Text(vm.timeString(time: vm.isWorkTurn ? vm.distractionTimeElapsed : vm.workTimeLeft))
            }
            .font(.caption)
            .foregroundColor(vm.isWorkTurn ? .red : .primary)
            .opacity(vm.isSetupMode ? 0.0 : 1.0) // Ukrywamy, ale miejsce zajmuje
            

            Divider()

            // SECTION 3: Control buttons (play/switch and Stop)
            HStack(spacing: 20) {
                
                // Play/Switch
                Button(action: {
                    // POPRAWKA 2: Logika rotacji
                    if vm.isRunning {
                        // Tylko jeśli timer już działa (czyli przełączamy tryb), wykonujemy obrót
                        withAnimation(.easeInOut(duration: 0.6)) {
                            spin += 180
                        }
                    } else {
                        // Jeśli startujemy od zera (Start), resetujemy spin (dla pewności)
                        spin = 0
                    }
                    
                    vm.toggleTimer()
                }) {
                    Image(systemName: vm.isRunning ? "arrow.triangle.2.circlepath.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .rotationEffect(.degrees(spin))
                }
                .buttonStyle(.plain)
                .foregroundColor(vm.isRunning ? .orange : colorApp1)
                .help(vm.isRunning ? "Change mode" : "Start")
                .focusable(false)
            
                // Stop
                Button(action: {
                    // vm.showSummaryInPopup = true
                    print("Debug: Stop clicked")
                    if(!vm.isSetupMode){
                        vm.requestFinish()
                        spin = 0 // Reset obrotu po zatrzymaniu
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNoTimerPopup = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showNoTimerPopup = false
                            }
                        }
                        
                    }
                }) {
                Image(systemName: "stop.circle.fill")
                    .font(.title)
                }
                .buttonStyle(.plain)
                .opacity(vm.isSetupMode ? 0.3 : 1.0)
                .focusable(false)
            }
        }
        .overlay(alignment: .bottom) {
            if showNoTimerPopup {
                Text("No timer working.")
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
                    .transition(.opacity)
            }
        }
    }
    
    var summaryPopup: some View {
        
        VStack{
            Divider()
           
        }
    }
}

#Preview(){
    TimerMenuPopup(vm: TimerViewModel())
}
