//
//  NoteListDelegate.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

protocol NoteListDelegate: AnyObject {
    ///This protocol is usign for fill arrays to NoteListController
    func fillTextNotesArray(text: String)
    func fillCurrentNoteTimeArray(time: String)
    func fillTitleNotesArray(title: String)
    func fillNotesIdArray(id: UUID)
}
