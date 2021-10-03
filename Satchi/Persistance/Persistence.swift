//
//  Persistence.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let testImage = UIImage(named: "SVTTestImage")?.pngData()
        for number in 0..<2 {
            let newTrack = Track(context: viewContext)
            newTrack.id = UUID()
            newTrack.name = "Trc \(number)"
            newTrack.length = Int32(number * 500)
            newTrack.created = Date(timeIntervalSinceNow: TimeInterval(-60*60*24+3))
            newTrack.difficulty = 4
            newTrack.image = testImage
        }
        for number in 2..<6 {
            let newTrack = Track(context: viewContext)
            newTrack.id = UUID()
            newTrack.name = "Trc \(number)"
            newTrack.length = Int32(number * 500)
            var createdTimeInterval = DateComponents(day: number)
            newTrack.created = Calendar.current.date(byAdding: createdTimeInterval, to: Date())
            var finishedTimeInterval = DateComponents(day: number+1)
            newTrack.started = Calendar.current.date(byAdding: finishedTimeInterval, to: Date())
            newTrack.timeToFinish = (35+Double(number))*60
            newTrack.difficulty = 5
            newTrack.image = testImage
        }

        var timeInterval = DateComponents(day: 2)

        let newTrack = Track(context: viewContext)
        newTrack.id = UUID()
        newTrack.name = "Stensö"
        newTrack.length = 5000
        newTrack.created = Date()
        newTrack.difficulty = 4
        newTrack.started = Calendar.current.date(byAdding: timeInterval, to: Date())
        newTrack.timeToFinish = 68 * 60
        newTrack.image = testImage

        let newTrack2 = Track(context: viewContext)
        newTrack2.id = UUID()
        newTrack2.name = "Udden"
        newTrack2.length = 5400
        newTrack2.created = Date()
        newTrack.difficulty = 2
        newTrack2.started = Calendar.current.date(byAdding: timeInterval, to: Date())
        newTrack.timeToFinish = 98*60
        newTrack.image = testImage

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Satchi")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible,
                 * due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func deleteAllTracks(inContext context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in Track error :", error)
        }

    }

}
