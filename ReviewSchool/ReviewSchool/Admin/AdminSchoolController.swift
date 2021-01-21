//
//  File.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

protocol SchoolPickerViewDelegate{
    func schoolPickerViewDidFinish(school:School)
}

class AdminSchoolController:UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let disposeBag = DisposeBag()
    var schools = [School]()
    var pickerDelegate:SchoolPickerViewDelegate?
    var lazyQuery = LazyQuery<School>(collection: SchoolModel.shared.collection!, orderBy: "name")
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        getData()
    }
    
    func getData(){
        lazyQuery.getDataSync {[weak self] (newSchools, error) in
            self?.refreshControl.endRefreshing()
            if let newSchools = newSchools {
                self?.schools.append(contentsOf: newSchools)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        refeshData()
    }
    
    @objc func refeshData(){
        filter(searchText: searchBar.text ?? "")
    }
    
    func setupViews(){
        refreshControl.addTarget(self, action: #selector(refeshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] query in
                self?.filter(searchText: query)
            })
            .disposed(by: disposeBag)
    }
    
    func filter(searchText:String){
        if (searchText.trimmingCharacters(in: .whitespaces).isEmpty) {
            lazyQuery = LazyQuery<School>(collection: SchoolModel.shared.collection!, orderBy: "name")
        } else {
            lazyQuery = LazyQueryFilter<School>(collection: SchoolModel.shared.collection!, orderBy: "name", key: searchText)
        }
        schools.removeAll()
        tableView.reloadData()
        getData()
    }
}

extension AdminSchoolController:UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolCell") as! AdminSchoolCellView
        cell.setupViews(school: schools[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let picker = pickerDelegate {
            self.dismiss(animated: true, completion: nil)
            picker.schoolPickerViewDidFinish(school: schools[indexPath.row])
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SchoolViewController") as! SchoolViewController
            vc.school = schools[indexPath.row]
            vc.editingStyle = .update
            vc.doneBlock = refeshData
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > schools.count - 5 {
            getData()
        }
    }
    
    @objc func addNewSchool(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "SchoolViewController") as! SchoolViewController
        vc.editingStyle = .add
        self.present(vc, animated: true, completion: nil)
    }
}
