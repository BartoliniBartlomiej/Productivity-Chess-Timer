import SwiftUI

struct ContentView: View {
    @StateObject var vm = TimerViewModel()
    
    var body: some View {
        ZStack {
            // 1. To stworzy efekt "szkła" (blur)
            //VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
            //   .edgesIgnoringSafeArea(.all)
            
            // 2. Opcjonalnie: lekki kolor bazowy, żeby teksty były czytelniejsze
            //Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            if vm.isSetupMode {
                setupView
            } else {
                timerView
            }
        }
        .frame(width: 300, height: 400) // Kompaktowy rozmiar okna
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
            // Przycisk powrotu/resetu w rogu
            Button(action: { vm.reset() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(8)
            }
            .buttonStyle(.plain),
            alignment: .topTrailing
        )
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
