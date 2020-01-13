//
//  MainViewController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import UIKit

class StudentsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var sortSelector: UISegmentedControl!
    @IBOutlet weak var filterSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let studentController = StudentController()
    
    private var filteredAndSortedStudents: [Student] = [] {
        // when it's set, it will run this code
        didSet{
            tableView.reloadData()
        }
    }

    // happens on main queue unless specified
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self // Connecting datasource of tableView to this VC
    
        studentController.loadFromPersistentStore { (students, error) in
            if let error = error {
                NSLog("Error: \(error)")
                return
            }
            
            // Take this block and make it run on main queue
            DispatchQueue.main.async {
                if let students = students {
                    self.filteredAndSortedStudents = students
                }
            }
        }
    }
    
    // MARK: - Action Handlers
    
    @IBAction func sort(_ sender: UISegmentedControl) {
        updateDataSource()
    }
    
    @IBAction func filter(_ sender: UISegmentedControl) {
        updateDataSource()
    }
    
    // MARK: - Private
    
    private func updateDataSource() {
        
        let filter = TrackType(rawValue: filterSelector.selectedSegmentIndex) ?? .none
        let sort = SortOptions(rawValue: sortSelector.selectedSegmentIndex) ?? .firstName
    
        studentController.filter(with: filter, sortedBy: sort) { (students) in
            self.filteredAndSortedStudents = students
        }
    }
}

extension StudentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAndSortedStudents.count // Changed from 0 to 1 and tested to see if we would just get 1 cell with Title and Detail
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        
        // Configure cell
        let aStudent = filteredAndSortedStudents[indexPath.row] // row of cell we're trying to build
        cell.textLabel?.text = aStudent.name
        cell.detailTextLabel?.text = aStudent.course
        
        return cell
    }
}
