//
//  Day.swift
//  ProductivityTimer
//
//  Created by Bartłomiej Kuś on 24/01/2026.
//

import Foundation
import SwiftData

@Model
final class DayItem {
    // @Attribute(.primaryKey) var id: UUID
    var date: Date
    var timeTasksFull : TimeInterval
    var timeDistractionsFull : TimeInterval
    var tasks: [TaskItem]?
    
    init(
        date: Date,
        timeTasksFull: TimeInterval,
        timeDistractionsFull: TimeInterval,
        taskCompletedCount: Int,
        taskInProgressCount: Int
    ) {
        self.date = date
        self.timeTasksFull = timeTasksFull
        self.timeDistractionsFull = timeDistractionsFull
        
    }
}
