//
//  MultiTaskList.swift
//  ProductivityTimer
//
//  Created by Bartłomiej Kuś on 27/01/2026.
//

import Foundation
import SwiftData

@Model
class MultiTaskList {
    var name: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.list)
    var tasks: [TaskItem] = []
    
    var fullTimeEst: TimeInterval {
        tasks.reduce(0) { $0 + $1.timeEst }
    }
    
    var fullTimeFocus: TimeInterval {
        tasks.reduce(0) { $0 + $1.timeTask }
    }
    
    var fullTimeDistractions: TimeInterval {
        tasks.reduce(0) { $0 + $1.timeDistractions }
    }
    
    init(name: String) {
        self.name = name
    }
}

