//
//  TableViewCell.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 15/11/21.
//

import UIKit

class PurchasesTableViewCell: UITableViewCell {
    @IBOutlet weak var purchaseImageView: UIImageView!
    @IBOutlet weak var purchasePaymentImageView: UIImageView!
    @IBOutlet weak var purchaseName: UILabel!
    @IBOutlet weak var stateName: UILabel!
    @IBOutlet weak var taxValueLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "pt_BR")
        return numberFormatter
    }()
    
    private let checkMark = "checkmark.square.fill"
    private let xMark = "xmark.app.fill"
    
    func setupView(with purchase: Purchase) {
        purchaseImageView.image = purchase.productImage
        valueLabel.text = numberFormatter.string(from: NSNumber(value: purchase.value)) ?? "R$ \(purchase.value)"
        purchaseName.text = purchase.name
        stateName.text = purchase.state?.name
        
        if let taxValue = purchase.state?.taxValue {
            taxValueLabel.text = "\(taxValue)%"
        }
        
        let checkPaymentImage = UIImage(systemName: checkMark)
        let xPaymentImage = UIImage(systemName: xMark)
        
        purchasePaymentImageView.image = purchase.isCardPurchase ? checkPaymentImage : xPaymentImage
    }
}
