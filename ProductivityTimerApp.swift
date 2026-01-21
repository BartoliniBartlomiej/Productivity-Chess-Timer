import SwiftUI

@main
struct ProductivityChessApp: App {
    // Delegate służy do konfiguracji okna po jego uruchomieniu
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Dodatkowe wymuszenie po pojawieniu się widoku
                    NSApp.windows.first?.level = .floating
                }
        }
        // Ukrywamy standardowy pasek tytułu, aby wyglądało jak "widget"
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Opóźnienie jest czasem potrzebne, aby upewnić się, że okno jest w pełni załadowane
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // 1. Ustawienie okna zawsze na wierzchu
                window.level = .floating
                
                // 2. Pozwól przesuwać okno chwytając za tło
                window.isMovableByWindowBackground = true
                
                // 3. Ukrycie paska tytułu
                //window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                
                // 4. Ukrycie przycisków systemowych (X, -, powiększ)
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                
                // 5. KLUCZOWE: Zablokowanie zmiany rozmiaru
                // Usuwamy flagę .resizable ze stylu okna
                window.styleMask.remove(.resizable)
                
                // Opcjonalnie: Ustaw sztywny rozmiar okna na poziomie AppKit, żeby nie mrugało przy starcie
                let fixedSize = CGSize(width: 300, height: 400)
                window.setContentSize(fixedSize)
                window.minSize = fixedSize
                window.maxSize = fixedSize
                
                window.isOpaque = false
                // window.backgroundColor = .clear
            }
        }
    }
}
