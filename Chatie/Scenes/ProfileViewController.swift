//
//  ProfileViewController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//


import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD
import SDWebImage


/// To do:
///  - Add user data to profile /D
///  - Rounded profile images
///  - Message read indicatior
///
///
/// Issues:
///  - ViewWillAppear, User data labels not showing data after first logging

struct ChatAppUser {
//    let profileImage: String
    
    let firstName: String
    let lastName: String
    let emailAddress: String

    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

class ProfileViewController: UIViewController {
    
    var data = [ProfileViewModel]()
    
    let spinner = JGProgressHUD(style: .dark)
    
    let activitySpinner: UIActivityIndicatorView = {
       let spinner = UIActivityIndicatorView()
        spinner.style = .white
        return spinner
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .yellow
        return tableView
    }()
    
    let userDataView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
        return view
    }()
    
    let userDataStackView: UIStackView = {
       let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 4)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
        return view
    }()
    
    
    let loggedInAsLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Logged In As:"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        
        return label
    }()
    
    let personImageView: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.image = UIImage(systemName: "person")
        iv.layer.masksToBounds = true
        return iv
    }()

    let userNameLabel: UILabel = {
        let atbTitle = NSMutableAttributedString(string: "Oskar Kordaś",
                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                              NSAttributedString.Key.font : UIFont.systemFont(ofSize: 23, weight: .semibold)])
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = atbTitle
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    let emailLabel: UILabel = {
        let atbTitle = NSMutableAttributedString(string: "osk@apl.pl",
                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                              NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular)])
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = atbTitle
        label.textAlignment = .center
        label.backgroundColor = .clear
        
        return label
    }()
    
    
    let logOutButton: UIButton = {
        let atbTitle = NSMutableAttributedString(string: "Log Out",
                                          attributes: [NSAttributedString.Key.foregroundColor : UIColor.red,
                                                       NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)])
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 3
        button.backgroundColor = .systemGray6
        button.setAttributedTitle(atbTitle, for: .normal)
        button.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let imageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.layer.cornerRadius = 28
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.masksToBounds = true
        return iv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        setupNavigationBar()
        
        data.append(ProfileViewModel(viewModelType: .info, title: "Name", handler: nil))
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        getUserData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         
    }
    
    func setupNavigationBar() {
 
        let customView = UIView()
        customView.addSubview(imageView)
        imageView.addSubview(activitySpinner)
        customView.frame = CGRect(x: 0, y: 26, width: 56, height: 56)
        imageView.frame = customView.frame
        activitySpinner.frame = CGRect(x: 23, y: 23, width: 10, height: 10)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
    }
    
    func getUserData() {
        
        guard let currentUserName = UserDefaults.standard.value(forKey: "name") as? String,
              let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        print("UD values:", currentUserName, email)
        
        DispatchQueue.main.async {
            self.userNameLabel.text = currentUserName
            self.emailLabel.text = email
        }
        
        guard !AppManager.shared.isProfilePictureLoaded else { return }
        if imageView.image == nil {
            activitySpinner.startAnimating()
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/" + fileName
        
        
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            guard let me = self else { return }
            switch result {
            case .success(let url):
//                me.imageView.sd_setImage(with: url, completed: nil)
                me.getImage(for: me.imageView, from: url)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getImage(for imageView: UIImageView, from url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to download image from URL")
                return
            }
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: data)
                imageView.image = profileImage
                imageView.contentMode = .scaleAspectFit
                AppManager.shared.isProfilePictureLoaded = true
                self.activitySpinner.stopAnimating()
            }
        }).resume()
    }
    
    
    func setupView() {
        view.backgroundColor = UIColor.init(r: 50, g: 180, b: 80)
        title = "Profile"
    }
    
    func setupLayout() {
  
        view.addSubview(logOutButton)
        view.addSubview(userDataView)
        
        userDataView.addSubview(personImageView)
        userDataView.addSubview(userDataStackView)
//        userDataView.addSubview(userDataStackView)

//        personImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        userDataStackView.frame = CGRect(x: 60, y: 10, width: 250, height: 250)
//
        
        userDataStackView.addArrangedSubview(userNameLabel)
        userDataStackView.addArrangedSubview(emailLabel)
        userDataStackView.axis = .vertical
        userDataStackView.distribution = .fillEqually
        userDataStackView.spacing = 0
        
        userDataView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        userDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        userDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        userDataView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        userDataStackView.leftAnchor.constraint(equalTo: personImageView.rightAnchor, constant: 10).isActive = true
        userDataStackView.topAnchor.constraint(equalTo: userDataView.topAnchor, constant: 10).isActive = true
        userDataStackView.bottomAnchor.constraint(equalTo: userDataView.bottomAnchor, constant: -10).isActive = true
        userDataStackView.rightAnchor.constraint(equalTo: userDataView.rightAnchor, constant: -10).isActive = true
        
        personImageView.leftAnchor.constraint(equalTo: userDataView.leftAnchor, constant: 10).isActive = true
        personImageView.topAnchor.constraint(equalTo: userDataView.topAnchor, constant: 10).isActive = true
        personImageView.bottomAnchor.constraint(equalTo: userDataView.bottomAnchor, constant: -10).isActive = true
        personImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        userNameLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        logOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        logOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        logOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        logOutButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        
//        tableView.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: 20).isActive = true
//        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
//        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func logOutButtonTapped() {
        
        UserDefaults.standard.setValue(nil, forKey: "name")
        UserDefaults.standard.setValue(nil, forKey: "email")
                
        
        let actionSheet = UIAlertController(title: "Are you sure that you want to log out?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes, log me out", style: .destructive) { [weak self] _ in
            
            guard let me = self else { return }
            
            AppManager.shared.isProfilePictureLoaded = false
            
            DispatchQueue.main.async {
                me.imageView.image = nil
            }
            
            // Facebook & Google Log Out
            FBSDKLoginKit.LoginManager().logOut()
            GIDSignIn.sharedInstance().signOut()
            
            do {
                let loginController = LoginViewController()
                let loginNavController = UINavigationController(rootViewController: loginController)
                
                try FirebaseAuth.Auth.auth().signOut()
            
                loginNavController.modalPresentationStyle = .fullScreen
                me.navigationController?.present(loginNavController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    me.tabBarController?.selectedIndex = 0
                })
                print("User has been logged out properly.")
            } catch {
                print(error)
            }
            
        }
        actionSheet.addAction(action)
        present(actionSheet, animated: true, completion: nil)
    }
}
