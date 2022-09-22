//
//  ViewViewController.swift
//  MyToDoList
//
//  Created by Afraz Siddiqui on 4/28/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import RealmSwift
import UIKit

class ViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table2: UITableView!
    
    public var item: ToDoListItem?
    public var deletionHandler: (() -> Void)?

    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var mySwitch: UISwitch!
    
//    @IBOutlet var firstSessionLabel: UILabel!
//    @IBOutlet var NotesSessionLabel: UILabel!
//    @IBOutlet var DateSessionLabel: UILabel!
    
    private let realm = try! Realm()
    private var data2 = [SessionItem]()

    
    var fullname = ""
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    static let dateFormatter2: DateFormatter = {
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeStyle = .short
        dateFormatter2.dateStyle = .short
        dateFormatter2.locale = .current
        return dateFormatter2
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SessionTableViewCell", bundle: nil)
        table2.register(nib, forCellReuseIdentifier: "SessionTableViewCell")
        
        table2.delegate = self
        table2.dataSource = self
        table2.rowHeight = 75
        
        //table2.backgroundColor = .lightGray
        
        fullname = "\(item!.item) \(item!.surname)"
        
        itemLabel.text = fullname
        
        data2 = realm.objects(SessionItem.self).filter("sessionName CONTAINS %@ AND sessionState = 'upcoming'", fullname).sorted(byKeyPath: "sessionDate").map({ $0 })
        
        //emailLabel.text = "Email: \(item!.email)"
        emailLabel.text = item!.email
        genderLabel.text = "- \(item!.gender)"
        
        addressLabel.text = item!.address
        notesLabel.text = item!.notes
        
        phoneLabel.text = item!.phone
        dateLabel.text = Self.dateFormatter.string(from: item!.date)
        
//        if(item!.sessions.count > 0 ) {
//            firstSessionLabel.text = item?.sessions.first?.sessionTitle
//            NotesSessionLabel.text = item?.sessions.first?.sessionNotes
//            DateSessionLabel.text = Self.dateFormatter2.string(from: item!.sessions.first!.sessionDate)
//        }else {
//            firstSessionLabel.text = "No Appointment Title"
//            NotesSessionLabel.text = "No Appointment Notes"
//            DateSessionLabel.text = "No Appointment Date"
//        }\

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddSession))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
        
        navigationItem.rightBarButtonItems = [delete, add]
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch){
        if sender.isOn{
            
            data2 = realm.objects(SessionItem.self).filter("sessionName CONTAINS %@ AND sessionState = 'upcoming'", fullname).sorted(byKeyPath: "sessionDate").map({ $0 })
            
            table2.reloadData()
            
        }
        else{
            
            data2 = realm.objects(SessionItem.self).filter("sessionName CONTAINS %@ AND sessionState = 'done'", fullname).sorted(byKeyPath: "sessionDate").map({ $0 })
            
            table2.reloadData()

            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data2.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.textLabel?.text = data2[indexPath.row].sessionTitle
        //cell.detailTextLabel?.text = data2[indexPath.row].sessionNotes
        //return cell
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionTableViewCell", for: indexPath) as! SessionTableViewCell
        cell.titleLabel.text = data2[indexPath.row].sessionName
        cell.noteLabel.text = data2[indexPath.row].sessionTitle
        
        cell.dateLabel.text = Self.dateFormatter2.string(from: data2[indexPath.row].sessionDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Open the screen where we can see item info and dleete
        let item = data2[indexPath.row]

        guard let vc = storyboard?.instantiateViewController(identifier: "viewSession") as? ViewSession else {
            return
        }

        vc.item = item
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.sessionTitle
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }

        let alert = UIAlertController(title: "Are you sure you want to delete this client?", message: "This cannot be reverted.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {  action in
            
            self.realm.beginWrite()
            self.realm.delete(myItem)
            try! self.realm.commitWrite()

            self.deletionHandler?()
            self.navigationController?.popToRootViewController(animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    @objc private func didTapAddSession() {
        
        guard let vcc = storyboard?.instantiateViewController(identifier: "enterSession") as? EntrySessionViewController else { return }
                
        //let nome = itemLabel.text!
        //let index = nome.index(nome.endIndex, offsetBy: -5)
        //let nomeFinal = nome.suffix(from: index)
        
        vcc.title = "New Appointment"
        vcc.clientName = item!.item
        vcc.clientSurname = item!.surname
        vcc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vcc, animated: true)
        
    }


}
