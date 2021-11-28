//
//  StatesTableViewCell.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 15/11/21.
//

import UIKit

class StatesTableViewCell: UITableViewCell {
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var taxValueLabel: UILabel!
    
    func setupView(with state: State) {
        stateNameLabel.text = state.name
        taxValueLabel.text = String(state.taxValue)
    }
}
