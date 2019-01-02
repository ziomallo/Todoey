//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Andrzej Stojak on 22/12/2018.
//  Copyright © 2018 Andrzej Stojak. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("No navbar")
        }
        
        navBar.barTintColor = UIColor(hexString: selectedCategory?.color)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: UIColor(hexString: selectedCategory?.color), returnFlat: true)]
        navBar.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: selectedCategory?.color), returnFlat: true)
        
        searchBar.barTintColor = UIColor(hexString: selectedCategory?.color)
    }
    
    //MARK: - TableView datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.backgroundColor = UIColor(hexString: selectedCategory?.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count * 4))
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: cell.backgroundColor!, returnFlat: true)
        cell.tintColor = ContrastColorOf(backgroundColor: cell.backgroundColor!, returnFlat: true)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action  = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let addedItem = Item(context: self.context)
            addedItem.title = textField.text!
            addedItem.done = false
            addedItem.parentCategory = self.selectedCategory
            self.itemArray.append(addedItem)
            
            self.saveItems()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    func saveItems(doReloadTableView : Bool = true ) {
        
        do {
           try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        if doReloadTableView {
            tableView.reloadData()
        }
    }
    
    func loadItems(_ request : NSFetchRequest<Item> = Item.fetchRequest(),_ predicate : NSPredicate? = nil) {
        
        let categoryPredicate  = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error loading context \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateModel(_ indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        saveItems(doReloadTableView: false)
    }
}

//MARK: -  Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(request, predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
