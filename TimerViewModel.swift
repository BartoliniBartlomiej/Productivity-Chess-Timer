//
//  TimerViewModel.swift
//  ProductivityTimer
//
//  Created by Bartłomiej Kuś on 20/01/2026.
//

import Foundation
import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    // Ustawienia
    @Published var targetDuration: TimeInterval = 25 * 60 // Domyślnie 25 min
    
    // Stan liczników
    @Published var workTimeLeft: TimeInterval = 25 * 60
    @Published var distractionTimeElapsed: TimeInterval = 0
    
    // Stan aplikacji
    @Published var isRunning: Bool = false
    @Published var isWorkTurn: Bool = true // True = Ty, False = Przeciwnik
    @Published var isSetupMode: Bool = true // Czy jesteśmy w menu ustawiania czasu
    
    private var timer: Timer?
    
    // Formatowanie czasu (MM:SS)
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startSession() {
        workTimeLeft = targetDuration
        distractionTimeElapsed = 0
        isSetupMode = false
        isRunning = false
        isWorkTurn = true
    }
    
    func toggleTimer() {
        if !isRunning {
            // Pierwsze uruchomienie
            isRunning = true
            startTicker()
        } else {
            // Przełączenie tury (jak w szachach)
            isWorkTurn.toggle()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
    }
    
    func reset() {
        pause()
        isSetupMode = true
    }
    
    private func startTicker() {
        timer?.invalidate() // Zabezpieczenie przed dublowaniem
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.isWorkTurn {
                if self.workTimeLeft > 0 {
                    self.workTimeLeft -= 1
                } else {
                    // Koniec czasu pracy - opcjonalnie dźwięk lub stop
                    self.isRunning = false
                    self.timer?.invalidate()
                }
            } else {
                self.distractionTimeElapsed += 1
            }
        }
    }
}
