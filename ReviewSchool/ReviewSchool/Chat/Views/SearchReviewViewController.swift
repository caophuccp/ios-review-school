//
//  SearchReviewViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 22/01/2021.
//

import UIKit

class SearchReviewViewController:UIViewController {
    
    @IBOutlet weak var searchTextField: RoundTextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var reviews = [Review]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        getAllData()
    }
    
    func getAllData(){
        ReviewModel.shared.getAll() { [weak self] (reviews, error) in
            if let newReviews = reviews {
                self?.reviews.append(contentsOf: newReviews)
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    func setupViews(){
        searchTextField.backgroundColor = .white
        searchTextField.layer.cornerRadius = 10
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func reloadData(){
        search()
    }
    
    @IBAction func searchButtonOnClick(_ sender: Any) {
        search()
    }
    
    func search(){
        reviews.removeAll()
        tableView.reloadData()
        let key = searchTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if key.isEmpty {
            getAllData()
        } else {
            filter(key: key)
        }
    }
    
    func filter(key:String) {
        SchoolModel.shared.search(key: key) { [weak self] (schools, error) in
            self?.refreshControl.endRefreshing()
            if let schools = schools {
                for school in schools {
                    self?.loadReviews(schoolID: school.id)
                }
            }
        }
    }
    
    func loadReviews(schoolID:String){
        ReviewModel.shared.getAll(bySchoolID: schoolID) { [weak self] (reviews, error) in
            print(reviews?.count ?? -1)
            if let newReviews = reviews {
                self?.reviews.append(contentsOf: newReviews)
                self?.reviews.sort(by: {$0.dateCreated > $1.dateCreated})
                self?.tableView.reloadData()
            }
        }
    }
    
    func goReviewDetail(review:Review){
        let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewDetailViewController") as! ReviewDetailViewController
        
        vc.review = review
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
    }
}

extension SearchReviewViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewReviewCell") as! ReviewTableCell
        let review = reviews[indexPath.row]
        cell.setupViews(review: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let review = reviews[indexPath.row]
        goReviewDetail(review: review)
    }
}
