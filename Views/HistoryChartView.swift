//
//  HistoryChartView.swift
//  ProductivityTimer
//

import SwiftUI
import Charts

struct HistoryChartView: View {
    let history: [TaskItem]
    
    // --- KONFIGURACJA WYGLĄDU (Dostosuj tutaj!) ---
    private let barWidth: MarkDimension = .fixed(20) // Grubość słupka
    private let barCornerRadius: CGFloat = 4         // Zaokrąglenie rogów
    private let showLabels: Bool = true              // Czy pokazywać liczby nad słupkami?
    // ----------------------------------------------

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last 7 days")
                .font(.headline)
                .padding(.leading, 8)
            
            if chartData.isEmpty {
                ContentUnavailableView("No data from this week", systemImage: "chart.bar")
                    .frame(height: 50)
            } else {
                Chart {
                    ForEach(chartData) { dataPoint in
                        BarMark(
                            x: .value("Day", dataPoint.date, unit: .day),
                            y: .value("Time", dataPoint.seconds),
                            width: barWidth
                        )
                        // To sprawia, że słupki są obok siebie (grupowane po typie)
                        .position(by: .value("Type", dataPoint.type.rawValue))
                        // Kolorowanie w zależności od typu
                        .foregroundStyle(dataPoint.type == .work ? colorApp1.gradient : Color.red.gradient)
                        .cornerRadius(barCornerRadius)
                        // Liczby nad słupkami
                        .annotation(position: .top, spacing: 2) {
                            if showLabels && dataPoint.seconds > 0 {
                                Text(formatMinutes(dataPoint.seconds))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "Work": colorApp1,
                    "Distractions": Color.red
                ])
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated)) // Np. "Pn", "Wt"
                    }
                }
                .chartYAxis {
                    // Używamy .stride(by: yAxisStep) żeby wymusić nasze okrągłe odstępy
                    AxisMarks(values: .stride(by: yAxisStep)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let seconds = value.as(Double.self) {
                                // Wyświetlamy minuty, np. "10m", "60m"
                                Text("\(Int(seconds / 60))m")
                            }
                        }
                    }
                }
                .frame(height: 100) // Wysokość całego wykresu
                .padding(.horizontal)
            }
        }
        .padding(.top, 4)
    }
    // MARK: - Logika Obliczeń Osi
        
    // Znajduje najwyższy słupek na wykresie
    var maxYValue: TimeInterval {
        chartData.map { $0.seconds }.max() ?? 0
    }
    
    // Inteligentnie dobiera krok osi Y (np. co 5, 10, 15 lub 30 minut)
    var yAxisStep: TimeInterval {
        let maxMinutes = maxYValue / 60
        
        if maxMinutes <= 15 {
            return 5 * 60  // Jeśli mało danych (<15 min), podziałka co 5 min
        } else if maxMinutes <= 40 {
            return 10 * 60 // Jeśli średnio (<40 min), podziałka co 10 min
        } else if maxMinutes <= 90 {
            return 20 * 60 // Podziałka co 20 min
        } else if maxMinutes <= 180 {
            return 30 * 60 // Podziałka co 30 min
        } else {
            return 60 * 60 // Jeśli bardzo dużo (>3h), podziałka co 1h (60 min)
        }
    }
    // MARK: - Przetwarzanie Danych
    
    enum ActivityType: String {
        case work = "Work"
        case distraction = "Distractions"
    }
    
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let type: ActivityType
        let seconds: TimeInterval
    }
    
    // Zamieniamy historię na płaską listę punktów danych
    var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 1. Zakres 7 dni
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) else { return [] }
        
        // 2. Filtrowanie
        let recentTasks = history.filter { $0.date >= sevenDaysAgo }
        
        // 3. Grupowanie po dniach
        let grouped = Dictionary(grouping: recentTasks) { task in
            calendar.startOfDay(for: task.date)
        }
        
        var points: [ChartDataPoint] = []
        
        // 4. Iteracja przez ostatnie 7 dni (żeby pokazać też puste dni na osi X)
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: sevenDaysAgo) {
                let tasks = grouped[dayDate] ?? []
                let workSum = tasks.reduce(0) { $0 + $1.timeTask }
                let distSum = tasks.reduce(0) { $0 + $1.timeDistractions }
                
                // Dodajemy dwa punkty dla każdego dnia (jeden dla pracy, jeden dla dystrakcji)
                // Nawet jeśli są zerowe (dla zachowania układu osi), chociaż Chart może je pominąć wizualnie
                if workSum > 0 {
                    points.append(ChartDataPoint(date: dayDate, type: .work, seconds: workSum))
                }
                if distSum > 0 {
                    points.append(ChartDataPoint(date: dayDate, type: .distraction, seconds: distSum))
                }
            }
        }
        return points
    }
    
    // Formatowanie małych etykiet (np. "25m")
    func formatMinutes(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        if m > 60 {
            return "\(m/60)h"
        }
        return "\(m)m"
    }
}
