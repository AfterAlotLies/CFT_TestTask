//
//  NotesTableViewCell.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

// MARK: - NotesTableViewCell
class NotesTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var noteTitleLabel: UILabel!
    @IBOutlet private weak var noteTimeLabel: UILabel!
    @IBOutlet private weak var noteTextLabel: UILabel!
    
    // MARK: - Setters for IBOutlet's
    func setNoteTitle(title: String) {
        noteTitleLabel.text = title
        noteTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    func setNoteText(text: String) {
        noteTextLabel.text = text
    }
    
    func setNoteTimeLabel(time: String) {
        noteTimeLabel.text = time
    }
    
}
