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
                DispatchQueue.main.async {
                    self?.reloadData(sl)
                }
            }
        }
    }
    
    func reloadData(_ data: [School]){
        self.schoolList = data
        if let allIndex = schoolList.firstIndex(where: {$0.id == "all"}) {
            schoolList.swapAt(allIndex, 0)
        }
        filter(searchText: searchBar.text ?? "")
        self.tableView.reloadData()
    }
    
    func filter(searchText:String){
        if (searchText.isEmpty) {
            self.filteredSchools = schoolList
            return
        }
        let key = searchText.lowercased()
        self.filteredSchools = schoolList.filter({$0.name.lowercased().contains(key)})
    }
}

extension SchoolPickerViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter(searchText: searchText)
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
