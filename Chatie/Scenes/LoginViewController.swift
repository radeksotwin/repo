//
//  LoginViewController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import Foundation
import UIKit
import AutomaticAssessmentConfiguration
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD



class SpinnerActivityController: UIViewController {
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          view.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
          view.backgroundColor = .yellow
     }
}


protocol LoginPageConfiguration {
     
     var pageState: LoginPageState { get set }
     var isAnimating: Bool { get set }
     func setLoginConfiguration()
     func setRegistrationConfiguration()
     
}

enum LoginPageState: String {
     case login = "Ready to log in"
     case registration = "Ready to register an account"
}

final class LoginViewController: UIViewController, LoginPageConfiguration, AEAssessmentSessionDelegate, GIDSignInUIDelegate {
     

     private let spinner = JGProgressHUD(style: .dark)
     
     var pageState: LoginPageState = .login
     
     private let bgView: UIView = {
          let view = UIView()
          view.translatesAutoresizingMaskIntoConstraints = false
//          view.layer.shadowRadius = 16
//          view.layer.shadowOpacity = 0.7
//          view.layer.shadowColor = UIColor.black.cgColor
//          view.layer.shadowOffset = CGSize(width: 6, height: 8)
          return view
     }()
     
     private let logoImageView: UIImageView = {
          let imageView = UIImageView()
          imageView.tintColor = .black
          imageView.contentMode = .scaleAspectFit
          imageView.image = UIImage(systemName: "message")
          imageView.layer.masksToBounds = true
          imageView.layer.cornerRadius = 17
          imageView.layer.borderWidth = 3
          imageView.layer.borderColor = UIColor.white.cgColor
          return imageView
     }()
     
     private let choosePictureButton: UIButton = {
          let button = UIButton()
          button.backgroundColor = .clear
          button.layer.cornerRadius = 17
          button.layer.masksToBounds = true
          button.addTarget(self, action: #selector(imageViewButtonTapped), for: .touchUpInside)
          return button
     }()
     
     private let containerStackView: UIStackView = {
          let stackView = UIStackView()
          stackView.translatesAutoresizingMaskIntoConstraints = false
          stackView.axis = .vertical
          stackView.spacing = 10
          stackView.distribution = .fillEqually
          return stackView
     }()
     
     private let firstNameTextField: UITextField = {
          let textField = UITextField()
          textField.backgroundColor = .clear
          textField.autocorrectionType = .no
          textField.autocapitalizationType =  .none
          textField.textColor = .white
          textField.layer.borderWidth = 3
          textField.layer.borderColor = UIColor.white.cgColor
          textField.layer.cornerRadius = 7
          textField.layer.masksToBounds = true
          textField.placeholder = "First name"
          textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
          textField.leftViewMode = .always
          return textField
     }()
     
     private let lastNameTextField: UITextField = {
          let textField = UITextField()
          textField.backgroundColor = .clear
          textField.autocorrectionType = .no
          textField.autocapitalizationType =  .none
          textField.textColor = .white
          textField.layer.borderWidth = 3
          textField.layer.borderColor = UIColor.white.cgColor
          textField.layer.cornerRadius = 7
          textField.layer.masksToBounds = true
          textField.placeholder = "Last name"
          textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
          textField.leftViewMode = .always
          return textField
     }()
     
     
     private let emailTextField: UITextField = {
          let textField = UITextField()
          textField.translatesAutoresizingMaskIntoConstraints = false
          textField.backgroundColor = .clear
          textField.autocorrectionType = .no
          textField.autocapitalizationType =  .none
          textField.textColor = .white
          textField.layer.borderWidth = 3
          textField.layer.borderColor = UIColor.white.cgColor
          textField.layer.cornerRadius = 7
          textField.layer.masksToBounds = true
          textField.placeholder = "Email address"
          textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
          textField.leftViewMode = .always
          return textField
     }()
     
     private let passwordTextField: UITextField = {
          let textField = UITextField()
          textField.translatesAutoresizingMaskIntoConstraints = false
          textField.backgroundColor = .clear
          textField.autocorrectionType = .no
          textField.autocapitalizationType =  .none
          textField.textColor = .white
          textField.isSecureTextEntry = true
          textField.layer.borderWidth = 3
          textField.layer.borderColor = UIColor.white.cgColor
          textField.layer.cornerRadius = 7
          textField.layer.masksToBounds = true
          textField.placeholder = "Password"
          textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
          textField.leftView?.backgroundColor = .blue
          textField.leftViewMode = .always
          return textField
     }()
     
     private let loginButton: UIButton = {
          let atbTitle = NSMutableAttributedString(string: "Log In",
                                                   attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)])
          let button = UIButton(type: .system)
          button.backgroundColor = .black
          button.setAttributedTitle(atbTitle, for: .normal)
          button.layer.cornerRadius = 7
          button.layer.masksToBounds = true
          button.translatesAutoresizingMaskIntoConstraints = false
          button.addTarget(self, action: #selector(handleLoginTap), for: .touchUpInside)
          return button
     }()
     
