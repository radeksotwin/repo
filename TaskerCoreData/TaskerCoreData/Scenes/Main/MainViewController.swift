//
//  ViewController.swift
//  TaskerCoreData
//
//  Created by Rdm on 19/11/2020.
//

import UIKit
import CoreData

protocol MainDataStore {
    var tasks: Main.Tasks! { get set }
    var pickedTask: Task! { get set }
}

class MainViewController: UIViewController, MainDataStore {
   
    // MARK: (viewWillAppear didn't get called after dismissing AddTaskVC), check why the Kacper's solution doesn't work in our project(?)
    
    @IBOutlet weak var tableView: UITableView!
    
    private let sections: [String] = ["Past tasks", "Today", "Tommorrow", "Upcoming 7 days"]
    
    var tasks: Main.Tasks!
    var pickedTask: Task!
    
    let alertView = UIAlertController(title: "", message: "", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegateAndDataSource()
        handleTableViewReloadCallBack()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasksContent()
        print("MainVC appeared")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? TaskCell, let addTaskVC = segue.destination as? AddTaskViewController {
            if tableView.indexPath(for: cell) != nil {
                let task = cell.task
                addTaskVC.taskToSave = task
                addTaskVC.taskModel = addTaskVC.fillUpTaskModel(task: task!)
            }
        }
    }
    
    @IBAction func routeToAddTaskVC(_ sender: UIBarButtonItem) {
        present(AddTaskViewController(), animated: true, completion: nil)
    }
    
    func handleTableViewReloadCallBack() {
        let addTaskVC = AddTaskViewController()
        print(addTaskVC)
        print("Callback sent")
        addTaskVC.reloadTableViewCallBack = { [weak self] in
            guard let me = self else {return}
            me.loadTasksContent()
        }
       
    }
    
    func setupDelegateAndDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func deleteTask() {
        PersistanceService.context.delete(pickedTask)
        PersistanceService.saveContext()
        loadTasksContent()
    }
    
    func markPickedTaskAsDone() {
        pickedTask.taskDone = !pickedTask.taskDone
        PersistanceService.saveContext()
    }

    func pickTaskToEdit(task: Task) {
        pickedTask = task
    }
    
    func loadTasksContent() {
        fetchTasks { [weak self] (tasksArray) in
            guard let me = self else { return }
            me.tasks = groupFetchedTasksArray(tasksToGroup: tasksArray)
            me.tableView.reloadData()
        }
        print("Tasks content successfully loaded")
    }
    
    // MARK: Worker methods
    
    func fetchTasks(completion: ([Task]) -> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let tasksArray = try PersistanceService.context.fetch(fetchRequest)
            completion(tasksArray)
        } catch let error {
            print("Error fetching CoreData objects", error)
        }
    }
    
    func groupFetchedTasksArray(tasksToGroup: [Task]) -> Main.Tasks {
        var past: [Task] = []
        var today: [Task] = []
        var tomorrow: [Task] = []
        var upcoming7Days: [Task] = []
        
        for task in tasksToGroup {
            if let date = task.date as Date? {
                if Date.wasInPast(date: date) == true {
                    past.append(task)
                }
                if Date.isToday(date: date) == true {
                    today.append(task)
                }
                if Date.isTomorrow(date: date) == true {
                    tomorrow.append(task)
                }
                if Date.isInUpcoming7days(date: date) == true {
                    upcoming7Days.append(task)
                }
            }
        }
        
        past.sort(by: { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 })
        today.sort(by: { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 })
        tomorrow.sort(by: { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 })
        upcoming7Days.sort(by: { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 })
        
        return Main.Tasks(past: past, today: today, tomorrow: tomorrow, upcoming7days: upcoming7Days)
    }
   
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: SectionHeaderCell.identifier) as! SectionHeaderCell
        header.sectionTitle.text = sections[section]
        return header.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            return tasks.past.count
        case 1 :
            return tasks.today.count
        case 2 :
            return tasks.tomorrow.count
        case 3 :
            return tasks.upcoming7days.count
        default:
            return 0
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskCell
        
        switch indexPath.section {
        case 0:
            cell.task = tasks.past[indexPath.row]
        case 1:
            cell.task = tasks.today[indexPath.row]
        case 2:
            cell.task = tasks.tomorrow[indexPath.row]
        case 3:
            cell.task = tasks.upcoming7days[indexPath.row]
        default:
            break
        }
        
        cell.setupView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskCell = tableView.cellForRow(at: indexPath) as! TaskCell
        
        switch indexPath.section {
        case 0:
            pickTaskToEdit(task: tasks.past[indexPath.row])
        case 1:
            pickTaskToEdit(task: tasks.today[indexPath.row])
        case 2:
            pickTaskToEdit(task: tasks.tomorrow[indexPath.row])
        case 3:
            pickTaskToEdit(task: tasks.upcoming7days[indexPath.row])
        default:
            break
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") {  [weak self] (action, indexPath, error) in
            guard let me = self else { return }
            me.deleteTask()
            Alert.showTaskDeletedAlert(on: me)
            print("Task deleted!")
        }
        
        let doneAction =  UIContextualAction(style: .normal, title: "Done") {  [weak self] (action, indexPath, error) in
            guard let me = self else { return }
            me.markPickedTaskAsDone()
            taskCell.layoutIfNeeded()
            Alert.showTaskDoneAlert(on: me)
            print("Task done!")
        }
        
        let editAction =  UIContextualAction(style: .normal, title: "Edit") {  [weak self] (action, indexPath, error) in
            guard let me = self else { return }
            me.performSegue(withIdentifier: "toAddTaskVC", sender: taskCell)
            }

        deleteAction.backgroundColor = .systemRed
        doneAction.backgroundColor = .systemGreen
        editAction.backgroundColor = .systemOrange
                
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
        return actions
    }
}
