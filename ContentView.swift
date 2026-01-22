import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var vm: TimerViewModel

    @Environment(\.modelContext) private var context
    @State private var showHistory = false

    var body: some View {
        ZStack {
            if vm.isSetupMode {
                setupView
            } else {
                timerView
            }
        }
        .frame(width: 300, height: 400)
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        // POPRAWKA: Alert teraz nasłuchuje centralnej zmiennej z ViewModela
        .alert("Session summary", isPresented: $vm.showCompletionPrompt) {
            Button("Task completed") {
                // Używamy funkcji z VM, która zapisuje i resetuje oba widoki
                vm.saveAndReset(context: context, isCompleted: true)
            }
            .focusable(false)

            Button("Task not completed") {
                vm.saveAndReset(context: context, isCompleted: false)
                // isTimerCancel = true // Opcjonalnie, jeśli używasz tej zmiennej globalnej
            }
            .focusable(false)

            Button("Cancel", role: .cancel) {
                // Po anulowaniu chowamy alert, ale nie resetujemy timera (wraca do pauzy)
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
                    Text("Historia")
                }
            }
            .buttonStyle(.borderless)
            .padding(.top, 10)
            .focusable(false)
        }
        .padding()
    }

    var timerView: some View {
        VStack(spacing: 0) {
            Button(action: {
                if !vm.isWorkTurn || (vm.isWorkTurn && !vm.isRunning) {
                    vm.toggleTimer()
                }
            }) {
                ZStack {
                    Rectangle()
                        .fill(vm.isWorkTurn && vm.isRunning ? Color.green : Color.gray)

                    VStack {
                        Text("YOUR TASK")
                            .font(.caption)
                            .opacity(0.7)
                        Text(vm.timeString(time: vm.workTimeLeft))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))

                        if !vm.isRunning && vm.isWorkTurn {
                            Text("Click, to start")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                    }
                    .foregroundColor(vm.isWorkTurn ? .white : .secondary)
                }
            }
            .buttonStyle(.plain)
            .focusable(false)

            Divider()
                .frame(height: 2)
                .background(Color.black)

            Button(action: {
                if vm.isWorkTurn || (!vm.isWorkTurn && !vm.isRunning) {
                    vm.toggleTimer()
                }
            }) {
                ZStack {
                    Rectangle()
                        .fill(!vm.isWorkTurn && vm.isRunning ? Color.red : Color.gray)

                    VStack {
                        Text("DISTRACTIONS")
                            .font(.caption)
                            .opacity(0.7)
                        Text(vm.timeString(time: vm.distractionTimeElapsed))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(!vm.isWorkTurn ? .white : .secondary)
                }
            }
            .buttonStyle(.plain)
            .focusable(false)
        }
        .overlay(
            Button(action: {
                // POPRAWKA: Sprawdzamy, czy coś zrobiono, i wywołujemy requestFinish w VM
                let workDone = vm.targetDuration - vm.workTimeLeft
                if workDone > 0 || vm.distractionTimeElapsed > 0 {
                    // To wywołanie spauzuje timer I ustawi showCompletionPrompt = true
                    // Dzięki temu oba okna (Popup i Main) zareagują jednocześnie
                    vm.requestFinish()
                } else {
                    vm.reset()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(8)
            }
            .focusable(false)
            .buttonStyle(.plain),
            alignment: .topTrailing
            
        )
    }
    
    // USUNIĘTO: func saveSession(...) - teraz używamy vm.saveAndReset(...)
}

// Reszta (VisualEffectView, Preview) bez zmian...
#Preview {
    ContentView(vm: TimerViewModel()) // Przekazujemy tymczasowy model do podglądu
}
