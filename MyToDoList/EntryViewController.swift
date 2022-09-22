//
//  EntryViewController.swift
//  MyToDoList
//
//  Created by Afraz Siddiqui on 4/28/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import RealmSwift
import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBOutlet var surnameTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var notesTextField: UITextView!
    @IBOutlet var addressTextField: UITextField!

    
    @IBOutlet var datePicker: UIDatePicker!

    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.becomeFirstResponder()
        textField.delegate = self
        datePicker.setDate(Date(), animated: true)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    }

    //clears keyboard after pressing save
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func didTapSaveButton() {
        if let text = textField.text, let surname = surnameTextField.text, let phone = phoneTextField.text, let email = emailTextField.text, let gender = genderTextField.text, let address = addressTextField.text, let notes = notesTextField.text, !text.isEmpty && !gender.isEmpty {
            
            if (!email.isEmpty && isValidEmail(email)) || (email.isEmpty) {

            
            let date = datePicker.date
            
            realm.beginWrite()
            
            let newItem = ToDoListItem()
            newItem.date = date
            newItem.item = text
            newItem.surname = surname
            newItem.gender = gender
            newItem.notes = notes
            
            if(!email.isEmpty && isValidEmail(email)){
                newItem.email = email
                
            }else{
                newItem.email = "No email address"
            }
            
            if(phone.isEmpty){
                newItem.phone = "No phone number"
            }else{
                newItem.phone = phone
            }
                
            if(address.isEmpty){
                newItem.address = "No address available"
            }else{
                newItem.address = address
            }
            

                realm.add(newItem)
                try! realm.commitWrite()

                completionHandler?()
                navigationController?.popToRootViewController(animated: true)
                
            }
            
        }
        else {
            print("Add something")
        }
    }
    
    func isValidEmail (_ email:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: email)
        
    }


}
