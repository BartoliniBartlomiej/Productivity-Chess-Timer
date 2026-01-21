import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var vm = TimerViewModel()
    
    @Environment(\.modelContext) private var context
    
    @State private var showHistory = false

    @State private var showCompletionAlert = false
    
    var body: some View {
        ZStack {
            if vm.isSetupMode {
                setupView
            } else {
                timerView
            }
        }
        .frame(width: 300, height: 400)
        //.background(Color(nsColor: .windowBackgroundColor))
        // 2. OTWIERANIE OKNA HISTORII
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        // 2. DEFINICJA ALBERTU (POPUPU)
        .alert("Session summary", isPresented: $showCompletionAlert) {
            Button("Task completed") {
                saveSession(isCompleted: true)
                vm.reset()
            }
            
            Button("Task not completed") {
                saveSession(isCompleted: false)
                vm.reset()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Is your task completed?")
        }
    }
    
    // Widok ustawień czasu
    var setupView: some View {
        VStack(spacing: 20) {
            Text("Productivity Chess Stopwatch")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("How much time your task will take?")
                .foregroundColor(.secondary)
            
            HStack {
                VStack {
                    Button("-5m") { if vm.targetDuration > 300 { vm.targetDuration -= 300 } }
                    Button("-10m") { if vm.targetDuration > 600 { vm.targetDuration -= 600 } }
                    Button("-30m") { if vm.targetDuration > 30*60 { vm.targetDuration -= 30*60 } }
                }
                
                
                Text("\(Int(vm.targetDuration / 60)) min")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .frame(width: 120)
                
                VStack {
                    Button("+5m") { vm.targetDuration += 300 }
                    Button("+10m") { vm.targetDuration += 600 }
                    Button("+30m") { vm.targetDuration += 30*60 }
                }
            }
            
            Button(action: {
                vm.startSession()
            }) {
                Text("START")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // 3. NOWY PRZYCISK HISTORII
            Button(action: {
                showHistory = true
            }) {
                HStack {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Historia")
                }
            }
            .buttonStyle(.borderless) // Dyskretny styl bez tła
            .padding(.top, 10)
        }
        .padding()
    }
    
    // Widok zegara szachowego
    var timerView: some View {
        VStack(spacing: 0) {
            // GÓRA: Twój czas (Praca)
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
            
            Divider()
                .frame(height: 2)
                .background(Color.black)
            
            // DÓŁ: Czas przeciwnika (Dystrakcje)
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
        }
        .overlay(
            // --- ZMIANA W PRZYCISKU RESETU ---
            Button(action: {
                // 3. LOGIKA PRZYCISKU "X"
                // Sprawdzamy, czy w ogóle coś robiliśmy (żeby nie pytać przy pustym timerze)
                let workDone = vm.targetDuration - vm.workTimeLeft
                if workDone > 0 || vm.distractionTimeElapsed > 0 {
                    // Jeśli był jakiś postęp -> Pytamy o sukces
                    showCompletionAlert = true
                } else {
                    // Jeśli nic nie zrobiono -> Po prostu reset
                    vm.reset()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(8)
            }
            .buttonStyle(.plain),
            alignment: .topTrailing
        )
    }
    
    func saveSession(isCompleted: Bool) {
            let workDuration = vm.targetDuration - vm.workTimeLeft
            
            if workDuration > 0 || vm.distractionTimeElapsed > 0 {
                let newTask = TaskItem(
                    date: Date(),
                    timeTask: workDuration,
                    timeDistractions: vm.distractionTimeElapsed,
                    timeEst: vm.targetDuration, // Zapisujemy planowany czas
                    isCompleted: isCompleted    // Zapisujemy czy sukces
                )
                
                context.insert(newTask)
            }
        }
    
    func completeTask() {
        
    }
}
#Preview{
    ContentView()
}

// Pomocniczy komponent do efektu Blur (AppKit -> SwiftUI)
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