     private let registerButton: UIButton = {
          let atbTitle = NSAttributedString(string: "Register account",
                                            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                         NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)])
          
          let button = UIButton(type: .system)
          button.backgroundColor = .black
          button.setAttributedTitle(atbTitle, for: .normal)
          button.tintColor = .white
          button.layer.cornerRadius = 7
          button.layer.masksToBounds = true
          button.addTarget(self, action: #selector(handleRegisterTap), for: .touchUpInside)
          button.frame = CGRect(x: -325, y: 519, width: 325, height: 50)
          return button
     }()
     
     private let registrationInfoLabel: UILabel = {
          let label = UILabel()
          label.translatesAutoresizingMaskIntoConstraints = false
          label.text = "Don't have an account? Swipe right to register!"
          label.textColor = .black
          label.textAlignment = .center
          label.backgroundColor = .clear
          label.font = .systemFont(ofSize: 14, weight: .semibold)
          label.alpha = 1
          return label
     }()
     
     private let loginInfoLabel: UILabel = {
          let label = UILabel()
          label.text = "Have an account? Swipe left to log in!"
          label.textColor = .black
          label.textAlignment = .center
          label.backgroundColor = .clear
          label.font = .systemFont(ofSize: 14, weight: .semibold)
          label.frame = CGRect(x: 25, y: 688, width: 325.0, height: 20.0)
          label.alpha = 0
          return label
     }()
     
     private let fbLoginButton: FBLoginButton = {
          let button = FBLoginButton()
          button.permissions = ["public_profile", "email"]
          button.layer.cornerRadius = 7
          button.layer.masksToBounds = true
          return button
     }()
     
     private let googleLogInButton: GIDSignInButton = {
          let button = GIDSignInButton()
          return button
     }()
     
     private let segmentedView: UISegmentedControl = {
          let items = ["Log In", "Register"]
          let segmentedControl = UISegmentedControl(items: items)
          segmentedControl.translatesAutoresizingMaskIntoConstraints = false
          segmentedControl.selectedSegmentIndex = 0
          segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.black], for: .selected)
          segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor : UIColor.white], for: .normal)
          segmentedControl.backgroundColor = .black
          segmentedControl.selectedSegmentTintColor = .white
          segmentedControl.addTarget(self, action: #selector(segmentedControlHandling), for: .valueChanged)
          return segmentedControl
     }()
     
     
     private var loginObserver: NSObjectProtocol?
     
     private var switchCounts = 0
     
     // Gets called after loadView(), when ContentView is about to be created in memory
     override func viewDidLoad() {
          super.viewDidLoad()
          
          setupConfiguration()
          setupLayoutAndAppearance()
          setupDelegate()
          addObservers()
          
     }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          guard let udName = UserDefaults.standard.value(forKey: "name"), let email = UserDefaults.standard.value(forKey: "email") else { return }
          print("UserDefaults values: \(email), \(udName)")
          
          
     }
     
     override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          
          validateAuth()
          
     }
     
     override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          
          setupObjectsFrame()
     }
     
     deinit {
          if let observer = loginObserver {
               NotificationCenter.default.removeObserver(observer)
          }
     }
     
     
     private func addObservers() {
          loginObserver = NotificationCenter.default.addObserver(forName: Notification.Name.didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
          
               guard let me = self else {
                    return
               }
               
               me.navigationController?.dismiss(animated: true, completion: nil)
          })
     }
     
     func setupConfiguration() {
          choosePictureButton.isEnabled = false
     }
  
     func validateAuth() {
          if let token = AccessToken.current, !token.isExpired {
               //            dismiss(animated: true, completion: nil)
               //            print("current access token:", token)
          }
     }
     
     
     func setupObjectsFrame() {
          logoImageView.frame = bgView.bounds
          choosePictureButton.frame = bgView.bounds
     }
     
     
     @objc func imageViewButtonTapped() {
          presentPhotoActionSheet()
          GIDSignIn.sharedInstance().signOut()
          print("Button tapped, google user signed out")
     }
     
     @objc func handleLoginTap() {
     
          spinner.show(in: view)

          guard let email = emailTextField.text, let password = passwordTextField.text else {
               return
          }
          
          UserDefaults.standard.set(email, forKey: "email")
          
          // Firebase login
          FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, authError in
               guard let me = self else  { return }
               DispatchQueue.main.async {
                    me.spinner.dismiss(animated: true)
               }

               guard let result = authResult, authError == nil else {
                    print("Failed to sign-in!")
                    Alert.userLoginErrorAlert(on: me)
                    return
               }

               let user = result.user
               let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
               
               DatabaseManager.shared.getUsersData(for: safeEmail, completion: { result in
                    switch result {
                    case .success(let data):
                        
                         guard let userData = data as? [String: Any],
                               let firstName = userData["first_name"] as? String,
                               let lastName = userData["last_name"] as? String else {
                                    return
                               }
                        
                         UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                        
                         let udname = UserDefaults.standard.value(forKey: "name")
//                         print("\(udname) HERE")
                    case .failure(let error):
                         print("\(error)")
                    }
               })
               
               NotificationCenter.default.post(name: .didLogInNotification, object: nil)
               print("User \(user) successfully signed in!")
               me.navigationController?.dismiss(animated: true, completion: nil)
          }
     }
     
     
     @objc func handleRegisterTap() {
          let me = self
          let textFieldsArray = [firstNameTextField, lastNameTextField, emailTextField, passwordTextField]
          for tf in textFieldsArray {
               tf.resignFirstResponder()
          }
          
          spinner.show(in: view)
          
          guard let firstName = firstNameTextField.text,
                let lastName = lastNameTextField.text,
                let email = emailTextField.text,
                let password = passwordTextField.text,
                !firstName.isEmpty,
                !lastName.isEmpty,
                !email.isEmpty,
                !password.isEmpty,
                password.count >= 6 else {
                     Alert.registrationErrorAlert(on: me)
                     return
                }

         // Firebase registration
         FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
             
             guard let result = authResult, error == nil else {
                 Alert.existingEmailAlert(on: me)
                 print("Error creating an user")
                 me.spinner.dismiss(animated: true)
                 return
             }
             
               let user = result.user
               print("Created an: \(user)")
               
               let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)

               DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                         // upload image
                         guard let image = me.logoImageView.image else { return }
                         guard let data = image.pngData() else { return }

                         let filename = chatUser.profilePictureFileName

                         StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                              switch result {
                              case .success(let downloadURL):
                                   UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                   print("profile_picture_URL: \(downloadURL)")
                              case .failure(let error):
                                  print(error)
                              }
                         })
                    }
               })
              
              me.handleLoginTap()
              
              DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                  me.spinner.dismiss(animated: true)
                  me.navigationController?.dismiss(animated: true, completion: nil)
              })
          }
     }
     
     
     @objc func segmentedControlHandling(sender: UISegmentedControl) {
          let index = sender.selectedSegmentIndex
          
          switch index {
          case 0 :
               setLoginConfiguration()
          case 1 :
               setRegistrationConfiguration()
          default:
               break
          }
     }
     
     func setupLayoutAndAppearance() {
          
          title = "Login page"
          navigationController?.navigationBar.isHidden = true
          navigationController?.navigationBar.prefersLargeTitles = false
          
          segmentedView.selectedSegmentIndex = 0
          
          view.backgroundColor = UIColor.init(r: 50, g: 180, b: 80)
          view.addSubview(bgView)
          bgView.addSubview(choosePictureButton)
          bgView.addSubview(logoImageView)
          view.addSubview(firstNameTextField)
          view.addSubview(lastNameTextField)
          view.addSubview(containerStackView)
          view.addSubview(loginButton)
          view.addSubview(registerButton)
          view.addSubview(fbLoginButton)
//          view.addSubview(googleLogInButton)
//          view.addSubview(loginInfoLabel)
//          view.addSubview(registrationInfoLabel)
          view.addSubview(segmentedView)
          
          containerStackView.addArrangedSubview(emailTextField)
          containerStackView.addArrangedSubview(passwordTextField)
          
          bgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          bgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
          bgView.widthAnchor.constraint(equalToConstant: 120).isActive = true
          bgView.heightAnchor.constraint(equalTo: bgView.widthAnchor).isActive = true
          
          // MARK: Refactor
          // Consider add lastName, firstName fields to stack and refactor animation code
          containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
          containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
          containerStackView.widthAnchor.constraint(equalToConstant: 325).isActive = true
          containerStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
          
          loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
          loginButton.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 30).isActive = true
          loginButton.widthAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
          loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
          
          //FB Button position
          let xPositionValue = (view.frame.width - 325) / 2
          let yPositionValue = view.center.y.magnitude + 160
          fbLoginButton.frame = CGRect(x: xPositionValue, y: yPositionValue, width: 325, height: 50)
          
          googleLogInButton.frame = CGRect(x: xPositionValue, y: yPositionValue + 60, width: 325, height: 50)
