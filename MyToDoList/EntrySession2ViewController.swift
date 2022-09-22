//
//  EntrySession2ViewController.swift
//  MyToDoList
//
//  Created by user185077 on 3/17/21.
//  Copyright © 2021 ASN GROUP LLC. All rights reserved.
//

import DropDown
import UIKit
import RealmSwift


class EntrySession2ViewController: UIViewController {
    
    @IBOutlet var btnClient: UIButton!
    @IBOutlet var TheView: UIView!
    
    @IBOutlet var btnTemplate: UIButton!
    @IBOutlet var TheView2: UIView!
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var notesTextField: UITextView!
    @IBOutlet var durationField: UITextField!

    var templateTitle = String()
    
    var date = Date()
    
    var clientFirstName = String()
    var clientSurname = String()
    var clientFullName = String()
    
    private let realm = try! Realm()
    public var data = [ToDoListItem]()
    
    public var tempData = [Templates]()

        
    let menu: DropDown = {
        let menu = DropDown()

        return menu
    }()
    
    let menu2: DropDown = {
        let menu2 = DropDown()

        return menu2
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = date
        
        data = realm.objects(ToDoListItem.self).sorted(byKeyPath: "item").map({ $0 })
        
        // ########## MENU CLIENTES ######### //
        
        var array = [String]()
                
        for anItem in data {
            clientFirstName = anItem["item"] as! String
            clientSurname = anItem["surname"] as! String
            let clientFullName = "\(clientFirstName) \(clientSurname)"

            array.append(clientFullName)
        }
        
        menu.dataSource = array
        menu.anchorView = TheView
        menu.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu.customCellConfiguration = {index, title, cell in
            guard let cell = cell as? ClientCell else {
                return
            }
            cell.clientImage.image = UIImage(systemName: "person.circle")
        }
        menu.selectionAction = { index, title in
            print("index \(index) and \(title)")
            self.btnClient.setTitle(title, for: .normal)
            
            self.clientFullName = title
        }
        
        
        // ########## MENU TEMPLATES ######### //

        
        tempData = realm.objects(Templates.self).sorted(byKeyPath: "tempTitle").map({ $0 })
                
        var arrayTemp = [String]()
        
        arrayTemp.append("Create New Template")
        
        for anItem in tempData {
            let arrayTitle = anItem["tempTitle"] as! String
            
            arrayTemp.append(arrayTitle)
        }
        
        menu2.dataSource = arrayTemp
        menu2.anchorView = TheView2
        menu2.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
    
        menu2.customCellConfiguration = {index, title, cell in
            guard let cell = cell as? ClientCell else {
                return
            }
            cell.clientImage.image = UIImage(systemName: "bookmark")
        }
        
        menu2.selectionAction = { index, title in
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
                self.tempData = self.realm.objects(Templates.self).filter("tempTitle = %@", title).map({ $0 })
                self.templateTitle = title

                
                self.titleField.text = self.tempData[0].tempTitle
                self.notesTextField.text = self.tempData[0].tempNotes
                self.durationField.text = self.tempData[0].tempDuration
            }
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tempData = realm.objects(Templates.self).sorted(byKeyPath: "tempTitle").map({ $0 })
                
        var arrayTemp = [String]()
        
        arrayTemp.append("Create New Template")
        
        for anItem in tempData {
            let arrayTitle = anItem["tempTitle"] as! String
            
            arrayTemp.append(arrayTitle)
        }
        
        menu2.dataSource = arrayTemp
        menu2.anchorView = TheView2
        menu2.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
    
        menu2.customCellConfiguration = {index, title, cell in
            guard let cell = cell as? ClientCell else {
                return
            }
            cell.clientImage.image = UIImage(systemName: "bookmark")
        }
        
        menu2.selectionAction = { index, title in
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
                self.tempData = self.realm.objects(Templates.self).filter("tempTitle = %@", title).map({ $0 })
                self.templateTitle = title

                
                self.titleField.text = self.tempData[0].tempTitle
                self.notesTextField.text = self.tempData[0].tempNotes
                self.durationField.text = self.tempData[0].tempDuration
            }
        }
    }

    @IBAction func didtapDone1(_ sender: UIButton){
        
        menu.show()
        
    }
    
    @IBAction func didtapDone2(_ sender: UIButton){
        
        menu2.show()
        
    }
    
    @objc func didTapSaveButton(){
        
        var stringDate = String()
        
        let clientes1 = realm.objects(ToDoListItem.self).filter("item == %@ && surname == %@", clientFirstName, clientSurname)
        
        let newSession = SessionItem()
        //let client = ToDoListItem()
        
        if(Date() >= datePicker.date){
          stringDate = "done"
        }else if(Date() <= datePicker.date){
          stringDate = "upcoming"
        }
        
        newSession.sessionName = clientFullName
        newSession.sessionTitle = titleField.text!
        newSession.sessionDate = datePicker.date
        newSession.sessionDuration = durationField.text!
        newSession.sessionNotes = notesTextField.text!
        newSession.sessionState = stringDate
            
        print("CRIOU NOVA SESSAO")
        
        try! realm.write{
            clientes1[0].sessions.append(newSession)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
}
