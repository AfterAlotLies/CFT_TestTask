//
//  MainViewController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit
import CoreData

class NoteListViewController: UIViewController {

    @IBOutlet private weak var noteTableView: UITableView!
    
    private var notesArray: [String] = ["Это первая заметка!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
    }
    
    private func setupView() {
        noteTableView.dataSource = self
        noteTableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
    }
    
    private func setupNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        navigationItem.title = "Заметки"
    }
    
    @objc
    private func createNewNote() {
        let noteViewController = NoteViewController(nibName: "NotesViewController", bundle: nil)
        navigationController?.pushViewController(noteViewController, animated: true)
    }
}

extension NoteListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = noteTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as? NotesTableViewCell else {
            return UITableViewCell()
        }
        cell.setNoteTextLabel(text: notesArray[indexPath.row])
        return cell
    }
}

