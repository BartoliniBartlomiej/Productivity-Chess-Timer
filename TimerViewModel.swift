import Foundation
import SwiftUI
import Combine
import SwiftData

class TimerViewModel: ObservableObject {

    @Published var targetDuration: TimeInterval = 25 * 60
    @Published var workTimeLeft: TimeInterval = 25 * 60
    @Published var distractionTimeElapsed: TimeInterval = 0
    
    @Published var isRunning: Bool = false
    @Published var isWorkTurn: Bool = true
    @Published var isSetupMode: Bool = true
    
    @Published var showCompletionPrompt: Bool = false
    @Published var showSummaryInPopup: Bool = false

    private var timer: Timer?

    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
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
        isRunning = false // first click
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
        pause() // stop tiemr
        showCompletionPrompt = true // switch view in Popup
    }

    // full reset of state
    func reset() {
        pause()
        isSetupMode = true
        showCompletionPrompt = false
        workTimeLeft = targetDuration
        distractionTimeElapsed = 0
        isWorkTurn = true
    }
    
    // logic of saving task to base
    func saveAndReset(context: ModelContext, isCompleted: Bool) {
        let workDuration = targetDuration - workTimeLeft

        // only if there is any work invlolved in task
        if workDuration > 0 || distractionTimeElapsed > 0 {
            let newTask = TaskItem(
                date: Date(),
                timeTask: workDuration,
                timeDistractions: distractionTimeElapsed,
                timeEst: targetDuration,
                isCompleted: isCompleted
            )
            context.insert(newTask)
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
                    self.showCompletionPrompt = true // when time's up -> auto completion view
                }
            } else {
                self.distractionTimeElapsed += 1
            }
        }
    }
}
