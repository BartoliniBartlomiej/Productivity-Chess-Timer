////
////  HistoryView.swift
////  ProductivityTimer
////
////  Created by Bartłomiej Kuś on 21/01/2026.
////
//
//import SwiftUI
//import SwiftData
//
//struct HistoryView: View {
//    // To pozwala zamknąć okno historii
//    @Environment(\.dismiss) private var dismiss
//    
//    // To automatycznie pobiera dane z bazy i sortuje je od najnowszych
//    @Query(sort: \TaskItem.date, order: .reverse) private var history: [TaskItem]
//    
//    // To pozwala usuwać elementy z bazy
//    @Environment(\.modelContext) private var context
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Nagłówek ---
//            HStack {
//                Text("History of Sessions")
//                    .font(.headline)
//                Spacer()
//                Button("Close") {
//                    dismiss()
//                }
//                .buttonStyle(.bordered)
//                .controlSize(.small)
//            }
//            .padding()
//            .background(Color(nsColor: .windowBackgroundColor))
//
//            Divider()
//
//            // --- Lista ---
//            if history.isEmpty {
//                VStack {
//                    Spacer()
//                    Image(systemName: "clock.arrow.circlepath")
//                        .font(.largeTitle)
//                        .opacity(0.3)
//                    Text("No sessions in history")
//                        .foregroundColor(.secondary)
//                        .padding(.top, 5)
//                    Spacer()
//                }
//            } else {
//                List {
//                    ForEach(history) { item in
//                        HStack {
//                            // Data po lewej
//                            VStack(alignment: .leading) {
//                                Text(item.date.formatted(date: .numeric, time: .omitted))
//                                    .font(.caption)
//                                    .bold()
//                                Text(item.date.formatted(date: .omitted, time: .shortened))
//                                    .font(.caption2)
//                                    .foregroundColor(.secondary)
//                            }
//                            .frame(width: 70, alignment: .leading)
//
//                            Divider()
//
//                            // Czasy po prawej
//                            VStack(alignment: .leading, spacing: 2) {
//                                HStack {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(.green)
//                                        .font(.caption2)
//                                    Text("Work: \(formatTime(item.timeTask))")
//                                }
//                                HStack {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .foregroundColor(.red)
//                                        .font(.caption2)
//                                    Text("Distractions: \(formatTime(item.timeDistractions))")
//                                }
//                            }
//                            .font(.system(.caption, design: .monospaced))
//                            
//                            Spacer()
//                            
//                            VStack{
//                                HStack{
//                                    Spacer()
//                                    Text("Σ \(formatTime(item.timeFull))")
//                                        .font(.caption2)
//                                        .foregroundColor(.secondary)
//                                }
//                                HStack{
//                                    Spacer()
//                                    Text("Est. \(formatTime(item.timeEst))")
//                                        .font(.caption2)
//                                        .foregroundColor(.secondary)
//                                }
//                            }
//                        }
//                        .padding(.vertical, 4)
//                        // Menu kontekstowe (prawy przycisk myszy) do usuwania
//                        .contextMenu {
//                            Button("Delete Session", role: .destructive) {
//                                deleteItem(item)
//                            }
//                        }
//                    }
//                    .onDelete(perform: deleteItems) // Obsługa swipe-to-delete
//                }
//                .listStyle(.plain) // Prosty styl listy, pasuje do małego okna
//            }
//        }
//        .frame(minWidth: 400, minHeight: 400)
//    }
//
//    // Funkcja pomocnicza do usuwania z listy
//    private func deleteItems(offsets: IndexSet) {
//        for index in offsets {
//            context.delete(history[index])
//        }
//    }
//    
//    // Funkcja pomocnicza do usuwania pojedynczego elementu (context menu)
//    private func deleteItem(_ item: TaskItem) {
//        context.delete(item)
//    }
//
//    // Pomocniczy format czasu (kopiujemy logikę, żeby widok był niezależny)
//    private func formatTime(_ time: TimeInterval) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//}
//
//
//#Preview {
//    // 1. Konfiguracja kontenera w pamięci (nie zapisuje na dysku)
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: TaskItem.self, configurations: config)
//
//    // 2. Tworzenie przykładowych danych
//    // Przykład 1: Dzisiejsza sesja (dobry wynik)
//    let item1 = TaskItem(
//        date: Date(),
//        timeTask: 25 * 60,       // 25 minut pracy
//        timeDistractions: 120 ,    // 2 minuty przerwy
//        timeEst: 25 * 60
//    )
//    
//    // Przykład 2: Wczorajsza sesja (dużo dystrakcji)
//    // .addingTimeInterval(-86400) odejmuje jeden dzień (w sekundach)
//    let item2 = TaskItem(
//        date: Date().addingTimeInterval(-86400),
//        timeTask: 15 * 60,       // 15 minut pracy
//        timeDistractions: 10 * 60, // 10 minut przerwy
//        timeEst: 15 * 60
//    )
//
//    // Przykład 3: Jakaś stara sesja
//    let item3 = TaskItem(
//        date: Date().addingTimeInterval(-86400 * 3),
//        timeTask: 45 * 60,
//        timeDistractions: 0,
//        timeEst: 45 * 60
//    )
//
//    // 3. Wstawienie danych do kontekstu
//    container.mainContext.insert(item1)
//    container.mainContext.insert(item2)
//    container.mainContext.insert(item3)
//
//    // 4. Zwrócenie widoku z wstrzykniętym kontenerem
//    return HistoryView()
//        .modelContainer(container)
//}

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
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

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
        .frame(minWidth: 400, minHeight: 450)
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
        timeTask: 45 * 60,
        timeDistractions: 0,
        timeEst: 45 * 60,
        isCompleted: false
    )

    container.mainContext.insert(item1)
    container.mainContext.insert(item2)
    container.mainContext.insert(item3)

    return HistoryView()
        .modelContainer(container)
}
