//
//  NotesTableViewCell.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var noteTextLabel: UILabel!
    
    
    func setNoteTextLabel(text: String) {
        noteTextLabel.text = text
    }
}