//
//          registrationInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//          registrationInfoLabel.bottomAnchor.constraint(equalTo: segmentedView.topAnchor, constant: -10).isActive = true
//          registrationInfoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
//          registrationInfoLabel.widthAnchor.constraint(equalTo: segmentedView.widthAnchor, multiplier: 1).isActive = true
//
          segmentedView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          segmentedView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
          segmentedView.heightAnchor.constraint(equalToConstant: 35).isActive = true
          segmentedView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1).isActive = true
          
     }
     
     /// Privacy settings configuration
     func configureAssessmentSession() {
          let config = AEAssessmentConfiguration()
          let session = AEAssessmentSession(configuration: config)
          
          session.delegate = self
          config.allowsPasswordAutoFill = false
          session.begin()
     }
     
     /// Login page animation code
     var isAnimating: Bool = true
     
     func setRegistrationConfiguration() {
          
          pageState = .registration
          isAnimating = true
          segmentedView.isEnabled = false
          choosePictureButton.isEnabled = true
          logoImageView.image = UIImage(systemName: "person")
          switchCounts += 1
          
          let containerSVSpacing = containerStackView.spacing
          let halfOfContainerSVHeight = containerStackView.frame.height / 2
          let yMagnitudeOfContainerSV = containerStackView.center.y.magnitude
          let textFieldHeight = emailTextField.frame.height
          let registerButtonHeight = loginButton.frame.height
          let dynamicXPositionValue = registerButton.frame.width + (view.frame.width - registerButton.frame.width) / 2
          
          let initialYvalueForFirstNameField = yMagnitudeOfContainerSV - halfOfContainerSVHeight - textFieldHeight * 2 - containerSVSpacing * 2
          let initialYvalueForLastNameField = yMagnitudeOfContainerSV - halfOfContainerSVHeight - textFieldHeight - containerSVSpacing
          let initialYvalueForRegisterButton = yMagnitudeOfContainerSV + halfOfContainerSVHeight + registerButtonHeight + containerSVSpacing * 4
           
          if switchCounts <= 1 {
               firstNameTextField.frame = CGRect(x: -325, y: initialYvalueForFirstNameField, width: 325, height: 45)
               lastNameTextField.frame = CGRect(x: -325, y: initialYvalueForLastNameField, width: 325, height: 45)
               registerButton.frame = CGRect(x: -325, y: initialYvalueForRegisterButton, width: 325, height: 50)
          }
          
          UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
               self.logoImageView.shake()
               self.fbLoginButton.transform = CGAffineTransform(translationX: 525, y: 0)
               self.bgView.transform = CGAffineTransform(rotationAngle: 80)
               self.bgView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
               self.bgView.layer.shadowRadius = 25
               self.logoImageView.tintColor = .white
               self.firstNameTextField.transform = CGAffineTransform(translationX: dynamicXPositionValue, y: 0)
               self.view.layoutIfNeeded()
          }
          
          UIView.animate(withDuration: 0.4, delay: 0.4, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
               self.loginButton.transform = CGAffineTransform(translationX: 0, y: 60)
               self.loginInfoLabel.alpha = 1
               self.registrationInfoLabel.alpha = 0
               self.view.layoutIfNeeded()
          } completion: { _ in
               UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
                    self.lastNameTextField.transform = CGAffineTransform(translationX: dynamicXPositionValue, y: 0)
                    self.view.layoutIfNeeded()
               }
          }
          
          UIView.animate(withDuration: 0.5, delay: 1.2, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut) {
               self.loginButton.transform = CGAffineTransform(translationX: 500, y: 60)
               self.registerButton.transform = CGAffineTransform(translationX: dynamicXPositionValue, y: 0)
               self.view.layoutIfNeeded()
          } completion: { _ in
               UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
                    self.bgView.transform = CGAffineTransform(rotationAngle: 0)
                    self.bgView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.registerButton.transform = CGAffineTransform(translationX: dynamicXPositionValue, y: -55)
                    self.bgView.layer.shadowRadius = 17
                    self.segmentedView.isEnabled = true
                    self.logoImageView.tintColor = .black
                    self.view.layoutIfNeeded()
               }
          }
          isAnimating = false
     }
     
     func setLoginConfiguration() {
          
          pageState = .login
          isAnimating = true
          segmentedView.isEnabled = false
          choosePictureButton.isEnabled = false
          logoImageView.image = UIImage(systemName: "message")
          
          let centerXValue = registerButton.frame.width + (view.frame.width - passwordTextField.frame.width) / 2
          let dynamicXPositionValue = (view.frame.width - registerButton.frame.width) / 2
          let initialYvalueForFacebookButton = containerStackView.center.y.magnitude + containerStackView.frame.height/2 + passwordTextField.frame.height + registerButton.frame.height + containerStackView.spacing * 3
          
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
               self.logoImageView.shake()
               self.bgView.transform = CGAffineTransform(rotationAngle: 80)
               self.bgView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
               self.firstNameTextField.transform = CGAffineTransform(translationX: -centerXValue, y: 0)
               self.registerButton.transform = CGAffineTransform(translationX: centerXValue, y: 0)
               self.logoImageView.tintColor = .white
               self.view.layoutIfNeeded()
          }
          
          UIView.animate(withDuration: 0.4, delay: 0.4, usingSpringWithDamping: 5, initialSpringVelocity: 0.1, options: .curveEaseOut) {
               self.registerButton.transform = CGAffineTransform(translationX: -525, y: 0)
               self.loginButton.transform = CGAffineTransform(translationX: 0, y: 60)
          } completion: { _ in
               UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 5, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
                    self.loginButton.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.loginInfoLabel.alpha = 0
                    self.registrationInfoLabel.alpha = 1
                    self.view.layoutIfNeeded()
               }
          }
          
          UIView.animate(withDuration: 0.4, delay: 1.2, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
               self.lastNameTextField.transform = CGAffineTransform(translationX: -centerXValue, y: 0)
               self.view.layoutIfNeeded()
          } completion: { _ in
               UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
               }) { _ in
                    UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 5, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
                         self.bgView.transform = CGAffineTransform(rotationAngle: 60)
                         self.bgView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                         self.registerButton.transform = CGAffineTransform(translationX: 0, y: 0)
                         self.loginButton.transform = CGAffineTransform(translationX: 0, y: 0)
                         self.fbLoginButton.transform = CGAffineTransform(translationX: 0, y: 0)
                         self.logoImageView.tintColor = .black
                         self.segmentedView.isEnabled = true
                         self.view.layoutIfNeeded()
                    }
               }
          }
     }
}

