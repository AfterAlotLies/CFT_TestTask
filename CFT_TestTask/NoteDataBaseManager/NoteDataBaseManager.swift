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
    
    func saveToEmptyBase(title: String, text: String, time: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        entity.setValue(title, forKey: "titleNote")
        entity.setValue(text, forKey: "noteText")
        entity.setValue(time, forKey: "timeNote")
        entity.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
        } catch {
            print("can't save to database")
        }
    }
    
    func loadFromBase(type : OperationType, id: String? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
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
                    }
                }
            } catch {
                print("cant read from database(2)")
            }
        }
    }
    
    func updateNote(id: String, title: String, text: String, time: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
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
}
