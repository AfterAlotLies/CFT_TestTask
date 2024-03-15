//
//  NoteViewController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NoteViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet private weak var noteTextField: UITextView!
    
    private enum Constants {
        static let idValue = "00000000-0000-0000-0000-000000000000"
        static let enterSymbol = "\n"
        static let dateFormat = "HH:mm"
    }
    
    private var constantNoteTitle: String?
    private var constantNoteText: String?
    private var selectedNoteId: UUID?
    private var firstEnterPressed: Bool = false
    
    private var insertableImage: UIImage?
    
    private let noteDataBaseManager = NoteDataBaseManager.shared
    private let constantNoteManager = ConstantNoteBaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = selectedNoteId?.uuidString else { return }
        if id == Constants.idValue {
            if let title = constantNoteTitle {
                setTitle(title: title)
                if let text = constantNoteText {
                    setNoteText(text: text)
                }
            }
        } else {
            noteDataBaseManager.loadFromBase(type: .note, id: id)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let id = selectedNoteId else {
            if noteTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
            } else {
                writeToBase()
                return
            }
        }
        
        if id == UUID(uuidString: Constants.idValue) {
            saveConstantNote()
            return
        }

        if noteTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            noteDataBaseManager.removeFromDataBase(id: id)
        } else {
            writeToBase()
        }
    }
    
    func setSelectedNoteId(id: UUID) {
        selectedNoteId = id
    }
    
    func passIdForConstantNote(id: UUID){
        selectedNoteId = id
    }
    
    func setFirstNoteTitle(title: String) {
        constantNoteTitle = title
    }
    
    func setFirstNoteText(text: String) {
        constantNoteText = text
    }
    
    private func setupView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        noteDataBaseManager.noteControllerDelegate = self
        noteTextField.delegate = self
        noteTextField.becomeFirstResponder()
        setupTextFieldsAccessoryView()
    }
    
    private func saveConstantNote() {
        if let text = noteTextField.text, !text.isEmpty {
            distributeTextToTitleAndBody(text: text, dataBaseType: .UserDefaults)
        }
    }
    
    private func writeToBase() {
        guard let id = selectedNoteId?.uuidString else {
            if let text = noteTextField.text, !text.isEmpty {
                distributeTextToTitleAndBody(text: text, dataBaseType: .CoreData)
            }
            return
        }
        
        if let text = noteTextField.text, !text.isEmpty {
            distributeTextToTitleAndBody(text: text, dataBaseType: .CoreData, id: id)
        }
    }
    
    private func distributeTextToTitleAndBody(text: String, dataBaseType: DataBaseType, id: String? = nil) {
        let components = text.components(separatedBy: Constants.enterSymbol)
        var title = ""
        var note = ""
        if let firstComponent = components.first {
            if !firstComponent.isEmpty {
                title = firstComponent
                if components.count > 1 {
                    note = components.dropFirst().joined(separator: Constants.enterSymbol)
                }
            } else {
                note = text
            }
        }
        
        let boldText = NSMutableAttributedString(string: title)
        boldText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location: 0, length: title.count))
        let boldTitle = boldText.string
        
        if let id = id {
            if let image = insertableImage?.pngData() {
                noteDataBaseManager.updateNote(id: id, title: boldTitle, text: note, time: getCurrentTime(), image: image)
            } else {
                noteDataBaseManager.updateNote(id: id, title: boldTitle, text: note, time: getCurrentTime())
            }
        } else {
            if dataBaseType == .CoreData {
                if let image = insertableImage?.pngData() {
                    noteDataBaseManager.saveToEmptyBase(title: boldTitle, text: note, time: getCurrentTime(), image: image)
                } else {
                    noteDataBaseManager.saveToEmptyBase(title: boldTitle, text: note, time: getCurrentTime())
                }
            } else {
                constantNoteManager.saveConstantNoteData(title: boldTitle, note: note, time: getCurrentTime())
            }
        }
    }
    
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        return dateFormatter.string(from: Date())
    }
    
    private func setupTextFieldsAccessoryView() {
        guard noteTextField.inputAccessoryView == nil else {
            return
        }
        
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false

        let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: self, action: #selector(didPressDoneButton))
        let addPhotoButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(insertPhoto))
        toolBar.items = [addPhotoButton, flexsibleSpace, closeButton]
        
        noteTextField.inputAccessoryView = toolBar
    }
    
    @objc
    private func didPressDoneButton(button: UIButton) {
        noteTextField.resignFirstResponder()
    }
    
    @objc
    private func insertPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc 
    private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        noteTextField.contentInset = contentInsets
        noteTextField.scrollIndicatorInsets = contentInsets
        if let selectedRange = noteTextField.selectedTextRange {
            noteTextField.scrollRectToVisible(noteTextField.caretRect(for: selectedRange.start), animated: true)
        }
    }
}

extension NoteViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let text = textView.text else { return }
        setAttributesToText(text: text, textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        setAttributesToText(text: text, textView: textView)
    }
    
    private func setAttributesToText(text: String, textView: UITextView) {
        let originalText = textView.attributedText
        var attachmentAttributes: [NSRange: Any] = [:]
        originalText?.enumerateAttribute(.attachment, in: NSRange(location: 0, length: originalText?.length ?? 0), options: []) { value, range, _ in
            if let value = value {
                attachmentAttributes[range] = value
            }
        }
        
        let attributedText = NSMutableAttributedString(string: text)
        let firstLineRange = (text as NSString).lineRange(for: NSRange(location: 0, length: 0))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: firstLineRange)
        
        for (range, value) in attachmentAttributes {
            attributedText.addAttribute(.attachment, value: value, range: range)
        }
        
        textView.attributedText = attributedText
    }

}

extension NoteViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let attachment = NSTextAttachment()
        attachment.image = image
        let newImageWidth = (noteTextField.bounds.size.width - 20 )
        let scale = newImageWidth/image.size.width
        let newImageHeight = image.size.height * scale
        attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
        let attString = NSAttributedString(attachment: attachment)
        noteTextField.textStorage.insert(attString, at: noteTextField.selectedRange.location)
        insertableImage = image
        picker.dismiss(animated: true, completion: nil)
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
            updatedText.append(NSAttributedString(string: Constants.enterSymbol))
            updatedText.append(attributedText)
            noteTextField.attributedText = updatedText
        } else {
            noteTextField.attributedText = attributedText
        }
    }
    
    func setImageToNoteText(image: Data?) {
        guard let imageData = image, let image = UIImage(data: imageData) else {
            return
        }
        let attachment = NSTextAttachment()
        attachment.image = image
        let newImageWidth = (noteTextField.bounds.size.width - 20)
        let scale = newImageWidth / image.size.width
        let newImageHeight = image.size.height * scale
        attachment.bounds = CGRect(x: 0, y: 0, width: newImageWidth, height: newImageHeight)

        let attachmentString = NSAttributedString(attachment: attachment)
        
        let selectedRange = noteTextField.selectedRange
        
        let attributedText = NSMutableAttributedString(attributedString: noteTextField.attributedText)
        attributedText.insert(attachmentString, at: 20)
        
        noteTextField.attributedText = attributedText
    }
}
