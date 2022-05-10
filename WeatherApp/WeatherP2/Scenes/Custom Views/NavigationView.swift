//
//  NavigationView.swift
//  WeatherP2
//
//  Created by Rdm on 15/10/2020.
//

import UIKit

@IBDesignable
class NavigationView: UIView {
    
    let homeVC = HomeViewController()
    var textFieldText: ((_ text: String) -> Void)?
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchView: SearchResultsView!
    @IBOutlet weak var navigationViewHeightConstraint: NSLayoutConstraint!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        setupTextFieldDelegate()
        setupView()
    }
    
    
    func setupView() {
        layer.masksToBounds = true
        locationLabel.text = homeVC.pickedLocation.title
        textField.backgroundColor = .white
        textField.addTarget(self, action: #selector(updateResults), for: UIControl.Event.editingChanged)
    }
    
    func setupTextFieldDelegate() {
        textField.delegate = self
    }
    
    @objc func updateResults() {
        let text = textField.text
        textFieldText?(text!)
    }
    
    func setTitle(text: String) {
        locationLabel.text = text
        textField.text?.removeAll()
        textField.text?.append(text)
    }
    
    func rollDown() {
        navigationViewHeightConstraint.constant = 155
        searchView.alpha = 1
    }
    
    func rollUp() {
        navigationViewHeightConstraint.constant = 120
        searchView.alpha = 0
    }
    
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

extension NavigationView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        searchView.results.removeAll()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rollDown()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        rollUp()
    }
}


