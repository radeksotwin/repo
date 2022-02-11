//
//  Task+CoreDataProperties.swift
//  TaskerCoreData
//
//  Created by Rdm on 17/02/2021.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var colorIndex: Int16
    @NSManaged public var date: Date
    @NSManaged public var priority: Int16
    @NSManaged public var subtitle: String
    @NSManaged public var taskDone: Bool
    @NSManaged public var time: Date
    @NSManaged public var title: String
}

extension Task : Identifiable {

}
