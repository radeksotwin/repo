//
//  MainViewController.swift
//  Calculator+programmatic
//
//  Created by Rdm on 09/02/2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MainDisplayLogic: AnyObject {
    func displayResults(viewModel: Main.PerformOperation.ViewModel)
}

class MainViewController: UIViewController, MainDisplayLogic {
    
    var interactor: MainBusinessLogic?
    var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing)?
    
    var buttons: [[CalcButton]] = [[.clear, .negative, .cos, .divide],
                                   [.seven, .eight, .nine, .multiply],
                                   [.four, .five, .six, .subtract],
                                   [.three, .two, .one, .add], [.zero],
                                   [.pi, .equal]]
    
    let ops = ["√", "AC", "=", "-", "+", "÷", "⁺∕₋", "π"]
    let nums = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    
    let holderView = UIView()
    let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 36)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.backgroundColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObjectsLayout()
        setupArchitecure()
    }
    
    func setupObjectsLayout() {
        
        let firstSVRow = UIStackView()
        let secondSVRow = UIStackView()
        let thirdSVRow = UIStackView()
        let fourthSVRow = UIStackView()
        let fifthSVRow = UIStackView()
        let zeroButton = UIButton()
        let stackViewsArray = [firstSVRow, secondSVRow, thirdSVRow, fourthSVRow, fifthSVRow]
        let buttonsStackView = UIStackView(arrangedSubviews: stackViewsArray)
        
        view.addSubview(holderView)
        holderView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 2, bottom: 0, right: 2))
        holderView.backgroundColor = .black
        holderView.addSubview(resultLabel)
        holderView.addSubview(buttonsStackView)
        
        resultLabel.anchor(top: holderView.topAnchor, leading: holderView.leadingAnchor, bottom: buttonsStackView.topAnchor, trailing: holderView.trailingAnchor)
        
        buttonsStackView.anchor(top: nil, leading: holderView.leadingAnchor, bottom: holderView.bottomAnchor, trailing: holderView.trailingAnchor, size: CGSize(width: holderView.frame.width, height: view.frame.width / 4 * 5 + 4 * 5))
        buttonsStackView.backgroundColor = .black
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 5
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
    
        for btn in buttons[0] {
            let button = UIButton()
            firstSVRow.addArrangedSubview(button)
            button.setTitle("\(btn.rawValue)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.layer.cornerRadius = view.frame.width / 8 - 1
            button.backgroundColor = setButtonColor(btn: btn)
            button.addTarget(self, action: #selector(buttonPadTapped(_:)), for: .touchUpInside)
        }
        
        for btn in buttons[1] {
            let button = UIButton()
            secondSVRow.addArrangedSubview(button)
            button.setTitle("\(btn.rawValue)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.backgroundColor = setButtonColor(btn: btn)
            button.layer.cornerRadius = view.frame.width / 8 - 1
            button.addTarget(self, action: #selector(buttonPadTapped(_:)), for: .touchUpInside)
        }
        
        for btn in buttons[2] {
            let button = UIButton()
            thirdSVRow.addArrangedSubview(button)
            button.setTitle("\(btn.rawValue)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.backgroundColor = setButtonColor(btn: btn)
            button.layer.cornerRadius = view.frame.width / 8 - 1
            button.addTarget(self, action: #selector(buttonPadTapped(_:)), for: .touchUpInside)
        }

        for btn in buttons[3] {
            let button = UIButton()
            fourthSVRow.addArrangedSubview(button)
            button.setTitle("\(btn.rawValue)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.backgroundColor = setButtonColor(btn: btn)
            button.layer.cornerRadius = view.frame.width / 8 - 1
            button.addTarget(self, action: #selector(buttonPadTapped(_:)), for: .touchUpInside)
        }
        
        fifthSVRow.addArrangedSubview(zeroButton)
        zeroButton.translatesAutoresizingMaskIntoConstraints = false
        zeroButton.setTitle("0", for: .normal)
        zeroButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        zeroButton.titleLabel?.textAlignment = .left
        zeroButton.backgroundColor = .lightGray
        zeroButton.layer.cornerRadius = view.frame.width / 8 - 1
        zeroButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        zeroButton.addTarget(self, action: #selector(buttonPadTapped(_:)), for: .touchUpInside)
        
        
        for btn in buttons[5] {
            let button = UIButton()
            fifthSVRow.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("\(btn.rawValue)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.backgroundColor = setButtonColor(btn: btn)
            button.layer.cornerRadius = view.frame.width / 8 - 1
            button.widthAnchor.constraint(equalTo: zeroButton.widthAnchor, multiplier: 0.5).isActive = true
            button.addTarget(self, action: #selector(buttonPadTapped(_:)), for: .touchUpInside)
            button.adjustsImageWhenHighlighted = true
        }
        
        for sv in stackViewsArray {
            sv.axis = .horizontal
            sv.backgroundColor = .clear
            sv.distribution = .fillEqually
            sv.spacing = 5
            sv.translatesAutoresizingMaskIntoConstraints = false
        }
        fifthSVRow.distribution = .fill
    }
    
    @objc private func buttonPadTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.currentTitle else { return }
        
        switch buttonTitle {
        case "√", "AC", "⁺∕₋", "cos","=", "-", "+", "÷", "×","π":
            operationButtonTapped(sender)
        case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
            numberPadButtonTapped(buttonTitle: buttonTitle)
            break
        default:
            break
        }
        sender.shake()
    }
    
    func operationButtonTapped(_ sender: UIButton) {
        guard let text = sender.currentTitle else { return }
        performOperation(text: text)
        print("\(text) operation button tapped!")
    }
    
    func numberPadButtonTapped(buttonTitle: String) {
        let request = Main.PerformOperation.Request(text: buttonTitle)
        interactor?.numberPadButtonTapped(request: request)
        print("Number \(buttonTitle) tapped!")
    }

    
    func performOperation(text: String) {
        let request = Main.PerformOperation.Request(text: text)
        interactor?.performOperation(request: request)
    }
    
    func displayResults(viewModel: Main.PerformOperation.ViewModel) {
        resultLabel.text = viewModel.text
    }
    
    func setButtonColor(btn: CalcButton) -> UIColor {
        switch btn {
        case .clear, .negative, .cos:
            return .darkGray
        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero, .decimal, .percent:
            return .lightGray
            
        case .add, .subtract, .divide, .multiply, .equal:
            return .orange
        default :
            return .darkGray
        }
    }
    
    //MARK: Viper architecture setup
    
    private func setupArchitecure() {
        let viewController = self
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        let router = MainRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}

