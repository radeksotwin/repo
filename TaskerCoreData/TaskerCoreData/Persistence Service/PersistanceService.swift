//
//  PersistanceService.swift
//  TaskerCoreData
//
//  Created by Rdm on 09/12/2020.
//

import CoreData

class PersistanceService {
    
    init() {}
    
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: CoreData stack
    
    static var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "TaskModel")
        container.loadPersistentStores(completionHandler: { (success, err) in
            
            if let error = err as NSError? {
                fatalError("Fatal Error: \(error), Error description: \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: CoreData managing support
    
    static func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Data succesfully saved")
            } catch {
                let nserror = error as NSError
                print("Unresolved error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func deleteObject(object: NSManagedObject) {
        let context = persistentContainer.viewContext
        context.delete(object)
        print("Object deleted succesfully")
    }
  
}
