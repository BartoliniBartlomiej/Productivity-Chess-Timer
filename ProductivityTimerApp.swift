import SwiftUI
import SwiftData

@main
struct ProductivityTimerApp: App {
    @StateObject private var vm = TimerViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskItem.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup(id: "main-window") {
            ContentView(vm: vm)
        }
        .modelContainer(sharedModelContainer)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra {
            TimerMenuPopup(vm: vm)
                .modelContainer(sharedModelContainer)
        } label: {
            let time = vm.isWorkTurn ? vm.workTimeLeft : vm.distractionTimeElapsed
            
            HStack(spacing: 6) {
                Text(vm.timeString(time: time))
                    .font(.custom("Menlo", size: 12))
                    .frame(width: 40, alignment: .trailing)
                
                Image(systemName: vm.isRunning ? (vm.isWorkTurn ? "pencil.and.scribble" : "hourglass.badge.eye") : "timer")
                    .frame(width: 22)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

//class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // Opóźnienie jest czasem potrzebne, aby upewnić się, że okno jest w pełni załadowane
//        DispatchQueue.main.async {
//            if let window = NSApplication.shared.windows.first {
//                // 1. Ustawienie okna zawsze na wierzchu
//                window.level = .floating
//                
//                // 2. Pozwól przesuwać okno chwytając za tło
//                window.isMovableByWindowBackground = true
//                
//                // 3. Ukrycie paska tytułu
//                //window.titleVisibility = .hidden
//                window.titlebarAppearsTransparent = true
//                
//                // 4. Ukrycie przycisków systemowych (X, -, powiększ)
//                // window.standardWindowButton(.closeButton)?.isHidden = true
//                // window.standardWindowButton(.miniaturizeButton)?.isHidden = true
//                // window.standardWindowButton(.zoomButton)?.isHidden = true
//                
//                // 5. KLUCZOWE: Zablokowanie zmiany rozmiaru
//                // Usuwamy flagę .resizable ze stylu okna
//                window.styleMask.remove(.resizable)
//                
//                // Opcjonalnie: Ustaw sztywny rozmiar okna na poziomie AppKit, żeby nie mrugało przy starcie
//                let fixedSize = CGSize(width: 300, height: 400)
//                window.setContentSize(fixedSize)
//                window.minSize = fixedSize
//                window.maxSize = fixedSize
//                
//                window.isOpaque = false
//                // window.backgroundColor = .clear
//            }
//        }
//    }
//}

