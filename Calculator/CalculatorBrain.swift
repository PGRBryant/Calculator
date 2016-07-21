//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gabriel Bryant on 7/11/16.
//  Copyright © 2016 Pegasaur. All rights reserved.
//

import Foundation

//implement a number formatter

/*
 * Extra Functions
 */
private func factorial(d: Double) -> Double {
    if (d <= 1) {
        return 1
    }
    return d * factorial(d - 1.0)
}

//generalized Factorial, shortened name for code
private func gFac(d: Double) -> Double {
    if floor(d) == d {
        return factorial(d)
    }
    else {
        return tgamma(d)*d
    }
}
/*
 * End Extra Functions
 */


class CalculatorBrain {
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var accumulator = 0.0
    
    let numFormatter: NSNumberFormatter = {
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 6
        return nf
    }()

    //parens will wait until RPN??
    private var operations: Dictionary<String, Operation> = [
        "π"     : Operation.Constant(M_PI),
        "e"     : Operation.Constant(M_E),
        "rand"  : Operation.NullaryOperation(drand48), // this needs to be of case random
//        "("     : Operation.Paren(),
//        ")"     : Operation.Paren(),
        "%"     : Operation.UnaryOperation({$0/100.0}, { "(" + $0 + ")/100" }),
        "±"     : Operation.UnaryOperation({ -$0 }, { "-(" + $0 + ")"}),
        "√"     : Operation.UnaryOperation(sqrt, { "√(" + $0 + ")"}),
        "cos"   : Operation.UnaryOperation(cos, {"cos(" + $0 + ")" }),
        "sin"   : Operation.UnaryOperation(sin, {"sin(" + $0 + ")" }),
        "tan"   : Operation.UnaryOperation(tan, {"tan(" + $0 + ")" }),
        "sin⁻¹" : Operation.UnaryOperation(asin,{"sin⁻¹(" + $0 + ")" }),
        "cos⁻¹" : Operation.UnaryOperation(acos,{"cos⁻¹(" + $0 + ")" }),
        "tan⁻¹" : Operation.UnaryOperation(atan,{"tan⁻¹(" + $0 + ")" }),
        "ln"    : Operation.UnaryOperation(log, {"ln(" + $0 + ")" }),
        "log"   : Operation.UnaryOperation(log10, {"log(" + $0 + ")" }),
        "x²"    : Operation.UnaryOperation({ pow($0, 2) }, { "(" + $0 + ")²"}),
        "x⁻¹"   : Operation.UnaryOperation({ 1 / $0 }, { "(" + $0 + ")⁻¹"}),
        "!"     : Operation.UnaryOperation(gFac, { "(" + $0 + ")!"}),
        "^"     : Operation.BinaryOperation({ pow($0,$1) }, { $0 + " ^ " + $1 }, 2),
        "×"     : Operation.BinaryOperation({ $0 * $1 }, { $0 + " × " + $1 }, 1),
        "÷"     : Operation.BinaryOperation({ $0 / $1 }, { $0 + " ÷ " + $1 }, 1),
        "+"     : Operation.BinaryOperation({ $0 + $1 }, { $0 + " + " + $1 }, 0),
        "−"     : Operation.BinaryOperation({ $0 - $1 }, { $0 + " - " + $1 }, 0),
        "nPr"   : Operation.BinaryOperation({ gFac($0)/gFac($0-$1) }, { $0 + "P" + $1 }, 1),
        "nCr"   : Operation.BinaryOperation({ gFac($0)/(gFac($0-$1)*gFac($1)) }, { $0 + "C" + $1 }, 1),
        "="     : Operation.Equals
    ]
    
    //to handle binary operations
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    //need a series of possible exception cases, how do I handle this?
    //dictionary?
    private enum Operation {
        case Constant(Double)
        case NullaryOperation(() -> Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String,String) -> String, Int)
        case Equals
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        //descriptionAccumulator = String(operand)
        descriptionAccumulator = numFormatter.stringFromNumber(operand)!
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = String(value)
            case .NullaryOperation(let foo):
                accumulator = foo()
                descriptionAccumulator = String(accumulator)
            case .UnaryOperation(let foo, let descriptionFoo):
                accumulator = foo(accumulator)
                descriptionAccumulator = descriptionFoo(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFoo, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFoo, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    
    //needs to be public to give API access to the controller
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var currentPrecedence = Int.max
    
    private var descriptionAccumulator = "0"  {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    //no set implemented, therefore read-only
    var result: Double {
        get {
            return accumulator //remove error
        }
    }
    
    /*
     ** Not currently implemented
     */
    //need to translate buttons to usable code
    //should I make another enum? Since some will want surrounding parens, etc.
    private var textUIButtonTranslations: Dictionary<String, String> = [
        "±"     : "-",
        "nPr"   : "P",
        "nCr"   : "C"
    ]
    
}