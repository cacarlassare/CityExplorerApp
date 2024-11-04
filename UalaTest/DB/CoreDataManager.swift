//
//  CoreDataManager.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import CoreData


protocol CoreDataManagerDelegate: AnyObject {
    func coreDataManagerDidFailToLoad(error: CoreDataError)
}


class CoreDataManager {

    // Singleton pattern for Core Data to centralize data access and simplify context management across the app
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer

    weak var delegate: CoreDataManagerDelegate?

    private init() {
        persistentContainer = NSPersistentContainer(name: "UalaTest")
        persistentContainer.loadPersistentStores { [weak self] _, error in
            if let error = error {
                self?.delegate?.coreDataManagerDidFailToLoad(error: CoreDataError.loadFailed(error))
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.saveFailed(error)
            }
        }
    }
}
