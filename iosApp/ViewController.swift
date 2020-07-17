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
var heroList = [Savedata]()
class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textfield: UITextField!
    
    @IBAction func buttonSave(_ sender: Any) {
        
        let notes = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //validating that values are not empty
        if(notes?.isEmpty)!{
            textfield.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Heroes (name) VALUES (?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, notes, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
       
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        //emptying the textfields
        textfield.text=""
      
      
        
        //displaying a success message
        print("Herro saved successfully")
        readValues()
    }
    
   
    
    func readValues(){
        
        //first empty the list of heroes
        heroList.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM Heroes"
        
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
            let notes = String(cString: sqlite3_column_text(stmt, 1))
            
            
            //adding values to list
            heroList.append(Savedata(id: Int(id), notes: String(describing: notes)))
        }
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //the database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            print("error")
            return
        }
        readValues()
        print("Cdo gje ne rregull")
    }
    
    @IBAction func button(_ sender: UIButton) {
        label.text=textfield.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

