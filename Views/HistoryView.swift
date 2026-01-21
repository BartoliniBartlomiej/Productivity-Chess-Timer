//
//  HistoryView.swift
//  ProductivityTimer
//
//  Created by Bartłomiej Kuś on 21/01/2026.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    // To pozwala zamknąć okno historii
    @Environment(\.dismiss) private var dismiss
    
    // To automatycznie pobiera dane z bazy i sortuje je od najnowszych
    @Query(sort: \TaskItem.date, order: .reverse) private var history: [TaskItem]
    
    // To pozwala usuwać elementy z bazy
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(spacing: 0) {
            // --- Nagłówek ---
            HStack {
                Text("History of Sessions")
                    .font(.headline)
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // --- TU DODAJ WYKRES ---
            // Wyświetlamy go tylko, jeśli jest historia
            if !history.isEmpty {
                HistoryChartView(history: history)
                    .padding(.bottom, 10)
                
                Divider() // Oddzielenie wykresu od listy
            }
            // -----------------------

            // --- Lista ---
            if history.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .opacity(0.3)
                    Text("No sessions in history")
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                    Spacer()
                }
            } else {
                List {
                    // Iterujemy po dniach (kluczach słownika)
                    ForEach(groupedHistoryKeys, id: \.self) { dayDate in
                        Section {
                            // Iterujemy po zadaniach z konkretnego dnia
                            ForEach(groupedHistory[dayDate] ?? []) { item in
                                taskRow(item)
                            }
                            .onDelete { indexSet in
                                deleteItems(at: indexSet, in: groupedHistory[dayDate] ?? [])
                            }
                        } header: {
                            // Nagłówek sekcji (Data)
                            Text(dayDate.formatted(date: .complete, time: .omitted))
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                        } footer: {
                            // Stopka sekcji (Podsumowanie dnia)
                            DailySummaryRow(items: groupedHistory[dayDate] ?? [])
                                .padding(.top, 8)
                                .padding(.bottom, 16)
                        }
                    }
                }
                .listStyle(.sidebar) // Styl sidebar ładnie oddziela sekcje
            }
        }
        .frame(minWidth: 300, minHeight: 500)
    }

    // MARK: - Logika Grupowania
    
    // Grupujemy wpisy po dacie (ignorując godzinę)
    var groupedHistory: [Date: [TaskItem]] {
        Dictionary(grouping: history) { item in
            Calendar.current.startOfDay(for: item.date)
        }
    }
    
    // Wyciągamy posortowane klucze (daty), żeby dni wyświetlały się chronologicznie (od najnowszego)
    var groupedHistoryKeys: [Date] {
        groupedHistory.keys.sorted(by: >)
    }

    // MARK: - Wiersz Zadania (Twoja logika UI)
    
    private func taskRow(_ item: TaskItem) -> some View {
        HStack {
            // Data/Godzina po lewej (pokazujemy tylko godzinę, bo data jest w nagłówku sekcji)
            Text(item.date.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Divider()
                .frame(height: 20)

            // Czasy pośrodku (Work / Distractions)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        //.foregroundColor(.green)
                        .font(.caption2)
                    Text("Work: \(formatTime(item.timeTask))")
                }
                
                // Pokazujemy dystrakcje tylko jeśli wystąpiły (opcjonalne, dla czystości)
                if item.timeDistractions > 0 {
                    HStack {
                        Image(systemName: "iphone.gen1.circle.fill")
                            //.foregroundColor(.red)
                            .font(.caption2)
                        Text("Distractions: \(formatTime(item.timeDistractions))")
                    }
                }
            }
            .font(.system(.caption, design: .monospaced))
            
            Spacer()
            
            // Prawa strona (Twoje podsumowania itemu: Suma i Estymacja)
            HStack{
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Σ \(formatTime(item.timeFull))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Est. \(formatTime(item.timeEst))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if(item.isCompleted == false) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                } else if (item.isCompleted == true){
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
        }
        .padding(.vertical, 4)
        // Menu kontekstowe
        .contextMenu {
            Button("Delete Session", role: .destructive) {
                deleteItem(item)
            }
        }
    }

    // MARK: - Funkcje Pomocnicze
    
    // Zmodyfikowana funkcja usuwania obsługująca grupowanie
    private func deleteItems(at offsets: IndexSet, in items: [TaskItem]) {
        for index in offsets {
            let itemToDelete = items[index]
            context.delete(itemToDelete)
        }
    }
    
    private func deleteItem(_ item: TaskItem) {
        context.delete(item)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Komponent Podsumowania Dnia
struct DailySummaryRow: View {
    let items: [TaskItem]
    
    var totalWork: TimeInterval {
        items.reduce(0) { $0 + $1.timeTask }
    }
    
    var totalDistraction: TimeInterval {
        items.reduce(0) { $0 + $1.timeDistractions }
    }
    
    // Formatowanie dla podsumowania (np. 1h 20m)
    func format(_ time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = (Int(time) % 3600) / 60
        if h > 0 {
            return String(format: "%dh %02dm", h, m)
        } else {
            return String(format: "%02d min", m)
        }
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Divider()
            HStack {
                Text("DAILY TOTAL:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Label(format(totalWork), systemImage: "briefcase.fill")
                        .foregroundColor(.green)
                    
                    Label(format(totalDistraction), systemImage: "coffee.fill")
                        .foregroundColor(.red)
                }
                .font(.callout)
                .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 4)
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, configurations: config)

    // Item 1: Dzisiaj
    let item1 = TaskItem(
        date: Date(),
        timeTask: 25 * 60,
        timeDistractions: 120,
        timeEst: 25 * 60,
        isCompleted: true
    )
    
    // Item 2: Wczoraj
    let item2 = TaskItem(
        date: Date().addingTimeInterval(-86400),
        timeTask: 15 * 60,
        timeDistractions: 600,
        timeEst: 15 * 60,
        isCompleted: true
    )

    // Item 3: TRZY DNI TEMU (Sesja poranna)
    let item3 = TaskItem(
        date: Date().addingTimeInterval(-86400 * 3),
        timeTask: 60 * 60,
        timeDistractions: 0,
        timeEst: 60 * 60,
        isCompleted: false
    )
    let item4 = TaskItem(
        date: Date().addingTimeInterval(-86400 * 2),
        timeTask: 45 * 60,
        timeDistractions: 5*60,
        timeEst: 45 * 60,
        isCompleted: false
    )
    let item5 = TaskItem(
        date: Date().addingTimeInterval(-86400 * 4),
        timeTask: 40 * 60,
        timeDistractions: 10*60,
        timeEst: 45 * 60,
        isCompleted: true
    )
    let item6 = TaskItem(
        date: Date().addingTimeInterval(-86400 * 5),
        timeTask: 15 * 60,
        timeDistractions: 25*60,
        timeEst: 15 * 60,
        isCompleted: false
    )

    container.mainContext.insert(item1)
    container.mainContext.insert(item2)
    container.mainContext.insert(item3)
    container.mainContext.insert(item4)
    container.mainContext.insert(item5)
    container.mainContext.insert(item6)

    return HistoryView()
        .modelContainer(container)
}
