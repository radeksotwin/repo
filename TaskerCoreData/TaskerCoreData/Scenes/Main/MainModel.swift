//
//  MainModel.swift
//  TaskerCoreData
//
//  Created by Rdm on 20/02/2021.
//

import Foundation

enum Main {
    struct Tasks {
        
        var past: [Task]
        var today: [Task]
        var tomorrow: [Task]
        var upcoming7days: [Task]
        
    }
}
