//
//  Purchase+Various.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 15/11/21.
//

import Foundation
import UIKit

extension Purchase {
    var productImage: UIImage? {
        if let data = image {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
}
