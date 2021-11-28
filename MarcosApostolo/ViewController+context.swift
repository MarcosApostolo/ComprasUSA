//
//  ViewController+context.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 14/11/21.
//

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        return appdelegate.persistentContainer.viewContext
    }
}
