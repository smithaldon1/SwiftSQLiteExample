//
//  ViewController.swift
//  SQLiteTest
//
//  Created by Aldon Smith on 8/15/20.
//  Copyright © 2020 Aldon Smith. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //this method is giving the row count of table view which is
        //total number of heroes in the list
        return heroList.count
    }
    
    //this method is binding the hero name with the tableview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let hero: Hero
        hero = heroList[indexPath.row]
        cell.textLabel?.text = hero.name
        return cell
    }
    

    var db: OpaquePointer?
    var heroList = [Hero]()
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableViewHeroes: UITableView!
    @IBOutlet weak var powerTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func saveButton(_ sender: UIButton) {
        //getting values from textfields
       let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
       let powerRanking = powerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)


       //validating that values are not empty
       if(name?.isEmpty)!{
           nameTextField.layer.borderColor = UIColor.red.cgColor
           return
       }

       if(powerRanking?.isEmpty)!{
           nameTextField.layer.borderColor = UIColor.red.cgColor
           return
       }

       //creating a statement
       var stmt: OpaquePointer?

       //the insert query
       let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"

       //preparing the query
       if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("Error preparing insert: \(errmsg)...")
           return
       }

       //binding the parameters
       if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("Failure binding name: \(errmsg)...")
           return
       }

       if sqlite3_bind_int(stmt, 2, (powerRanking! as NSString).intValue) != SQLITE_OK{
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("Failure binding name: \(errmsg)...")
           return
       }

       //executing the query to insert values
       if sqlite3_step(stmt) != SQLITE_DONE {
           let errmsg = String(cString: sqlite3_errmsg(db)!)
           print("Failure inserting hero: \(errmsg)...")
           return
       }

       //emptying the textfields
       nameTextField.text=""
       powerTextField.text=""


       readValues()

       //displaying a success message
       print("Hero saved successfully!")
    }
    
    func readValues() {
        
        //empty the hero list
        heroList.removeAll()
        
        //select query
        let queryString = "SELECT * FROM Heroes"
        
        //statement pointer
        var stmt: OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing insert: \(errmsg)...")
            return
        }
        
        //traversing through the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
        
            //adding values to the list
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
        }
        
       self.tableViewHeroes.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("HeroesDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database...")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errmsg)...")
        }
    }


}

