import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var vm: TimerViewModel

    @Environment(\.modelContext) private var context
    @State private var showHistory = false
    @State private var currentMotivation: String = "Stay focused"

    private let textMotivation: [String] = [
        "Stay focused",
        "Keep going",
        "You're doing great",
        "One step at a time",
        "Deep work mode",
        "Minimize distractions",
        "Progress over perfection"
    ]

    var body: some View {
        ZStack {
            if vm.isSetupMode {
                setupView
            } else {
                timerView
            }
        }
        .frame(width: 300, height: 400)
        .fixedSize()
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        // alert listening var from VM
        .alert("Session summary", isPresented: $vm.showCompletionPrompt) {
            Button("Task completed") {
                vm.saveAndReset(context: context, isCompleted: true)
            }
            .focusable(false)

            Button("Task not completed") {
                vm.saveAndReset(context: context, isCompleted: false)
                // isTimerCancel = true // Opcjonalnie, jeśli używasz tej zmiennej globalnej
            }
            .focusable(false)

            Button("Cancel", role: .cancel) {
                // Cancel -> back to main timer popup view (timer is paused)
                vm.showCompletionPrompt = false
            }
            .focusable(false)
        } message: {
            Text("Is your task completed?")
        }
    }

    var setupView: some View {
        VStack(spacing: 20) {
            Text("Productivity Chess Stopwatch")
                .font(.title2)
                .fontWeight(.bold)

            Text("How much time your task will take?")
                .foregroundColor(.secondary)

            HStack {
                VStack {
                    Button("-5m") { vm.adjustTargetDuration(by: -300) }.focusable(false)
                    Button("-10m") { vm.adjustTargetDuration(by: -600) }.focusable(false)
                    Button("-30m") { vm.adjustTargetDuration(by: -1800) }.focusable(false)
                }

                Text("\(Int(vm.targetDuration / 60)) min")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .frame(width: 120)

                VStack {
                    Button("+5m") { vm.adjustTargetDuration(by: 300) }.focusable(false)
                    Button("+10m") { vm.adjustTargetDuration(by: 600) }.focusable(false)
                    Button("+30m") { vm.adjustTargetDuration(by: 1800) }.focusable(false)
                }
            }

            Button(action: {
                vm.startSession()
            }) {
                Text("START")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(colorApp1)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .focusable(false)

            Button(action: {
                showHistory = true
            }) {
                HStack {
                    Image(systemName: "list.bullet.clipboard")
                    Text("History")
                }
            }
            .buttonStyle(.borderless)
            .padding(.top, 10)
            .focusable(false)
        }
        .padding()
    }

    var timerView: some View {
        Button(action: {
            // one button controls everything
            // 1. Starts timer
            // every next switch modes (Focus/Distractions)
            vm.toggleTimer()
            
        }) {
            ZStack {
                // Background
                Rectangle()
                    .fill(
                        vm.isRunning
                        ? (vm.isWorkTurn ? colorApp1 : Color.red)
                        : Color.gray
                    )
                    .animation(.easeInOut, value: vm.isWorkTurn) // Smooth changing colors

                VStack(spacing: 12) {
                    
                    // Header
                    Text(vm.isWorkTurn ? "FOCUS" : "DISTRACTIONS")
                        .font(.headline)
                        .opacity(0.8)
                        .tracking(2) // W o r d
                    
                    // Time from mode that's live
                    Text(vm.timeString(time: vm.isWorkTurn ? vm.workTimeLeft : vm.distractionTimeElapsed))
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .contentTransition(.numericText()) // animations of numerals

                    // STATUS
                    if !vm.isRunning {
                        Text("Click to Start")
                            .font(.caption)
                            .padding(.top, 5)
                            .opacity(0.8)
                    } else {
                        // Other time
                        Text(vm.isWorkTurn
                             ? "Distractions: \(vm.timeString(time: vm.distractionTimeElapsed))"
                             : "Work Left: \(vm.timeString(time: vm.workTimeLeft))")
                            .font(.caption)
                            .opacity(0.6)
                    }
                    
                    Text(currentMotivation)
                        .font(.headline)
                        .opacity(0.8)
                        .tracking(2) // W o r d
                        .opacity(vm.isRunning ? 1 : 0.0)
                }
                .foregroundColor(.white) // Text always white
                .onChange(of: vm.isWorkTurn) { _, _ in
                    currentMotivation = textMotivation.randomElement() ?? currentMotivation
                }
                .onAppear {
                    currentMotivation = textMotivation.randomElement() ?? currentMotivation
                }
            }
        }
        .buttonStyle(.plain)
        .focusable(false)
        .overlay(
            // Exit button
            Button(action: {
                let workDone = vm.targetDuration - vm.workTimeLeft
                if workDone > 0 || vm.distractionTimeElapsed > 0 {
                    vm.requestFinish()
                } else {
                    vm.reset()
                }
                
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6)) // Lekko przezroczysty biały, żeby pasował do tła
                    .padding(12)
            }
            .buttonStyle(.plain)
            .focusable(false),
            alignment: .topTrailing
        )
    }
}

#Preview {
    ContentView(vm: TimerViewModel()) // only for preview
}

