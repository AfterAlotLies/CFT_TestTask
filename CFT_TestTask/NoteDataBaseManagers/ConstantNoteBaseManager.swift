//
//  ConstantNoteBaseManager.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 15.03.2024.
//

import UIKit

class ConstantNoteBaseManager {
    
    static let shared = ConstantNoteBaseManager()
    
    var constantNoteTitle: String? {
        return UserDefaults.standard.string(forKey: "constantNoteTitle")
    }
    
    var constantNoteText: String? {
        return UserDefaults.standard.string(forKey: "constantNoteText")
    }
    
    var constantCurrentTime: String? {
        return UserDefaults.standard.string(forKey: "constantCurrentTime")
    }
    
    var isUserDefaultsEmpty: String? {
        return UserDefaults.standard.string(forKey: "isUserDefaultsEmpty")
    }
    
    func saveConstantNoteData(title: String, note: String, time: String) {
        UserDefaults.standard.set(title, forKey: "constantNoteTitle")
        UserDefaults.standard.set(note, forKey: "constantNoteText")
        UserDefaults.standard.setValue(time, forKey: "constantCurrentTime")
        UserDefaults.standard.set("false", forKey: "isUserDefaultsEmpty")
    }
    
    func removeConstantNoteData() {
        UserDefaults.standard.removeObject(forKey: "constantNoteTitle")
        UserDefaults.standard.removeObject(forKey: "constantNoteText")
        UserDefaults.standard.removeObject(forKey: "constantCurrentTime")
        UserDefaults.standard.set("true", forKey: "isUserDefaultsEmpty")
    }
    
}
