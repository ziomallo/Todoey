//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Andrzej Stojak on 22/12/2018.
//  Copyright © 2018 Andrzej Stojak. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = ["buy bike","make shop","learn to code"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//
//        tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        print("Odznaczono " + itemArray[indexPath.row])
//    }

    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action  = UIAlertAction(title: "Add Item", style: .default) { (action) in
            self.itemArray.append(textField.text!)
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

