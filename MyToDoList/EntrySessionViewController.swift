//
//  EntrySessionViewController.swift
//  MyToDoList
//
//  Created by user185077 on 1/17/21.
//  Copyright © 2021 ASN GROUP LLC. All rights reserved.
//

import DropDown
import RealmSwift
import UIKit

class EntrySessionViewController: UIViewController {

    @IBOutlet var clientNameLabel: UILabel!
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var notesTextField: UITextView!
    @IBOutlet var durationField: UITextField!

    
    var clientName = String()
    var clientSurname = String()
    
   private let realm = try! Realm()
   public var completionHandler: (() -> Void)?
    
    public var data = [Templates]()
    public var tempData = [Templates]()

    
    @IBOutlet var btnTemplate: UIButton!
    @IBOutlet var TheView: UIView!
    
    var templateTitle = String()

    
    let menu: DropDown = {
        let menu = DropDown()

        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        clientNameLabel.text = "\(clientName) \(clientSurname)"
        //clientName = "Nuno"
        
        //-------- MENU DROPDOWN TEMPLATES ---------//
        
        data = realm.objects(Templates.self).sorted(byKeyPath: "tempTitle").map({ $0 })
                
        var array = [String]()
        
        array.append("Create New Template")
        
        for anItem in data {
            let arrayTitle = anItem["tempTitle"] as! String
            
            array.append(arrayTitle)
        }
        
        menu.dataSource = array
        
        menu.anchorView = TheView
        
        menu.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        
        menu.customCellConfiguration = {index, title, cell in
            guard let cell = cell as? ClientCell else {
                return
            }
            cell.clientImage.image = UIImage(systemName: "bookmark")
        }
        
        menu.selectionAction = { index, title in
            print("index \(index) and \(title)")
            
            if (index == 0){
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "CreateTemplate") as? NewTemplateViewController else {
                    return
                }

                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = "Create New Template"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            else {
                
                self.btnTemplate.setTitle(title, for: .normal)
                self.templateTitle = title
            
                self.tempData = self.realm.objects(Templates.self).filter("tempTitle = %@", title).map({ $0 })

                self.titleField.text = self.tempData[0].tempTitle
                self.notesTextField.text = self.tempData[0].tempNotes
                self.durationField.text = self.tempData[0].tempDuration
            }
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        data = realm.objects(Templates.self).sorted(byKeyPath: "tempTitle").map({ $0 })
                
        var array = [String]()
        
        array.append("Create New Template")
        
        for anItem in data {
            let arrayTitle = anItem["tempTitle"] as! String
            
            array.append(arrayTitle)
        }
        
        menu.dataSource = array
        
        menu.anchorView = TheView
        
        menu.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        
        menu.customCellConfiguration = {index, title, cell in
            guard let cell = cell as? ClientCell else {
                return
            }
            cell.clientImage.image = UIImage(systemName: "bookmark")
        }
        
        menu.selectionAction = { index, title in
            print("index \(index) and \(title)")
            
            if (index == 0){
                
                guard let vc = self.storyboard?.instantiateViewController(identifier: "CreateTemplate") as? NewTemplateViewController else {
                    return
                }

                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = "Create New Template"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            else {
                
                self.btnTemplate.setTitle(title, for: .normal)
                self.templateTitle = title
            
                self.tempData = self.realm.objects(Templates.self).filter("tempTitle = %@", title).map({ $0 })

                self.titleField.text = self.tempData[0].tempTitle
                self.notesTextField.text = self.tempData[0].tempNotes
                self.durationField.text = self.tempData[0].tempDuration
            }
        }
        
    }
    
    @IBAction func didtapDoneTemplate(_ sender: UIButton){
        
        menu.show()
        
    }

    
    @objc func didTapSaveButton() {
                
        if let title = titleField.text, let notes = notesTextField.text, let duration = durationField.text, !title.isEmpty && !notes.isEmpty {
            
            var stringDate = String()
            
            let clientes1 = realm.objects(ToDoListItem.self).filter("item == %@ && surname == %@", clientName, clientSurname)
            print("Existem: \(clientes1.count) clientes com o nome \(clientName)")
            
            let clientes = realm.objects(ToDoListItem.self)
            print("Existem: \(clientes.count) clientes no geral")
            
            let sessoes = realm.objects(SessionItem.self)
            
            print("O cliente: \(clientes1[0].item) tem \(clientes1[0].sessions.count+1) sessoes marcadas")
            
            let date = datePicker.date
            
            if(Date() >= date){
              stringDate = "done"
            }else if(Date() <= date){
              stringDate = "upcoming"
            }
            
            let newSession = SessionItem()
            //let client = ToDoListItem()
            
            newSession.sessionTitle = title
            newSession.sessionDate = date
            newSession.sessionNotes = notes
            newSession.sessionDuration = duration
            newSession.sessionName = clientNameLabel.text!
            newSession.sessionState = stringDate
                
            print("CRIOU NOVA SESSAO")
            
            try! realm.write{
                clientes1[0].sessions.append(newSession)
            }
            
            print("Existem: \(sessoes.count) sessoes no total")
            
            completionHandler?()
            navigationController?.popViewController(animated: true)
            
        }
        
    }

}
