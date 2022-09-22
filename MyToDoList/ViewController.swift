//
//  ViewController.swift
//  MyToDoList
//
//  Created by Afraz Siddiqui on 4/28/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import RealmSwift
import FSCalendar
import UIKit

/*
 - To show list of current to do list itmes
 - To enter new to do list items
 - To show previously entered to do list item

 - Item
 - Date
 */

class SessionItem: Object {
    @objc dynamic var sessionName: String = ""
    @objc dynamic var sessionTitle: String = ""
    @objc dynamic var sessionDate: Date = Date()
    @objc dynamic var sessionNotes: String = ""
    @objc dynamic var sessionDuration: String = ""
    @objc dynamic var sessionState: String = ""
    @objc dynamic var picture: Data? = nil
    @objc dynamic var picture2: Data? = nil
    @objc dynamic var picture3: Data? = nil
    //@objc dynamic var pictures: [Data] = [Data()]
    
    let pictures = List<PictureItem>()

}

class PictureItem: Object {
    @objc dynamic var pictureNew: Data? = nil
}

class Templates: Object {
    @objc dynamic var tempTitle: String = ""
    @objc dynamic var tempDuration: String = ""
    @objc dynamic var tempNotes: String = ""
}


class ToDoListItem: Object {
    @objc dynamic var item: String = ""
    @objc dynamic var surname: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var gender: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var notes: String = ""
    
    let sessions = List<SessionItem>()
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var field: UISearchBar!

    private let realm = try! Realm()
    private var data = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = realm.objects(ToDoListItem.self).sorted(byKeyPath: "item").map({ $0 })
        
        let nib = UINib(nibName: "ClientTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "ClientTableViewCell")
        
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 90
    
        field.delegate = self
    }

    // Mark: Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientTableViewCell", for: indexPath) as! ClientTableViewCell
        
        cell.nameLabel.text = data[indexPath.row].item
        cell.surnameLabel.text = data[indexPath.row].surname
        cell.contactLabel.text = data[indexPath.row].phone
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Open the screen where we can see item info and delete
        let item = data[indexPath.row]

        guard let vc = storyboard?.instantiateViewController(identifier: "view") as? ViewViewController else {
            return
        }

        vc.item = item
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.item
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "enter") as? EntryViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = "New Client"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func refresh() {
        data = realm.objects(ToDoListItem.self).sorted(byKeyPath: "item").map({ $0 })
        table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(!searchText.isEmpty){
            data = realm.objects(ToDoListItem.self).sorted(byKeyPath: "item").filter("item BEGINSWITH %@ OR surname BEGINSWITH %@", searchText, searchText).map({ $0 })
            table.reloadData()
        }
        else{
            refresh()
        }
    }

}

class SessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table2: UITableView!
    //@IBOutlet var label4: UILabel!
    
    private let realm = try! Realm()
    private var data2 = [SessionItem]()
    
    var date = Date()

    static let dateFormatter2: DateFormatter = {
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeStyle = .short
        dateFormatter2.dateStyle = .short
        dateFormatter2.locale = .current
        return dateFormatter2
    }()
    
    var notificationToken: NotificationToken?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let dateFormatter2 = DateFormatter()
        //dateFormatter2.dateFormat = "dd-MM-YYYY"
        //let string = dateFormatter2.date(from: date)
        
        let todayStart = Calendar.current.startOfDay(for: date)
        let todayEnd: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: todayStart)!
        }()
        
        data2 = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@", [todayStart, todayEnd]).sorted(byKeyPath: "sessionDate").map({ $0 })
        
        print("Existem: \(data2.count) appointments nesta data")
        
        //let data3 = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@", [todayStart, todayEnd])

        //let string2 = dateFormatter2.string(from: data2[0].sessionDate)
        //let index = string2.index(string2.startIndex, offsetBy: 10)
        //let subString = string2.prefix(upTo: index)
        //print("A data da database: \(string2)")
        //print(string)
        
        let nib = UINib(nibName: "SessionTableViewCell", bundle: nil)
        table2.register(nib, forCellReuseIdentifier: "SessionTableViewCell")
        
        table2.delegate = self
        table2.dataSource = self
        table2.rowHeight = 75
        //print(data2.count)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddSession))
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        let todayStart = Calendar.current.startOfDay(for: date)
        let todayEnd: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: todayStart)!
        }()
        
        //data2 = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@ && sessionState != 'done'", [todayStart, todayEnd]).sorted(byKeyPath: "sessionDate").map({ $0 })
        data2 = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@", [todayStart, todayEnd]).sorted(byKeyPath: "sessionDate").map({ $0 })
                
        table2.reloadData()
    }

    // Mark: Table

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
    
    func refresh() {
        
    }
    
    @objc func didTapAddSession() {
        guard let vc = storyboard?.instantiateViewController(identifier: "enterNewSession") as? EntrySession2ViewController else {
            return
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.date = date
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

class CalendarController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    @IBOutlet var calendar: FSCalendar!

    private let realm = try! Realm()
    private var data2 = [SessionItem]()
    
    @IBOutlet var table2: UITableView!
    private var dataTable = [SessionItem]()
    
    var arrayDatas = [String]()
    
    var testDates = ["2021-04-05", "2021-04-07", "2021-04-10"]
    
    static let dateFormatter2: DateFormatter = {
        let dateFormatter2 = DateFormatter()
        dateFormatter2.timeStyle = .short
        dateFormatter2.dateStyle = .short
        dateFormatter2.locale = .current
        return dateFormatter2
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        
        //calendar.scope = .week
        calendar.scope = .month
        //calendar.appearance.weekdayTextColor = .systemRed
                
        
       // data2 = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@", [todayStart, todayEnd]).sorted(byKeyPath: "sessionDate").map({ $0 })
        data2 = realm.objects(SessionItem.self).sorted(byKeyPath: "sessionDate").map({ $0 })
        
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: todayStart)!
        }()
        
        dataTable = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@", [todayStart, todayEnd]).sorted(byKeyPath: "sessionDate").map({ $0 })

                
        print("Existem: \(data2.count) appointments nesta data")
                
        let eventFormat = DateFormatter()
        eventFormat.dateFormat = "YYYY-MM-dd"
        
        for umaData in data2{
        
            let aData = umaData.sessionDate
            let strData = eventFormat.string(from: aData)
            
            arrayDatas.append(strData)
        }
        
        print(todayStart)
        print(todayEnd)
        print(dataTable.count)
        
        let nib = UINib(nibName: "SessionTableViewCell", bundle: nil)
        table2.register(nib, forCellReuseIdentifier: "SessionTableViewCell")
        
        table2.delegate = self
        table2.dataSource = self
        table2.rowHeight = 75
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddSession))
        
        }
    
    @objc func didTapAddSession() {
        guard let vc = storyboard?.instantiateViewController(identifier: "enterNewSession") as? EntrySession2ViewController else {
            return
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.date = Date()
        navigationController?.pushViewController(vc, animated: true)
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
       
        data2 = realm.objects(SessionItem.self).sorted(byKeyPath: "sessionDate").map({ $0 })

        let eventFormat = DateFormatter()
        eventFormat.dateFormat = "YYYY-MM-dd"
        
        arrayDatas.removeAll()
        
        for umaData in data2{
        
            let aData = umaData.sessionDate
            let strData = eventFormat.string(from: aData)
            
            arrayDatas.append(strData)
        }
        
        self.calendar.reloadData()
                
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: todayStart)!
        }()

        
        dataTable = realm.objects(SessionItem.self).filter("sessionDate BETWEEN %@", [todayStart, todayEnd]).sorted(byKeyPath: "sessionDate").map({ $0 })

        
        table2.reloadData()

    }
    
    // Mark: Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.textLabel?.text = data2[indexPath.row].sessionTitle
        //cell.detailTextLabel?.text = data2[indexPath.row].sessionNotes
        //return cell
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionTableViewCell", for: indexPath) as! SessionTableViewCell
        cell.titleLabel.text = dataTable[indexPath.row].sessionName
        cell.noteLabel.text = dataTable[indexPath.row].sessionTitle
        
        cell.dateLabel.text = Self.dateFormatter2.string(from: dataTable[indexPath.row].sessionDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Open the screen where we can see item info and dleete
        let item = dataTable[indexPath.row]

        guard let vc = storyboard?.instantiateViewController(identifier: "viewSession") as? ViewSession else {
            return
        }

        vc.item = item
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.sessionTitle
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd-MM-YYYY"
        
        let eventFormat = DateFormatter()
        eventFormat.dateFormat = "YYYY-MM-dd"
        //formatter.dateFormat = "dd-MM-YYYY"
        let string = formatter.string(from: date)
        
        //print("\(string)")
        
        guard let vc = storyboard?.instantiateViewController(identifier: "sessionView") as? SessionViewController else {
            return
       }

        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = string
        vc.date = date
       navigationController?.pushViewController(vc, animated: true)
        
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let eventFormat = DateFormatter()
        eventFormat.dateFormat = "YYYY-MM-dd"

        let dateString = eventFormat.string(from: date)

        if self.arrayDatas.contains(dateString){
            return [UIColor.blue]
        }

        return [UIColor.white]
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let eventFormat = DateFormatter()
        eventFormat.dateFormat = "YYYY-MM-dd"

        let dateString = eventFormat.string(from: date)

        if self.arrayDatas.contains(dateString){
            print("olá estou aqui")
            return 1
        }

        return 0
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let eventFormat = DateFormatter()
        eventFormat.dateFormat = "YYYY-MM-dd"
        
        let dateString = eventFormat.string(from: date)
        
        cell.eventIndicator.isHidden = false
        cell.eventIndicator.color = UIColor.blue
        
        if self.arrayDatas.contains(dateString){
            cell.eventIndicator.numberOfEvents = 1
        }
    }
    
}

