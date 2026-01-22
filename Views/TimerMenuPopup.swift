////
////  TimerMenuPopup.swift
////  ProductivityTimer
////
////  Created by Bartłomiej Kuś on 21/01/2026.
////
//import SwiftUI
//import SwiftData
//
//struct TimerMenuPopup: View {
//    @ObservedObject var vm: TimerViewModel
//    @Environment(\.openWindow) var openWindow
//    @Environment(\.modelContext) private var context // Potrzebne do zapisu
//
//    var body: some View {
//        VStack(spacing: 12) {
//            
//            // LOGIKA: Jeśli trwa zamykanie sesji, pokaż pytania. Jeśli nie, pokaż timer.
//            if vm.showCompletionPrompt {
//                completionView
//            } else {
//                standardTimerView
//            }
//            
//            Divider()
//
//            // Stopka (zawsze widoczna)
//            HStack {
//                Button("Open App") { openWindow(id: "main-window") }
//                    .font(.caption)
//                    .buttonStyle(.link)
//                    .foregroundColor(.gray)
//                    .focusable(false)
//
//                Spacer()
//
//                Button("Quit") { NSApplication.shared.terminate(nil) }
//                    .font(.caption)
//                    .buttonStyle(.link)
//                    .foregroundColor(.gray)
//                    .focusable(false)
//            }
//        }
//        .padding()
//        .frame(width: 200)
//    }
//    
//    // Widok pytania "Czy skończone?"
//    var completionView: some View {
//        VStack(spacing: 10) {
//            Text("Session Finished?")
//                .font(.headline)
//            
//            HStack {
//                Button("Yes") {
//                    vm.saveAndReset(context: context, isCompleted: true)
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(colorApp1) // Używamy Twojego koloru
//                
//                Button("No") {
//                    // Tutaj zakładam, że "No" oznacza porażkę, ale zapisujemy sesję
//                    // Jeśli chcesz tylko anulować reset, użyj vm.reset() bez zapisu
//                    // Ale w Twoim kodzie "No" zapisywało jako isCompleted: false
//                    vm.saveAndReset(context: context, isCompleted: false)
//                }
//                .buttonStyle(.bordered)
//            }
//            
//            Button("Cancel (Don't Save)") {
//                vm.reset() // Tylko reset, bez zapisu
//            }
//            .buttonStyle(.plain)
//            .font(.caption)
//            .padding(.top, 5)
//        }
//        .padding(.vertical, 10)
//    }
//    
//    // Twój standardowy widok timera (z moimi poprzednimi poprawkami)
//    var standardTimerView: some View {
//        VStack(spacing: 12) {
//            HStack(spacing: 15) {
//                Button(action: { vm.adjustTargetDuration(by: -300) }) {
//                    Image(systemName: "minus.circle").font(.title2)
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(.secondary)
//                .opacity(vm.isSetupMode ? 1.0 : 0.0)
//                .focusable(false)
//
//                Text(vm.timeString(time: vm.isWorkTurn ? vm.workTimeLeft : vm.distractionTimeElapsed))
//                    .font(.system(size: 32, weight: .bold, design: .monospaced))
//                    .foregroundColor(vm.isWorkTurn ? .primary : .red)
//                    .contentTransition(.numericText())
//                    .frame(minWidth: 110)
//
//                Button(action: { vm.adjustTargetDuration(by: 300) }) {
//                    Image(systemName: "plus.circle").font(.title2)
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(.secondary)
//                .opacity(vm.isSetupMode ? 1.0 : 0.0)
//                .focusable(false)
//            }
//
//            Text(vm.isSetupMode ? "Ready" : (vm.isRunning ? (vm.isWorkTurn ? "Focus" : "Distractions") : "Pause"))
//                .font(.system(size: 12, design: .monospaced))
//                .foregroundColor(.secondary)
//
//            HStack {
//                Text(vm.isWorkTurn ? "Distractions" : "Focus")
//                Spacer()
//                Text(vm.timeString(time: vm.isWorkTurn ? vm.distractionTimeElapsed : vm.workTimeLeft))
//            }
//            .font(.caption)
//            .foregroundColor(vm.isWorkTurn ? .red : .primary)
//            .padding(.horizontal, 4)
//            
//            Divider()
//            
//            // Kontrolki
//            HStack(spacing: 20) {
//                Button(action: vm.toggleTimer) {
//                    Image(systemName: vm.isRunning ? "arrow.triangle.2.circlepath.circle.fill" : "play.circle.fill")
//                        .font(.title)
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(vm.isRunning ? .orange : colorApp1)
//                .focusable(false)
//
//                // ZMIANA: Ten przycisk teraz wywołuje requestFinish, a nie surowy reset
//                Button(action: {
//                    if vm.isSetupMode {
//                        // Jeśli w setupie, nic nie robi, albo zeruje do domyślnych
//                    } else {
//                        vm.requestFinish()
//                    }
//                }) {
//                    Image(systemName: "stop.circle.fill") // Zmieniłem ikonę na Stop, bo to kończy sesję
//                        .font(.title)
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(.gray)
//                .opacity(vm.isSetupMode ? 0.3 : 1.0) // Wygaszony w setupie
//                .focusable(false)
//            }
//        }
//    }
//}
//
//#Preview(){
//    TimerMenuPopup(vm: TimerViewModel())
//}

