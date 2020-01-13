//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

enum SortOptions: Int {
    case firstName
    case lastName
}

class StudentController {
    
    // User/Apps/Students... returns URL or nil if path doesn't exist
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    var students: [Student] = []
    
    func filter(with trackType: TrackType, sortedBy sorter: SortOptions, completion: @escaping ([Student]) -> Void) {
        
        var updatedStudents: [Student]
        
        switch trackType {
        case .iOS:
            updatedStudents = students.filter { $0.course == "iOS" }
        case .Web:
            updatedStudents = students.filter { $0.course == "Web" }
        case .UX:
            updatedStudents = students.filter { $0.course == "UX" }
        default:
            // filter for none, or any other track type
            updatedStudents = students
        }
        
        if sorter == .firstName {
            updatedStudents = updatedStudents.sorted { $0.firstName < $1.firstName }
        } else {
            updatedStudents = updatedStudents.sorted { $0.lastName < $1.lastName }
        }
        
        completion(updatedStudents)
        
    }
    
    // Void = () // returns nothing Closurs need -> then Void or () to mean returns nothing
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        
        // background queue /  main queue
        let bgQueue = DispatchQueue(label: "studentQueue", attributes: .concurrent)
        
        // do on different queue/thread
        bgQueue.async {
            
            // access to default file manager object (Finder window)
            let fm = FileManager.default
            
            //
            guard let url = self.persistentFileURL, fm.fileExists(atPath: url.path) else {return}
            
            // takes data in url and stores in data if it does exist
            do {
                // collection of bits
                let data = try Data(contentsOf: url)
                
                // Decodes from JSON into Swift
                let decoder = JSONDecoder()
                
                // you should expect to see an array of Student objects
                let students = try decoder.decode([Student].self, from: data)
                self.students = students // decoded students from JSON = students array in this controller
                completion(students, nil) // name of closure, nil means no error
            } catch {
                print("Error loading student data \(error)")
            }
            
        }
    }
}
