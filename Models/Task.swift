//
//  Task.swift
//  ProductivityTimer
//
//  Created by Bartłomiej Kuś on 21/01/2026.
//

import Foundation
import SwiftData

@Model
class TaskItem {
    // @Attribute(.primaryKey) var id: UUID
    var date: Date
    var timeTask: TimeInterval //time in which task is completed
    var timeDistractions: TimeInterval //time of distractions
    var timeFull: TimeInterval // full time of task + distracions
    var timeEst: TimeInterval// estimated time to do task
    var isCompleted: Bool
    
    init(
        date: Date,
        timeTask: TimeInterval,
        timeDistractions: TimeInterval,
        timeEst: TimeInterval = 0,
        isCompleted: Bool = false
    ){
        self.date = date
        self.timeTask = timeTask
        self.timeDistractions = timeDistractions
        self.timeFull = timeTask + timeDistractions
        self.timeEst = timeEst
        self.isCompleted = isCompleted
    }
}
