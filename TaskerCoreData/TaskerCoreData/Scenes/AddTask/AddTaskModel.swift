//
//  AddTaskModel.swift
//  TaskerCoreData
//
//  Created by Rdm on 21/12/2020.
//

import UIKit

enum AddTask {
    
    struct TaskModel {
        
        var title: String = ""
        var date: Date = Date()
        var time: Date = Date()
        var priority: Int16 = 0
        var subtitle: String = ""
        var colorIndex: Int16 = 0
        var taskDone: Bool = false
    
    }
    
}