extension LoginViewController: UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, LoginButtonDelegate {
     
    
     func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
          do {
               try FirebaseAuth.Auth.auth().signOut()
          } catch {
               print(error)
          }
     }
     
     func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
          
          spinner.show(in: view)
          let me = self
          
          guard let token = result?.token?.tokenString else {
               print("User failed to log in with Facebook")
               me.spinner.dismiss(animated: true)
               return
          }
          
          let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
          

          facebookRequest.start(completion: { _, result, error in
               
               guard let result = result as? [String : Any], error == nil else {
                    print("Failed to make Facebook graph request")
                    return
               }
               
               guard let firstName = result["first_name"] as? String,
                     let lastName = result["last_name"] as? String,
                     let email = result["email"] as? String,
               let picture = result["picture"] as? [String: Any],
               let data = picture["data"] as? [String : Any],
               let pictureUrl = data["url"] as? String else {
                          print("Failed to get email and name from fb result")
                          return
                     }
              
              UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
              UserDefaults.standard.set(email, forKey: "email")
              
               
               let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
               
               DatabaseManager.shared.checkIfUsersExists(for: email, completion: { exists in
                    guard !exists else {
                         print("User already exists")
                         return
                    }
                    
                    // MARK: Consider how to avoid users node override - guard/if? - FIXED
                    
                    /// Adding Facebook User personals to Firebase database
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                         if success {
                              // upload image
                              guard let url = URL(string: pictureUrl) else { return }

                              URLSession.shared.dataTask(with: url, completionHandler: { data, _ , error in
                                   guard let data = data, error == nil else {
                                        print("Failed to download Facebook profile picture")
                                        return
                                   }

                                   let filename = chatUser.profilePictureFileName

                                   StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                        switch result {
                                        case .success(let downloadURL):
                                             UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        case .failure(let error):
                                             print("Storage manager error: \(error)")
                                        }
                                   })
                              }).resume()
                         }
                         print("New app user has been added successfully!")
                    })
               })
               
               let credential = FacebookAuthProvider.credential(withAccessToken: token)
               print("Credential:", credential)
               
               FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                    guard let me = self else { return }
                    guard authResult != nil, error == nil else {
                         if let error = error {
                              print("Facebook credential login failed, MFA may be needed: \(error)")
                         }
                         return

                         DispatchQueue.main.async {
                              me.spinner.dismiss(animated: true)
                         }
                    }
                    
                    NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                    print("Successfully logged user in")
