//
//  ResultsViewController.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 14/11/21.
//

import UIKit
import CoreData

class ResultsViewController: UIViewController {
    @IBOutlet weak var dolarTotalLabel: UILabel!
    @IBOutlet weak var BRLTotalLabel: UILabel!
    @IBOutlet weak var warningStackView: UIStackView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Purchase> = {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "pt_BR")
        return numberFormatter
    }()
    
    let userDefaults = UserDefaults.standard
    
    private var resultCalculator: ResultCalculator = {
        let dolar = UserDefaults.standard.double(forKey: "dolar")
        let iof = UserDefaults.standard.double(forKey: "iof")
        
        return ResultCalculator(iof: iof, dolar: dolar)
    }()
    
    private var dolarTotal = 0.0 {
        didSet {
            dolarTotalLabel.text = numberFormatter.string(from: NSNumber(value: dolarTotal)) ?? "R$ \(dolarTotal)"
        }
    }
    
    private var BRLValue = 1.0 {
        didSet {
            BRLTotalLabel.text = numberFormatter.string(from: NSNumber(value: BRLValue)) ?? "R$ \(BRLValue)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUDChange), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc private func handleUDChange() {
        let dolar = UserDefaults.standard.double(forKey: "dolar")
        let iof = UserDefaults.standard.double(forKey: "iof")
        
        resultCalculator.setIOF(with: iof)
        resultCalculator.setDolar(with: dolar)
        
        updateWithValues()
    }
    
    private func setupData() {
        try? fetchedResultsController.performFetch()
    }
    
    private func setupView() {
        setupWarning()
        
        updateWithValues()
    }
    
    private func setupWarning() {
        let purchases = fetchedResultsController.fetchedObjects
        
        if let purchases = purchases {
            let hasPuchasesWithoutStateTaxInfo = purchases.contains { purchase in
                return purchase.state == nil
            }
            
            if (hasPuchasesWithoutStateTaxInfo) {
                warningStackView.isHidden = false
            }
        }
    }
    
    private func updateWithValues() {
        let purchases = fetchedResultsController.fetchedObjects
        
        if let purchases = purchases {
            resultCalculator.setPurchases(with: purchases)
            
            dolarTotal = resultCalculator.getValueInDolars()
            BRLValue = resultCalculator.getValueInBRL()
        }
    }
    
    private func updateWarning() {
        let purchases = fetchedResultsController.fetchedObjects
        
        if let purchases = purchases {
            let hasPuchasesWithoutStateTaxInfo = purchases.contains { purchase in
                return purchase.state == nil
            }
            
            if (hasPuchasesWithoutStateTaxInfo) {
                warningStackView.isHidden = false
            } else {
                warningStackView.isHidden = true
            }
        }
    }
}

extension ResultsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateWithValues()
        
        updateWarning()
    }
}
