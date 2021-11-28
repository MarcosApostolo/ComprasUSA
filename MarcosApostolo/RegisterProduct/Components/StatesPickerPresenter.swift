//
//  StatesPickerPresenter.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 15/11/21.
//

import Foundation
import UIKit

protocol StatesPickerPresenterProtocol {
    func onDoneButtonTap(selectedValue: State)
}

class StatesPickerPresenter: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    var delegate: StatesPickerPresenterProtocol?
    
    private lazy var doneToolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        doneButton.isEnabled = false

        let items = [flexSpace, doneButton]
        toolbar.items = items
        toolbar.sizeToFit()

        return toolbar
    }()
    
    private let textField = UITextField(frame: .zero)

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()

    private var selectedItem: State? {
        didSet {
            if (selectedItem != nil) {
                doneToolbar.items?.last?.isEnabled = true
            }
        }
    }
    
    private var states: [State] = []

    init(states: [State]) {
        super.init(frame: .zero)
        setupView()
        
        self.states = states
    }
    
    func setStates(with states: [State]) {
        self.states = states
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        textField.inputView = pickerView
        textField.inputAccessoryView = doneToolbar
        
        self.addSubview(textField)
    }

    @objc private func doneButtonTapped() {
        if let selectedItem = selectedItem {
            delegate?.onDoneButtonTap(selectedValue: selectedItem)
        }
        
        textField.resignFirstResponder()
    }

    func showPicker() {
        textField.becomeFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.states.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.states[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = self.states[row]
    }
}
