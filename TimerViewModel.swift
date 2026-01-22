import Foundation
import SwiftUI
import Combine
import SwiftData // WAŻNE: Dodaj ten import

class TimerViewModel: ObservableObject {

    @Published var targetDuration: TimeInterval = 25 * 60
    @Published var workTimeLeft: TimeInterval = 25 * 60
    @Published var distractionTimeElapsed: TimeInterval = 0
    
    @Published var isRunning: Bool = false
    @Published var isWorkTurn: Bool = true
    @Published var isSetupMode: Bool = true
    
    // NOWE: Stan sterujący pytaniem "Czy zakończono?" w obu oknach
    @Published var showCompletionPrompt: Bool = false

    private var timer: Timer?

    // --- Istniejące funkcje pomocnicze ---
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Nowa funkcja do zmiany czasu (z poprzedniej odpowiedzi)
    func adjustTargetDuration(by seconds: TimeInterval) {
        guard isSetupMode else { return }
        let newDuration = targetDuration + seconds
        if newDuration >= 60 {
            targetDuration = newDuration
            workTimeLeft = newDuration
        }
    }

    func startSession() {
        workTimeLeft = targetDuration
        distractionTimeElapsed = 0
        isSetupMode = false
        isRunning = false // Czeka na pierwsze kliknięcie
        isWorkTurn = true
        showCompletionPrompt = false
    }

    func toggleTimer() {
        if !isRunning {
            isRunning = true
            isSetupMode = false
            startTicker()
        } else {
            isWorkTurn.toggle()
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
    }
    
    func requestFinish() {
        print("Debug: Request Finish called")
        pause() // Zatrzymuje timer
        showCompletionPrompt = true // To przełączy widok w Popupie i wywoła Alert w Oknie
    }

    // ZMIANA: Pełny reset stanu
    func reset() {
        pause()
        isSetupMode = true
        showCompletionPrompt = false
        workTimeLeft = targetDuration
        distractionTimeElapsed = 0
        isWorkTurn = true
    }
    
    // NOWE: Logika zapisu przeniesiona tutaj
    func saveAndReset(context: ModelContext, isCompleted: Bool) {
        let workDuration = targetDuration - workTimeLeft

        // Zapisujemy tylko jeśli cokolwiek robiliśmy
        if workDuration > 0 || distractionTimeElapsed > 0 {
            let newTask = TaskItem(
                date: Date(),
                timeTask: workDuration,
                timeDistractions: distractionTimeElapsed,
                timeEst: targetDuration,
                isCompleted: isCompleted
            )
            context.insert(newTask)
            // SwiftData automatycznie zapisuje zmiany, ale context.insert jest kluczowy
            print("Task saved to history. | Work duration: \(workDuration)s |Distraction duration: \(distractionTimeElapsed)s")
        }
        
        reset()
    }

    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.isWorkTurn {
                if self.workTimeLeft > 0 {
                    self.workTimeLeft -= 1
                } else {
                    self.isRunning = false
                    self.timer?.invalidate()
                    // Opcjonalnie: Automatycznie wywołaj prompt, gdy czas się skończy
                    self.showCompletionPrompt = true
                }
            } else {
                self.distractionTimeElapsed += 1
            }
        }
    }
}
