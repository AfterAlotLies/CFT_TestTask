//
//  NoteViewController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet private weak var noteTextField: UITextView!
    @IBOutlet private weak var titleField: UITextField!
    
    private var selectedNoteId: UUID?
    
    private let noteDataBaseManager = NoteDataBaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteDataBaseManager.noteControllerDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = selectedNoteId?.uuidString else { return }
        noteDataBaseManager.loadFromBase(type: .note, id: id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        writeToBase()
    }
    
    func setSelectedNoteId(id: UUID) {
        selectedNoteId = id
    }
    
    private func writeToBase() {
        guard let uuid = selectedNoteId?.uuidString else {
            if titleField.text != "" {
                if let title = titleField.text {
                    noteDataBaseManager.saveToEmptyBase(title: title, text: noteTextField.text, time: getCurrentTime())
                    return
                }
                return
            } else {
                return
            }
        }
        if let title = titleField.text, title != "" {
            noteDataBaseManager.updateNote(id: uuid, title: title, text: noteTextField.text, time: getCurrentTime())
        }
    }
    
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date())
    }
}

extension NoteViewController: NoteViewControllerDelegate {
    
    func setTitle(title: String) {
        titleField.text = title
    }
    
    func setNoteText(text: String) {
        noteTextField.text = text
    }
}