import SwiftUI
import SwiftData

struct TimerMenuPopup: View {
    @ObservedObject var vm: TimerViewModel
    @Environment(\.openWindow) var openWindow
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(spacing: 12) {
            
            // LOGIKA: Jeśli trwa zamykanie sesji (Stop został kliknięty) -> pokaż pytania
            if vm.showCompletionPrompt {
                completionView
            } else {
                standardTimerView // Twój oryginalny widok
            }

            Divider()

            // STOPKA (Oryginalna)
            HStack {
                Button("Open App") {
                    openWindow(id: "main-window")
                }
                .font(.caption)
                .buttonStyle(.link)
                .foregroundColor(.gray)
                .focusable(false)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
                .buttonStyle(.link)
                .foregroundColor(.gray)
                .focusable(false)
            }
        }
        .padding()
        .frame(width: 220) // Nieco szersze, by pomieścić przyciski +/-
    }
    
    // Widok pytań (Zastępuje Alert, styl minimalistyczny)
    var completionView: some View {
        VStack(spacing: 10) {
            Text("Is task completed?")
                .font(.headline)
            
            HStack {
                Button("Yes") {
                    vm.saveAndReset(context: context, isCompleted: true)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorApp1)
                
                Button("No") {
                    vm.saveAndReset(context: context, isCompleted: false)
                }
                .buttonStyle(.bordered)
            }
            
            Button("Cancel") {
                vm.showCompletionPrompt = false
            }
            .buttonStyle(.plain)
            .font(.caption)
            .padding(.top, 5)
        }
        .padding(.vertical, 10)
    }
    
    // Twój standardowy widok (Styl przywrócony)
    var standardTimerView: some View {
        VStack(spacing: 12) {
            
            // SEKCJA 1: Licznik i przyciski +/-
            HStack(spacing: 15) {
                // Przycisk -5m
                if (!vm.isRunning){
                    Button(action: { vm.adjustTargetDuration(by: -300) }) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .opacity(vm.isSetupMode ? 1.0 : 0.0)
                    .focusable(false)
                }

                // Czas
                Text(vm.timeString(time: vm.isWorkTurn ? vm.workTimeLeft : vm.distractionTimeElapsed))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(vm.isWorkTurn ? .primary : .red)
                    .contentTransition(.numericText())
                    .frame(minWidth: 110)

                // Przycisk +5m
                if (!vm.isRunning){
                    Button(action: { vm.adjustTargetDuration(by: +300) }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .opacity(vm.isSetupMode ? 1.0 : 0.0)
                    .focusable(false)
                }
            }

            // Status tekstowy
            Text(vm.isSetupMode ? "Ready" : (vm.isRunning ? (vm.isWorkTurn ? "Focus" : "Distractions") : "Pause"))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                
            // SEKCJA 2: Pasek Focus/Distraction
            if(!vm.isSetupMode){
                HStack {
                    Text(vm.isWorkTurn ? "Distractions" : "Focus")
                    Spacer()
                    Text(vm.timeString(time: vm.isWorkTurn ? vm.distractionTimeElapsed : vm.workTimeLeft))
                }
                .font(.caption)
                .foregroundColor(vm.isWorkTurn ? .red : .primary)
                .padding(.horizontal, 4)
            }
            

            Divider()

            // SEKCJA 3: Przyciski sterowania (PRZYWRÓCONE ORYGINALNE IKONY)
            HStack(spacing: 20) {
                
                // Przycisk Play/Switch
                Button(action: vm.toggleTimer) {
                    Image(systemName: vm.isRunning ? "arrow.triangle.2.circlepath.circle.fill" : "play.circle.fill")
                        .font(.title) // Oryginalny rozmiar
                }
                .buttonStyle(.plain)
                .foregroundColor(vm.isRunning ? .orange : colorApp1)
                .help(vm.isRunning ? "Change mode" : "Start")
                .focusable(false)

                Button(action: {
                    print("Debug: Stop clicked")
                    vm.requestFinish() // To musi ustawić showCompletionPrompt = true
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title)
                }
                .buttonStyle(.plain)
                .opacity(vm.isSetupMode ? 0.3 : 1.0)
                .focusable(false)
            }
        }
    }
}

#Preview(){
    TimerMenuPopup(vm: TimerViewModel())
}
