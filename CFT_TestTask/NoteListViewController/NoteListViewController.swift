//
//  MainViewController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NoteListViewController: UIViewController {
    
    @IBOutlet private weak var noteTableView: UITableView!
    
    private var titleNotesArray: [String] = ["Это первая заметка!"]
    private var textNotesArray: [String] = ["Вы можете ее редактировать!"]
    private var currentNoteTime: [String] = ["17:40"]
    private var notesIdArray = [UUID]()
    
    private let noteDataBaseManager = NoteDataBaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearArrays()
        noteDataBaseManager.loadFromBase(type: .noteList)
        noteTableView.reloadData()
    }
    
    private func clearArrays() {
        titleNotesArray.removeAll()
        textNotesArray.removeAll()
        currentNoteTime.removeAll()
        notesIdArray.removeAll()
    }
    
    private func setupView() {
        noteTableView.dataSource = self
        noteTableView.delegate = self
        noteDataBaseManager.noteListDelegate = self
        noteTableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
    }
    
    private func setupNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        navigationItem.title = "Заметки"
    }
    
    @objc
    private func createNewNote() {
        let noteViewController = NoteViewController(nibName: "NoteViewController", bundle: nil)
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
        let noteViewController = NoteViewController(nibName: "NoteViewController", bundle: nil)
        noteViewController.setSelectedNoteId(id: notesIdArray[indexPath.row])
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            noteDataBaseManager.removeFromDataBase(id: notesIdArray[indexPath.row])
            textNotesArray.remove(at: indexPath.row)
            titleNotesArray.remove(at: indexPath.row)
            currentNoteTime.remove(at: indexPath.row)
            notesIdArray.remove(at: indexPath.row)
            noteTableView.reloadData()
        }
    }
}

extension NoteListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNotesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = noteTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as? NotesTableViewCell else {
            return UITableViewCell()
        }
        cell.setNoteTitle(title: titleNotesArray[indexPath.row])
        cell.setNoteText(text: textNotesArray[indexPath.row])
        cell.setNoteTimeLabel(time: currentNoteTime[indexPath.row])
        return cell
    }
    
}
