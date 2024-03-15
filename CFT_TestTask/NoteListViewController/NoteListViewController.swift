//
//  MainViewController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NoteListViewController: UIViewController {
    
    @IBOutlet private weak var noteTableView: UITableView!
    
    private enum Constants {
        static let idValue = "00000000-0000-0000-0000-000000000000"
        static let userDefaultsStateTrue = "true"
        static let constantNoteTime = "17:40"
        static let constantNoteText = "Отредактируйте ее, чтобы сохранить или удалить!"
        static let constantNoteTitle = "Это первая заметка!"
        static let constantNoText = "Нет дополнительного текста"
        static let notesTableViewCell = "NotesTableViewCell"
        static let noteTableViewCell = "NoteTableViewCell"
        static let noteViewController = "NoteViewController"
        static let enterSymbol = "\n"
    }
    
    private var titleNotesArray = [String]()
    private var textNotesArray = [String]()
    private var currentNoteTime = [String]()
    private var notesIdArray = [UUID]()
    
    private let constantIdNote = Constants.idValue
    private let noteDataBaseManager = NoteDataBaseManager.shared
    private let constantNoteBaseManager = ConstantNoteBaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearArrays()
        addForConstantNote()
        noteDataBaseManager.loadFromBase(type: .noteList)
        noteTableView.reloadData()
    }
    
    private func clearArrays() {
        titleNotesArray.removeAll()
        textNotesArray.removeAll()
        currentNoteTime.removeAll()
        notesIdArray.removeAll()
    }
    
    private func addForConstantNote() {
        if let isUserDefaultsEmpty = constantNoteBaseManager.isUserDefaultsEmpty{
            if isUserDefaultsEmpty == Constants.userDefaultsStateTrue {
                return
            } else {
                setupConstantNote()
            }
        } else {
            setupConstantNote()
        }
    }
    
    private func setupConstantNote() {
        if let constantNoteTitle = constantNoteBaseManager.constantNoteTitle {
            titleNotesArray.append(constantNoteTitle)
            if let constantNoteText = constantNoteBaseManager.constantNoteText {
                textNotesArray.append(constantNoteText)
                if let constantCurrentTime = constantNoteBaseManager.constantCurrentTime {
                    currentNoteTime.append(constantCurrentTime)
                    notesIdArray.append(UUID(uuidString: constantIdNote)!)
                } else {
                    currentNoteTime.append(Constants.constantNoteTime)
                    notesIdArray.append(UUID(uuidString: constantIdNote)!)
                }
                
            } else {
                textNotesArray.append(Constants.constantNoText)
                currentNoteTime.append(Constants.constantNoteTime)
                notesIdArray.append(UUID(uuidString: constantIdNote)!)
            }
        } else {
            titleNotesArray.append(Constants.constantNoteTitle)
            textNotesArray.append(Constants.constantNoteText)
            currentNoteTime.append(Constants.constantNoteTime)
            notesIdArray.append(UUID(uuidString: constantIdNote)!)
        }
    }
    
    private func setupView() {
        noteTableView.dataSource = self
        noteTableView.delegate = self
        noteDataBaseManager.noteListDelegate = self
        noteTableView.register(UINib(nibName: Constants.notesTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.noteTableViewCell)
    }
    
    private func setupNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        navigationItem.title = LocalizableStrings.navigationTitle
    }
    
    private func removeElementFromArrays(row: Int) {
        textNotesArray.remove(at: row)
        titleNotesArray.remove(at: row)
        currentNoteTime.remove(at: row)
        notesIdArray.remove(at: row)
    }
    
    @objc
    private func createNewNote() {
        let noteViewController = NoteViewController(nibName: Constants.noteViewController, bundle: nil)
        navigationController?.pushViewController(noteViewController, animated: true)
    }
}

extension NoteListViewController: NoteListDelegate {
    
    func fillTitleNotesArray(title: String) {
        titleNotesArray.insert(title, at: 0)
    }
    
    func fillTextNotesArray(text: String) {
        textNotesArray.insert(text, at: 0)
    }
    
    func fillCurrentNoteTimeArray(time: String) {
        currentNoteTime.insert(time, at: 0)
    }
    
    func fillNotesIdArray(id: UUID) {
        notesIdArray.insert(id, at: 0)
    }
}

extension NoteListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteViewController = NoteViewController(nibName: Constants.noteViewController, bundle: nil)
        if notesIdArray[indexPath.row] == UUID(uuidString: Constants.idValue) {
            noteViewController.passIdForConstantNote(id: notesIdArray[indexPath.row])
            noteViewController.setFirstNoteTitle(title: titleNotesArray[indexPath.row])
            noteViewController.setFirstNoteText(text: textNotesArray[indexPath.row])
            navigationController?.pushViewController(noteViewController, animated: true)
        } else {
            noteViewController.setSelectedNoteId(id: notesIdArray[indexPath.row])
            navigationController?.pushViewController(noteViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if notesIdArray[indexPath.row] == UUID(uuidString: Constants.idValue) {
                constantNoteBaseManager.removeConstantNoteData()
            } else {
                noteDataBaseManager.removeFromDataBase(id: notesIdArray[indexPath.row])
            }
            removeElementFromArrays(row: indexPath.row)
            noteTableView.reloadData()
        }
    }
}

extension NoteListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNotesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = noteTableView.dequeueReusableCell(withIdentifier: Constants.noteTableViewCell) as? NotesTableViewCell else {
            return UITableViewCell()
        }
        if titleNotesArray[indexPath.row] == "" {
            cell.setNoteTitle(title: textNotesArray[indexPath.row].replacingOccurrences(of: Constants.enterSymbol, with: " "))
            cell.setNoteText(text: Constants.constantNoText)
        } else if textNotesArray[indexPath.row] == "" {
            cell.setNoteTitle(title: titleNotesArray[indexPath.row])
            cell.setNoteText(text: Constants.constantNoText)
        } else {
            cell.setNoteTitle(title: titleNotesArray[indexPath.row])
            cell.setNoteText(text: textNotesArray[indexPath.row].replacingOccurrences(of: Constants.enterSymbol, with: " "))
        }
        cell.setNoteTimeLabel(time: currentNoteTime[indexPath.row])
        return cell
    }
    
}
