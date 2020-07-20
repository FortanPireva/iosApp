//
//  ViewController.swift
//  iosApp
//
//  Created by Fortan on 7/16/20.
//  Copyright © 2020 GrFL. All rights reserved.
//

import UIKit
import SQLite3

var db: OpaquePointer?
var noteList = [Note]()
class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textfield: UITextField!
    
    @IBOutlet weak var datepicker: UIDatePicker!
    @IBAction func buttonSave(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure ", message: " ", preferredStyle: .alert)
        
       
        
        let action1 = UIAlertAction(title: "Save", style: .default) { (action) in
            print("THIS IS ACTION 1")
           
        }
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
        let note = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let datetext=datepicker.date.description(with: Locale(identifier: "en_US"))
        
        
        //validating that values are not empty
        if(note?.isEmpty)!{
            textfield.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Notes (note,date) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, note, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 2, datetext, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        print("datetext inserted")
        
       
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        //emptying the textfields
        textfield.text=""
      
      
        datepicker.setDate(Date.init(timeIntervalSinceNow: 0), animated: true)
        
        
        //displaying a success message
        print("Herro saved successfully")
        
        readValues()
    }
    
   
    
    func readValues(){
        
        //first empty the list of notes
        noteList.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM Notes"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let note = String(cString: sqlite3_column_text(stmt, 1))
            let datetext=String(cString:sqlite3_column_text(stmt, 2))
           
            print(datetext)
            
       
            
            //adding values to list
            noteList.append(Note(id: Int(id), note: String(describing: note),date:datetext))
            
           
        }
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //the database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("notedb.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Notes (id INTEGER PRIMARY KEY AUTOINCREMENT, note TEXT, date TEXT)", nil, nil, nil) != SQLITE_OK {
            print("error")
            return
        }
        readValues()
    }
    
    @IBAction func button(_ sender: UIButton) {
        label.text=textfield.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

