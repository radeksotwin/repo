//
//  AddTaskViewController.swift
//  TaskerCoreData
//
//  Created by Rdm on 26/11/2020.
//

import UIKit
//import QuartzCore

protocol AddTaskDataStore {
    var taskToSave: Task! { get set }
    var taskModel: AddTask.TaskModel! { get set }
}

class AddTaskViewController: UIViewController {

    // MARK: To do - Add empty placeholder alert, refresh mainTableView after saving task and dismiss editVC
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var datePickerStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var dateStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timePickerStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var timeStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var priorityStackView: UIStackView!
    @IBOutlet weak var priorityStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var firstSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thridSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthSpacingConstraint: NSLayoutConstraint!
    
    var taskModel = AddTask.TaskModel()
    var taskToSave: Task?
    var markedIndexPath = IndexPath(row: 0, section: 0)
    
    var reloadTableViewCallBack: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegateAndDataSource()
        setupLayout()
        setObservers()
        holdTaskContent()
        print("View succesfully loaded")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(taskToSave)
        print("View appeared")
    }
    
    deinit {
        print("🔥🔥🔥AddTaskVC has been deallocated🔥🔥🔥")
        reloadTableViewCallBack?()
    }
    
    func setupNavigationBarAppearance() {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.init(name: "Avenir Next Bold", size: 30)]
    }
    
    
    @IBAction func saveTaskButton(_ sender: UIBarButtonItem) {
        saveTask()
    }
    
    @IBAction func goBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func titleTextDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        updateTitle(title: text)
    }
    
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        updateDate(date: sender.date)
    }
    
    @IBAction func timePickerAction(_ sender: UIDatePicker) {
        updateTime(date: sender.date)
    }
    
    @IBAction func priorityDidChange(_ sender: UISegmentedControl) {
        updatePriority(priority: sender.selectedSegmentIndex)
    }
    
    @IBAction func rollDownDateStack(_ sender: UIButton) {
        if timePicker.isHidden == false {
            timePicker.shake()
        }
        guard timePickerStackViewHeight.constant == 42 else { return }
        let height = datePickerStackViewHeight.constant
        datePicker.isHidden = height == 42 ? false : true
        datePickerBgViewHeight.constant = height == 42 ? 42 : 0
        datePickerStackViewHeight.constant = height == 42 ? 80 : 42
        dateStackViewHeight.constant = height == 42 ? 109 : 67
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func rollDownTimeStack(_ sender: UIButton) {
        if datePicker.isHidden == false {
            datePicker.shake()
        }
        guard datePickerStackViewHeight.constant == 42 else { return }
        let height = timePickerStackViewHeight.constant
        timePicker.isHidden = height == 42 ? false : true
        timePickerBgViewHeight.constant = height == 42 ? 42 : 0
        timePickerStackViewHeight.constant = height == 42 ? 80 : 42
        timeStackViewHeight.constant = height == 42 ? 109 : 67

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    func holdTaskContent() {
        if let task = taskToSave {
            titleTextField.text = task.title
            datePicker.date = task.date
            dateLabel.text = Date.convertDateToDateString(date: task.date)
            timePicker.date = task.time
            timeLabel.text = Date.convertDateToHourAndMinutes(date: task.time)
            prioritySegmentedControl.selectedSegmentIndex = Int(task.priority)
            subtitleTextView.text = task.subtitle
            collectionView.selectItem(at: IndexPath(row: Int(task.colorIndex), section: 0), animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    func updateTitle(title: String) {
        taskModel.title = title
    }
    
    func updateSubtitle(subtitle: String) {
        taskModel.subtitle = subtitle
    }
    
    func updateDate(date: Date) {
        taskModel.date = date
        let dateString = Date.convertDateToDateString(date: taskModel.date as Date)
        dateLabel.text = dateString
    }
    
    func updateTime(date: Date) {
        taskModel.time = date
        let timeString = Date.convertDateToHourAndMinutes(date: taskModel.time as Date)
        timeLabel.text = timeString
    }
    
    func updateColor(colorIndex: Int) {
        taskModel.colorIndex = Int16(colorIndex)
        markedIndexPath.row = colorIndex
    }
    
    func updatePriority(priority: Int!) {
        taskModel.priority = Int16(priority)
    }
    
    func saveTask() {
        if taskModel.title != "" && taskModel.subtitle != "" {
            if taskToSave == nil {
                taskToSave = Task(context: PersistanceService.context)
            }
            taskToSave = mergeTaskModelIntoTaskToSave(taskToSave: taskToSave!, taskModel: taskModel)
            PersistanceService.saveContext()
            Alert.showTaskSavedAlert(on: self)
            disMissAndResignFirstResponder()
        } else {
            Alert.showEmptyPlaceholdersAlert(on: self)
        }
    }
    
    func disMissAndResignFirstResponder() {
        dismiss(animated: true, completion: nil)
        titleTextField.resignFirstResponder()
        subtitleTextView.resignFirstResponder()
    }
    
    func mergeTaskModelIntoTaskToSave(taskToSave: Task, taskModel: AddTask.TaskModel) -> Task {
        taskToSave.title = taskModel.title
        taskToSave.subtitle = taskModel.subtitle
        taskToSave.date = taskModel.date
        taskToSave.time = taskModel.time
        taskToSave.priority = taskModel.priority
        taskToSave.colorIndex = taskModel.colorIndex
        return taskToSave
    }
    
    func fillUpTaskModel(task: Task) -> AddTask.TaskModel {
        var taskModel = AddTask.TaskModel()
        taskModel.title = task.title
        taskModel.subtitle = task.subtitle
        taskModel.date = task.date
        taskModel.time = task.time
        taskModel.priority = task.priority
        taskModel.colorIndex = task.colorIndex
        return taskModel
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.keyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.keyboardWillHide, object: nil)
    }
    
    func setupDelegateAndDataSource() {
        collectionView.delegate = self
        collectionView.dataSource = self
        titleTextField.delegate = self
        scrollView.delegate = self
        subtitleTextView.delegate = self
    }
    
    func setupLayout() {
        titleTextField.layer.masksToBounds = true
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.borderColor = UIColor.white.cgColor
        titleTextField.layer.cornerRadius = 10

        datePicker.layer.masksToBounds = true
        datePicker.layer.borderWidth = 2
        datePicker.layer.borderColor = UIColor.white.cgColor
        datePicker.layer.cornerRadius = 10
        datePicker.tintColor = .white
        
        timePicker.layer.masksToBounds = true
        timePicker.layer.borderWidth = 2
        timePicker.layer.borderColor = UIColor.white.cgColor
        timePicker.layer.cornerRadius = 10
        
        let attributedTextTitle = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        
        prioritySegmentedControl.setTitleTextAttributes(attributedTextTitle, for: .normal)
        prioritySegmentedControl.setTitleTextAttributes(attributedTextTitle, for: .selected)
    }
    
    @objc func keyboardWillShow(_ sender: NSNotification) {
        if dateStackViewHeight.constant == 109 || timeStackViewHeight.constant == 109 {
            datePickerStackViewHeight.constant = 42
            datePickerBgViewHeight.constant = 0
            
            timePickerStackViewHeight.constant = 42
            timePickerBgViewHeight.constant = 0
        }
        
        dateStackViewHeight.constant = 0
        dateStackView.isHidden = true
        timeStackViewHeight.constant = 0
        timeStackView.isHidden = true
        priorityStackViewHeight.constant = 0
        priorityStackView.isHidden = true
        
        firstSpacingConstraint.constant = 0
        secondSpacingConstraint.constant = 0
        thridSpacingConstraint.constant = 0
        fourthSpacingConstraint.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ sender: NSNotification) {
        dateStackViewHeight.constant = 67
        dateStackView.isHidden = false
        timeStackViewHeight.constant = 67
        timeStackView.isHidden = false
        priorityStackViewHeight.constant = 67
        priorityStackView.isHidden = false
        
        firstSpacingConstraint.constant = 10
        secondSpacingConstraint.constant = 10
        thridSpacingConstraint.constant = 10
        fourthSpacingConstraint.constant = 10
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("Segperformed")
    }
    
}


extension AddTaskViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell
        
        cell?.contentView.backgroundColor = Constants.colors[indexPath.row]
        cell?.imageView.isHidden = indexPath == markedIndexPath ? false : true
    
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        markedIndexPath = indexPath
        updateColor(colorIndex: markedIndexPath.row)
        collectionView.scrollToItem(at: markedIndexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}


extension AddTaskViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateSubtitle(subtitle: textView.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
}
