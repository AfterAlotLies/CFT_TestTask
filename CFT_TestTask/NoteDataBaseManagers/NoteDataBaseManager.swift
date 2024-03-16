//
//  NoteManager.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit
import CoreData

// MARK: - NoteDataBaseManager
class NoteDataBaseManager {
    
    weak var noteListDelegate: NoteListDelegate?
    weak var noteControllerDelegate: NoteViewControllerDelegate?
    
    static let shared = NoteDataBaseManager()
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init()
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Save data to empty Core Data
    func saveToEmptyBase(title: String, text: String, time: String, image: Data? = nil) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        entity.setValue(title, forKey: "titleNote")
        entity.setValue(text, forKey: "noteText")
        entity.setValue(time, forKey: "timeNote")
        entity.setValue(UUID(), forKey: "id")
        if let image = image {
            entity.setValue(image, forKey: "imageData")
        }
        
        do {
            try context.save()
        } catch {
            print("can't save to database")
        }
    }
    
    // MARK: - Get data from Core Data
    func loadFromBase(type : OperationType, id: String? = nil) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        switch type {
            
        case .noteList:
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    print("base is empty")
                }
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "titleNote") as? String {
                        noteListDelegate?.fillTitleNotesArray(title: title)
                    }
                    if let text = result.value(forKey: "noteText") as? String {
                        noteListDelegate?.fillTextNotesArray(text: text)
                    }
                    if let time = result.value(forKey: "timeNote") as? String {
                        noteListDelegate?.fillCurrentNoteTimeArray(time: time)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        noteListDelegate?.fillNotesIdArray(id: id)
                    }
                    if let image = result.value(forKey: "imageData") as? Data {
                        noteListDelegate?.fillImagesDataArray(image: image)
                    }
                }
            } catch {
                print("cant read from database")
            }
            
        case .note :
            fetchRequest.predicate = NSPredicate(format: "id = %@", id!)
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "titleNote") as? String {
                            noteControllerDelegate?.setTitle(title: title)
                        }
                        if let text = result.value(forKey: "noteText") as? String {
                            noteControllerDelegate?.setNoteText(text: text)
                        }
                        if let image = result.value(forKey: "imageData") as? Data {
                            noteControllerDelegate?.setImageToNoteText(image: image)
                        }
                    }
                }
            } catch {
                print("cant read from database(2)")
            }
        }
    }
    
    // MARK: - Update data in Core Data
    func updateNote(id: String, title: String, text: String, time: String, image: Data? = nil) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    result.setValue(title, forKey: "titleNote")
                    result.setValue(text, forKey: "noteText")
                    result.setValue(time, forKey: "timeNote")
                    if let image = image {
                        result.setValue(image, forKey: "imageData")
                    }
                    
                    do {
                        try context.save()
                    } catch {
                        print("cant update item 1")
                    }
                }
            }
        } catch {
            print("cant update item 2")
        }
    }
    
    // MARK: - Delete data from Core Data
    func removeFromDataBase(id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        let idString = id.uuidString
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let deletingId = result.value(forKey: "id") as? UUID {
                        if deletingId == id {
                            context.delete(result)
                            
                            do {
                                try context.save()
                            } catch {
                                print("can't 2")
                            }
                        }
                    }
                }
            }
        } catch {
            print("can't 1")
        }
    }
    
    // MARK: - Delete imageData from Core Data
    func deleteImageFromDataBase(id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        let idString = id.uuidString
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let _ = result.value(forKey: "imageData") as? Data {
                    result.setValue(nil, forKey: "imageData")
                    try context.save()
                }
            }
        } catch {
            print("Error deleting image from database: \(error)")
        }
    }
}
