//
//  HomeViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import UIKit

class HomeViewController:BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let avatarView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "user"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    let usernameLabel: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSize(minScale: 0.5)
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    let headerView = UIView()
    
    let user = Auth.shared.currentUser!
    let headerTitle = ["Your Review", "New Review"]
    
    var userReviews = [Review]()
    var reviews = [Review]()
    let lazyQuery = LazyQuery<Review>(collection: ReviewModel.shared.collection!, orderBy: "dateCreated", descending: true)
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        getData()
    }
    
    @objc func reloadData(_ sender:UIRefreshControl){
        lazyQuery.reset()
        reviews.removeAll()
        tableView.reloadData()
        getMoreData()
    }
    
    func setupViews(){
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        initHeaderView()
        
        usernameLabel.text = user.username
        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = 40
        avatarView.contentMode = .scaleAspectFill
        
        if let url = URL(string: user.avatar) {
            NetworkImage.shared.download(url: url) { [weak self](image) in
                DispatchQueue.main.async {
                    self?.avatarView.image = image
                }
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func initHeaderView(){
        let wellcomeLabel = UILabel()
        wellcomeLabel.text = "Wellcome"
        wellcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.backgroundColor = #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1)
        headerView.rounded(borderWidth: 4, color: #colorLiteral(red: 0, green: 0.6916311383, blue: 1, alpha: 1), cornerRadius: 30)
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView.addSubview(usernameLabel)
        headerView.addSubview(avatarView)
        headerView.addSubview(wellcomeLabel)
        
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            avatarView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30)
        ])
        
        NSLayoutConstraint.activate([
            wellcomeLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            wellcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            
            usernameLabel.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
        ])
    }
    
    func getData(){
        ReviewModel.shared.getAll(byUserID: user.uid) { [weak self](reviews, error) in
            if let reviews = reviews {
                self?.userReviews = reviews
                DispatchQueue.main.async {
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
                self?.getMoreData()
            }
        }
    }
    
    func getMoreData(){
        lazyQuery.getDataSync { [weak self](reviews, error) in
            self?.refreshControl.endRefreshing()
            if let newReviews = reviews {
                self?.reviews.append(contentsOf: newReviews)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
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

extension HomeViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return reviews.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourReviewCell") as! UserReviewTableCell
            cell.setupViews(delegate: self, dataSource: self)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewReviewCell") as! ReviewTableCell
        cell.setupViews(review: reviews[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return userReviews.isEmpty ? 0 : 280
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            headerView.translatesAutoresizingMaskIntoConstraints = false
            
            let sectionHeaderView = sectionHeader(text: "Your Review")
            sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sectionHeaderView)
            view.addSubview(headerView)
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: view.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                headerView.heightAnchor.constraint(equalToConstant: 150),
                
                sectionHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                sectionHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sectionHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                sectionHeaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            return view
        }
        return sectionHeader(text: "New Review")
    }
    
    func sectionHeader(text:String) -> UIView{
        let headerView = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.text = text
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: headerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
        ])
        
        headerView.backgroundColor = .white
        headerView.layer.masksToBounds = false
        headerView.layer.shadowColor = UIColor.gray.cgColor
        headerView.layer.shadowRadius = 4
        headerView.layer.shadowOpacity = 0.6
        headerView.layer.shadowOffset = CGSize(width: 0 , height:3)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 200 : 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let review = reviews[indexPath.row]
        goReviewDetail(review: review)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > 1 && indexPath.row > reviews.count - 5 {
            getMoreData()
        }
    }
}

extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userReviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserReviewCollectionCell", for: indexPath) as! ReviewCollectionCell
        let review  = userReviews[indexPath.row]
        cell.setupViews(review: review)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let review = reviews[indexPath.row]
        goReviewDetail(review: review)
    }
}
