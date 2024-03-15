//
//  NoteManager.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit
import CoreData

class NoteDataBaseManager {
    
    weak var noteListDelegate: NoteListDelegate?
    weak var noteControllerDelegate: NoteViewControllerDelegate?
    
    static let shared = NoteDataBaseManager()
    
    private let context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
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
    
    func deleteImageFromDataBase(id: UUID, image: Data) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        let idString = id.uuidString
        
        fetchRequest.predicate = NSPredicate(format: "imageData = %@", image as CVarArg)
        
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
    
    func viewDataBase() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 1 {
                for result in results as! [NSManagedObject] {
                    print(result)
                }
            }
        } catch { print("can't output base data ") }
    }
}
