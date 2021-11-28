//
//  BaseTextField.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 15/11/21.
//

import UIKit

class BaseTextField: UITextField {

   

}

extension UITextField {
    open override var isFocused: Bool {
        didSet {
            if (isFocused) {
                print("wiuebfewibfwefbewfubeifbwifuew")
            }
        }
    }
}
