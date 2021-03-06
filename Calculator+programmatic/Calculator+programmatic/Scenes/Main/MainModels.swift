//
//  MainModels.swift
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

enum Main
{
    struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: (Double)
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }

    enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    enum PerformOperation {
        struct Request {
            var text: String
        }

        struct Response {
            var text: String
        }

        struct ViewModel {

            var text: String
        }
    }
}
