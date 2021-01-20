//
//  File.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit
import Firebase

protocol SchoolPickerViewDelegate{
    func schoolPickerViewDidFinish(school:School)
}

class AdminSchoolController:UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var schools = [School]()
    var filteredSchools = [School]()
    var listener:ListenerRegistration?
    var lastDocument:DocumentSnapshot?
    let collection = Firestore.firestore().collection("school")
    
    var pickerDelegate:SchoolPickerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        listener = SchoolModel.shared.addSnapshotListener { [weak self](query, error) in
            if let documents = query?.documents {
                let newData = documents.compactMap({try? $0.data(as: School.self)})
                DispatchQueue.main.async {
                    self?.reloadData(newData)
                }
            }
        }
    }
    
    func setupViews(){
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    deinit {
        print("AdminSchoolController deinit")
        listener?.remove()
    }
    
    func reloadData(_ data: [School]){
        self.schools = data
        filter(searchText: searchBar.text ?? "")
        self.tableView.reloadData()
    }
    
    func filter(searchText:String){
        if (searchText.isEmpty) {
            self.filteredSchools = schools
            return
        }
        let key = searchText.lowercased()
        self.filteredSchools = schools.filter({$0.name.lowercased().contains(key)})
        tableView.reloadData()
    }
}

extension AdminSchoolController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter(searchText: "")
    }
}

extension AdminSchoolController:UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSchools.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolCell") as! AdminSchoolCellView
        cell.setupViews(school: filteredSchools[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let picker = pickerDelegate {
            self.dismiss(animated: true, completion: nil)
            picker.schoolPickerViewDidFinish(school: filteredSchools[indexPath.row])
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SchoolViewController") as! SchoolViewController
            vc.school = filteredSchools[indexPath.row]
            vc.editingStyle = .update
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "School List"
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
        ])
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "add-3"), for: .normal)
        button.addTarget(self, action: #selector(addNewSchool), for: .touchUpInside)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.6
        view.layer.shadowOffset = CGSize(width: 0 , height:3)
        return view
    }
    
    @objc func addNewSchool(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "SchoolViewController") as! SchoolViewController
        vc.editingStyle = .add
        self.present(vc, animated: true, completion: nil)
    }
}
