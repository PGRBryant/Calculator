//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gabriel Bryant on 7/11/16.
//  Copyright © 2016 Pegasaur. All rights reserved.
//

import Foundation

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
    
    private var accumulator = 0.0
    
    func setOperand(operand: Double) {
        accumulator = operand
    }

    //parens will wait until RPN??
    private var operations: Dictionary<String, Operation> = [
        "π"     : Operation.Constant(M_PI),
        "e"     : Operation.Constant(M_E),
        "rand"  : Operation.Constant(drand48()),
//        "("     : Operation.Paren(),
//        ")"     : Operation.Paren(),
        "%"     : Operation.UnaryOperation({$0/100.0}),
        "±"     : Operation.UnaryOperation({ -$0 }),
        "√"     : Operation.UnaryOperation(sqrt),
        "cos"   : Operation.UnaryOperation(cos),
        "sin"   : Operation.UnaryOperation(sin),
        "tan"   : Operation.UnaryOperation(tan),
        "sin⁻¹" : Operation.UnaryOperation(asin),
        "cos⁻¹" : Operation.UnaryOperation(acos),
        "tan⁻¹" : Operation.UnaryOperation(atan),
        "ln"    : Operation.UnaryOperation(log),
        "log"   : Operation.UnaryOperation(log10),
        "x²"    : Operation.UnaryOperation({ pow($0, 2) }),
        "x⁻¹"   : Operation.UnaryOperation({ 1 / $0 }),
        "!"     : Operation.UnaryOperation(gFac),
        "^"     : Operation.BinaryOperation({ pow($0,$1) }),
        "×"     : Operation.BinaryOperation({ $0 * $1 }),
        "÷"     : Operation.BinaryOperation({ $0 / $1 }),
        "+"     : Operation.BinaryOperation({ $0 + $1 }),
        "−"     : Operation.BinaryOperation({ $0 - $1 }),
        "nPr"   : Operation.BinaryOperation({ gFac($0)/gFac($0-$1) }),
        "nCr"   : Operation.BinaryOperation({ gFac($0)/(gFac($0-$1)*gFac($1)) }),
        "="     : Operation.Equals
    ]
    
    //need to translate buttons to usable code
    //should I make another enum? Since some will want surrounding parens, etc.
    private var textUIButtonTranslations: Dictionary<String, String> = [
        "±"     : "-",
        "nPr"   : "P",
        "nCr"   : "C"
    ]
    
    //need a series of possible exception cases, how do I handle this?
    //dictionary?
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let foo):
                accumulator = foo(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    //no set implemented, therefore read-only
    var result: Double {
        get {
            return accumulator //remove error
        }
    }
    
}