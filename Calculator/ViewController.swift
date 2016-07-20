//
//  ViewController.swift
//  Calculator
//
//  Created by Gabriel Bryant on 7/11/16.
//  Copyright © 2016 Pegasaur. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
//    @IBOutlet var buttons: [UIButton]!
//    @IBOutlet var heightConstraintsForChoiceButtons: [NSLayoutConstraint]!
    private var userIsInTheMiddleOfTyping = false

    
    @IBAction private func touchDigit(sender: UIButton) {
        //sometimes crashing your app is a way to find a bug
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            //if for some reason display weren't wired, it would crash
            let textCurrentlyInDisplay = display.text!
            switch digit {
            case ".":
                if (display.text!.rangeOfString(".") == nil) {fallthrough}
            default:
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if (digit == ".") {
                display.text = "0."
            } else {
                display.text = digit
            }
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double {
        get {
            //would crash if non-numbers were in the label
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    //this could totally be an optional if CalculatorBrain is nil
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        } //else not defined
        displayValue = brain.result
    }
    
    /*
     ** Setup custom display elements
     */
    
    @IBOutlet var extraFuncStacks: [UIStackView]!
    @IBOutlet var buttons: [UIButton]!
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,
                                                  withTransitionCoordinator coordinator:
        UIViewControllerTransitionCoordinator) {
        
        super.willTransitionToTraitCollection(newCollection,
                                              withTransitionCoordinator: coordinator)
        configureView(newCollection.verticalSizeClass)
    }
    
    private func configureView(verticalSizeClass: UIUserInterfaceSizeClass) {
        for stack in extraFuncStacks {
            stack.hidden = (verticalSizeClass == .Regular)
        }
        
//        if (verticalSizeClass == .Regular)
//        {
//            display.font.pointSize = CGFloat(50)
//        } else {
//            display.font.pointSize
//        }

//        for button in buttons {
//            button.layer.borderWidth = CGFloat(0.5)
//            button.layer.borderColor = UIColor.grayColor().CGColor
//            
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView(traitCollection.verticalSizeClass)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
}

/*
 ** extensions
 */
extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, forState: state)
    }
}

