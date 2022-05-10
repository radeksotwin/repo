//
//  NewConversationViewController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//


import Foundation
import UIKit
import JGProgressHUD

struct SearchUserResult {
    let name: String
    let email: String
}

final class NewConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let spinner = JGProgressHUD(style: .dark)
    
    public var completion: ((SearchUserResult) -> Void)?
    
    private var users = [[String: String]]()
    private var results = [SearchUserResult]()
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
       let sb = UISearchBar()
        sb.placeholder = "Search for users..."
        sb.searchTextField.tintColor = .white
        sb.backgroundColor = .systemBackground
        sb.tintColor = .black
        return sb
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        tableView.register(NewConversationCell.self, forCellReuseIdentifier: "userCell")
        tableView.backgroundColor = Color.chatieGreen
        return tableView
    }()
    
    private let noResultsLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No users found"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupDelegateAndDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! NewConversationCell
        
        let model = results[indexPath.row]
        cell.configure(with: model)
        cell.backgroundColor = Color.chatieGreen
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            guard let me = self else { return }
            me.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    private func setupView() {
        view.backgroundColor = Color.chatieGreen
        searchBar.becomeFirstResponder()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noResultsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        noResultsLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    private func setupDelegateAndDataSource() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {0
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        spinner.show(in: view)
        searchUsers(query: text)
        searchBar.resignFirstResponder()
    }
    
    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to fetch users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        spinner.dismiss(animated: true)
        
        let results: [SearchUserResult] = self.users.filter({
            guard let email = $0["email"] as? String, email != safeEmail else { return false }
            guard let name = $0["name"]?.lowercased() as? String else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let name = $0["name"], let email = $0["email"] else { return nil }
            return SearchUserResult(name: name, email: email)
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
        
    }
}
