//
//  NoteViewControllerDelegate.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 12.03.2024.
//

import UIKit

// MARK: - NoteViewControllerDelegate
protocol NoteViewControllerDelegate: AnyObject {
    func setTitle(title: String)
    func setNoteText(text: String)
    func setImageToNoteText(image: Data?)
}
