//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Andrzej Stojak on 31/12/2018.
//  Copyright © 2018 Andrzej Stojak. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let navBar = navigationController?.navigationBar else {
            fatalError("No navbar")
        }

        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: navBar.barTintColor!, returnFlat: true)]
        navBar.tintColor = ContrastColorOf(backgroundColor: navBar.barTintColor!, returnFlat: true)
    }

    //MARK: - TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].color)
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Model manipulation methods
    
    func saveCategories(doReloadTableView : Bool = true) {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        if doReloadTableView {
            tableView.reloadData()
        }
    }
    
    func loadCategories(_ request : NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error loading context \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateModel(_ indexPath: IndexPath) {
        context.delete(self.categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        saveCategories(doReloadTableView: false)
    }
    
    //MARK: - Adding new category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Add new category"
        }
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat()?.hexValue()
            
            self.categoryArray.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

