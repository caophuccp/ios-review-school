//
//  SchoolPickerViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 17/01/2021.
//

import UIKit

protocol SchoolPickerViewDelegate{
    func schoolPickerViewDidFinish(school:School)
}

class SchoolPickerViewController:UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var schoolList = [School]()
    var filteredSchools = [School]()
    var delegate: SchoolPickerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        SchoolModel.shared.getAll {[weak self] (result, error) in
            if let sl = result {
                self?.schoolList = sl
                self?.filteredSchools = sl
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension SchoolPickerViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let key = searchText.lowercased()
        filteredSchools = schoolList.filter({$0.name.lowercased().contains(key)})
        tableView.reloadData()
    }
}

extension SchoolPickerViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSchools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UniversityCell")!
        cell.textLabel?.text = schoolList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.schoolPickerViewDidFinish(school: filteredSchools[indexPath.row])
    }
}
