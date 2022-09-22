//
//  NewTemplateViewController.swift
//  MyToDoList
//
//  Created by user185077 on 4/9/21.
//  Copyright © 2021 ASN GROUP LLC. All rights reserved.
//

import UIKit
import RealmSwift

class NewTemplateViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var durationField: UITextField!
    @IBOutlet var notesField: UITextView!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
     
    public var data = [Templates]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        data = realm.objects(Templates.self).sorted(byKeyPath: "tempTitle").map({ $0 })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))

    }
    

    @objc func didTapSaveButton(){
        
        if let title = titleField.text, let duration = durationField.text, let notes = notesField.text, !title.isEmpty && !duration.isEmpty {

            realm.beginWrite()
            
            let newTemplate = Templates()
            //let client = ToDoListItem()
            
            newTemplate.tempTitle = title
            newTemplate.tempDuration = duration
            
            if(notes.isEmpty){
                newTemplate.tempNotes = ""
            } else {
                newTemplate.tempNotes = notes
            }
                
            realm.add(newTemplate)
            try! realm.commitWrite()
            
            completionHandler?()
            navigationController?.popViewController(animated: true)
            
        }
    }

}
