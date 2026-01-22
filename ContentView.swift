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
        .fixedSize()
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
        Button(action: {
            // Jeden przycisk obsługuje całą logikę: Start lub Przełączenie
            vm.toggleTimer()
        }) {
            ZStack {
                // TŁO: Zmienia się w zależności od stanu
                Rectangle()
                    .fill(
                        vm.isRunning
                        ? (vm.isWorkTurn ? colorApp1 : Color.red) // Praca: Zielony, Dystrakcja: Czerwony
                        : Color.gray // Pauza: Szary
                    )
                    .animation(.easeInOut, value: vm.isWorkTurn) // Płynne przejście kolorów

                VStack(spacing: 12) {
                    
                    // 1. NAGŁÓWEK (Zmienia się dynamicznie)
                    Text(vm.isWorkTurn ? "YOUR TASK" : "DISTRACTIONS")
                        .font(.headline)
                        .opacity(0.8)
                        .tracking(2) // Rozstrzelone litery dla stylu
                    
                    // 2. GŁÓWNY CZAS (Ten, który aktualnie jest aktywny)
                    Text(vm.timeString(time: vm.isWorkTurn ? vm.workTimeLeft : vm.distractionTimeElapsed))
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .contentTransition(.numericText()) // Ładna animacja cyferek

                    // 3. STATUS / PODPOWIEDŹ
                    if !vm.isRunning {
                        Text("Click to Start")
                            .font(.caption)
                            .padding(.top, 5)
                            .opacity(0.8)
                    } else {
                        // Opcjonalnie: Pokazujemy drugi czas na dole (dla kontekstu)
                        Text(vm.isWorkTurn
                             ? "Distractions: \(vm.timeString(time: vm.distractionTimeElapsed))"
                             : "Work Left: \(vm.timeString(time: vm.workTimeLeft))")
                            .font(.caption)
                            .opacity(0.6)
                    }
                }
                .foregroundColor(.white) // Tekst zawsze biały dla kontrastu
            }
        }
        .buttonStyle(.plain)
        .focusable(false)
        .overlay(
            // PRZYCISK ZAMYKANIA / ZAPISYWANIA (W prawym górnym rogu)
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
    
    // USUNIĘTO: func saveSession(...) - teraz używamy vm.saveAndReset(...)
}

// Reszta (VisualEffectView, Preview) bez zmian...
#Preview {
    ContentView(vm: TimerViewModel()) // Przekazujemy tymczasowy model do podglądu
}
