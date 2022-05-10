//
//  ConversationsViewController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD



// MARK: - New conversation feature fixed, messageId's, navigating to ChatViewController with newConversation logic  ->>  Fill up DatabaseManager message sending functions: 39:00 tut


class ConverastionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.cellIdentifier)
        tableView.backgroundColor = UIColor.init(r: 50, g: 180, b: 80)
        
        return tableView
    }()
    
    private let noConversationsLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No converastions yet"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupView()
        setupTableView()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        
        /// Opourtunity to call the startListeningForConversations() method from here instead of NotificationCenter posting.
        startListeningForConversations()
        
        guard let udName = UserDefaults.standard.value(forKey: "name"), let email = UserDefaults.standard.value(forKey: "email") else { return }
        print("UserDefaults values: \(email), \(udName)")
    }
    
    
    private func addObservers() {
         loginObserver = NotificationCenter.default.addObserver(forName: Notification.Name.didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
         
              guard let me = self else {
                   return
              }
              print("Observer Notification")
              me.startListeningForConversations()
         })
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("Error: Conversations array is empty")
                    return
                }
                self?.conversations = conversations
            
                DispatchQueue.main.async {
                    self?.noConversationsLabel.isHidden = true
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.noConversationsLabel.isHidden = false
                    self?.tableView.isHidden = true
                }
                print("Error fetchinig conversations: \(error)")
            }
        })
    }
    
    private func fetchConversations() {
        
//        DatabaseManager.shared.getAllConversations(for: currentUserEmail, completion: { [weak self] array in
//
//            switch array
//
//        })
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        
        cell.setupView()
        cell.configure(with: model)
        
//        tableView.reloadRows(at: [indexPath], with: .fade)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
        
            let conversationId = conversations[indexPath.row].id
            
            tableView.beginUpdates()
            
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            DatabaseManager.shared.deleteConversation(with: conversationId, completion: { [weak self] success in
                guard let me = self else { return }
                if success {
                    print("Convo deleted")
                } else {
                    print("Error deleting conversation")
                }
            })
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let atb = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.black], for: .selected)]
    
        let view = UIView()
        view.backgroundColor = .black
        
        let model = conversations[indexPath.row]
 
        openConversation(with: model)
    }
    
    func openConversation(with model: Conversation) {
        let chatVc = ChatViewController(id: model.id, with: model.otherUserEmail)
        chatVc.navigationItem.largeTitleDisplayMode = .never
        chatVc.title = model.name
        navigationController?.pushViewController(chatVc, animated: true)
    }
    
    func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
    
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        noConversationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noConversationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noConversationsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        noConversationsLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 2 / 3).isActive = true
    }
    
    func setupView() {
//        let isLoggedIn = UserDefaults.standard.bool(forKey: "Is logged in")
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
//        view.addGestureRecognizer(gestureRecognizer)
//
        title = "Chats"
        view.backgroundColor = UIColor.init(r: 50, g: 180, b: 80)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addChat))
        navigationItem.rightBarButtonItem?.tintColor = .white

//        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChat))
//        navigationController?.navigationBar.topItem?.rightBarButtonItem?.tintColor = .white
    }
    
    @objc func addChat() {
        
        let vc = NewConversationViewController()
        
        vc.completion = { [weak self] result in
            guard let me = self else { return }
            
            let currentConversations = me.conversations
            
            print(currentConversations)
            
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let chatVc = ChatViewController(id: targetConversation.id, with: targetConversation.otherUserEmail)
                chatVc.isNewConversation = false
                chatVc.title = targetConversation.name
                chatVc.navigationItem.largeTitleDisplayMode = .never
                me.navigationController?.pushViewController(chatVc, animated: true)
                print("Convo with that user already exists in array")
            } else {
                me.createNewConversation(result: result)
                print("There is no conversation with that user in main conversations array -> checking if conversation exists in targetUser node, then creating new one or opening old conversation")
            }
        }
        
        let nc = UINavigationController(rootViewController: vc)

        vc.navigationController?.navigationItem.largeTitleDisplayMode = .never
        present(nc, animated: true, completion: nil)
    }
    
    // MARK: To consider - why only Radoslaw is able to create new convo with other users
    func createNewConversation(result: SearchUserResult) {
        let name = result.name
        let email = result.email
        
        DatabaseManager.shared.isConversationExists(with: email, completion: { [weak self] result in
            
            guard let me = self else {
                return
            }
            // UPDATED
            
            switch result {
            case .success(let conversationId):
                let chatVc = ChatViewController(id: conversationId, with: email)
                chatVc.isNewConversation = false
                chatVc.title = name
                chatVc.navigationItem.largeTitleDisplayMode = .never
                me.navigationController?.pushViewController(chatVc, animated: true)
                print("Conversation already exists - pushing ChatVc")
            case .failure(_):
                let chatVc = ChatViewController(id: "", with: email)
                chatVc.isNewConversation = true
                chatVc.title = name
                chatVc.navigationItem.largeTitleDisplayMode = .never
                me.navigationController?.pushViewController(chatVc, animated: true)
                print("Creating new conversation")
            }
        })
    }
    
    @objc func viewTapped() {
        let vc = LoginViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: false, completion: nil)
    }
}

extension ConverastionsViewController {
    
    
}
