//
//  NoteViewController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet private weak var noteTextField: UITextView!
    
    private var selectedNoteId: UUID?
    private let noteDataBaseManager = NoteDataBaseManager()
    private var firstEnterPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = selectedNoteId?.uuidString else { return }
        noteDataBaseManager.loadFromBase(type: .note, id: id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let id = selectedNoteId else {
            writeToBase()
            return
        }
        if noteTextField.text == "" {
            noteDataBaseManager.removeFromDataBase(id: id)
        } else {
            writeToBase()
        }
    }
    
    func setSelectedNoteId(id: UUID) {
        selectedNoteId = id
    }
    
    private func setupView() {
        noteDataBaseManager.noteControllerDelegate = self
        noteTextField.delegate = self
        noteTextField.becomeFirstResponder()
    }
    
    private func writeToBase() {
        guard let id = selectedNoteId?.uuidString else {
            if let text = noteTextField.text, !text.isEmpty {
                let components = text.components(separatedBy: "\n")
                var title = ""
                var note = ""
                if let firstComponent = components.first {
                    if !firstComponent.isEmpty {
                        title = firstComponent
                        if components.count > 1 {
                            note = components.dropFirst().joined(separator: "\n")
                        }
                    } else {
                        note = text
                    }
                }
                
                let boldText = NSMutableAttributedString(string: title)
                boldText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location: 0, length: title.count))
                let boldTitle = boldText.string
                noteDataBaseManager.saveToEmptyBase(title: boldTitle, text: note, time: getCurrentTime())
            }
            return
        }
        
        if let text = noteTextField.text, !text.isEmpty {
            let components = text.components(separatedBy: "\n")
            var title = ""
            var note = ""
            if let firstComponent = components.first {
                if !firstComponent.isEmpty {
                    title = firstComponent
                    if components.count > 1 {
                        note = components.dropFirst().joined(separator: "\n")
                    }
                } else {
                    note = text
                }
            }
            
            let boldText = NSMutableAttributedString(string: title)
            boldText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location: 0, length: title.count))
            let boldTitle = boldText.string
            noteDataBaseManager.updateNote(id: id, title: boldTitle, text: note, time: getCurrentTime())
        }
    }
    
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date())
    }
}

extension NoteViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let text = textView.text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        let firstLineRange = (text as NSString).lineRange(for: NSRange(location: 0, length: 0))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: firstLineRange)
        
        textView.attributedText = attributedText
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        let firstLineRange = (text as NSString).lineRange(for: NSRange(location: 0, length: 0))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: firstLineRange)
        
        textView.attributedText = attributedText
    }
}

extension NoteViewController: NoteViewControllerDelegate {
    
    func setTitle(title: String) {
        noteTextField.text = title
    }
    
    func setNoteText(text: String) {
        let attributedText = NSMutableAttributedString(string: text)
        let firstLineRange = (text as NSString).lineRange(for: NSRange(location: 0, length: 0))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: firstLineRange)
        
        if let existingText = noteTextField.attributedText {
            let updatedText = NSMutableAttributedString(attributedString: existingText)
            updatedText.append(NSAttributedString(string: "\n"))
            updatedText.append(attributedText)
            noteTextField.attributedText = updatedText
        } else {
            noteTextField.attributedText = attributedText
        }
    }
}
