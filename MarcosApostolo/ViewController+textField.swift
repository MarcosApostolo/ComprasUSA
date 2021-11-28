//
//  ViewController+textField.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 15/11/21.
//

import Foundation
import UIKit

extension UIViewController {
    func setupTextFieldWithError(textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.layer.cornerRadius = 4
    }
    
    func setupActiveTextField(textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.tintColor.cgColor
        textField.layer.cornerRadius = 4
    }
    
    func setupInactiveTextField(textField: UITextField) {
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = CGColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0)
        textField.layer.cornerRadius = 4
    }
}