//                    print("\(result.description)")
                    me.dismiss(animated: true, completion: nil)
               })
          })
     }
     
     
     // MARK: TextFields delegate confirmation
     
     func setupDelegate() {
          firstNameTextField.delegate = self
          lastNameTextField.delegate = self
          passwordTextField.delegate = self
          emailTextField.delegate = self
          fbLoginButton.delegate = self
          GIDSignIn.sharedInstance().uiDelegate = self
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
     }
     
     // MARK: b
     
     func presentPhotoActionSheet() {
          
          let me = self
          let actionSheet = UIAlertController(title: "", message: "How would you like to choose your profile picture?", preferredStyle: .actionSheet)
          
          actionSheet.addAction(UIAlertAction(title: "Take picture", style: .default, handler: { [weak self] _ in
               me.presentCamera()
          }))
          actionSheet.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { [weak self] _ in
               me.selectPhotoFromLibrary()
          }))
          actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
          
          present(actionSheet, animated: true, completion: nil)
     }
     
     func presentCamera() {
          let imagePicker = UIImagePickerController()
          
          imagePicker.delegate = self
          imagePicker.sourceType = .camera
          imagePicker.allowsEditing = true
          present(imagePicker, animated: true, completion: nil)
     }
     
     func selectPhotoFromLibrary() {
          let imagePicker = UIImagePickerController()
          imagePicker.delegate = self
          imagePicker.sourceType = .photoLibrary
          imagePicker.allowsEditing = true
          present(imagePicker, animated: true, completion: nil)
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          picker.dismiss(animated: true, completion: nil)
          print(info)
          
          let selectedImage = info[UIImagePickerController.InfoKey.editedImage]
          logoImageView.image = selectedImage as? UIImage
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
     }
     
}
