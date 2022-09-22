//
//  SessionViewController.swift
//  MyToDoList
//
//  Created by user185077 on 1/18/21.
//  Copyright © 2021 ASN GROUP LLC. All rights reserved.
//

import RealmSwift
import UIKit

class SessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table2: UITableView!
    @IBOutlet var label1: UILabel!

    private let realm = try! Realm()
    private var data = [SessionItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].sessionTitle
        return cell
    }
    
}
