//
//  SearchResultsView.swift
//  WeatherP2
//
//  Created by Rdm on 09/11/2020.
//

import UIKit

class SearchResultsView: UIView {
    
    let homeVC = HomeViewController()
    var pickedLocationCallBack: (() -> Void)?
    
    private let cellIdentifier = "placeCell"
    
    var results: [Place] = [] {
        didSet {
            searchTableView.reloadData()
        }
    }
    
    @IBOutlet weak var navigationView: NavigationView!
    @IBOutlet weak var searchTableView: UITableView!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDelegateAndDataSource()
        searchTableView.isScrollEnabled = false
    }
    
    
    func setDelegateAndDataSource() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
}

extension SearchResultsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.backgroundColor = .clear
        cell?.textLabel?.text = results[indexPath.row].title
        cell?.textLabel?.textColor = .white
        cell?.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell?.textLabel?.textAlignment = .center
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else {return}
        pickedLocationCallBack?()
        print(results.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.layer.bounds.height
        return height
    }
}
