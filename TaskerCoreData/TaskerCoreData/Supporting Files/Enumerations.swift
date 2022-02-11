//
//  Enumerations.swift
//  TaskerCoreData
//
//  Created by Rdm on 10/02/2022.
//

import UIKit

enum Alert {
    static func showEmptyPlaceholdersAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Fill empty placeholders!", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            vc.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showTaskDeletedAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Task has been deleted!", message: "", preferredStyle: .alert)
        vc.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    static func showTaskDoneAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Task done!", message: "", preferredStyle: .alert)
        vc.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    static func showTaskSavedAlert(on vc:  UIViewController) {
        let alert = UIAlertController(title: "Task saved!", message: "", preferredStyle: .alert)
        vc.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            vc.dismiss(animated: true, completion: nil)
        }
      
    }
}
