//
//  SettingsViewController.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 14/11/21.
//

import UIKit
import CoreData

protocol StateCreatedDelegate {
    func onStateCreated()
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dolarValueTextField: UITextField!
    @IBOutlet weak var taxValueTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var dolarValueErrorLabel: UILabel!
    @IBOutlet weak var taxValueErrorLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var statesTableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<State> = {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    let doubleFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.decimalSeparator = ","
        
        return formatter
    }()
    
    private let defaultDolarValue = DEFAULT_DOLAR_VALUE
    private let defaultIOFValue = DEFAULT_IOF_VALUE
    
    let userDefaults = UserDefaults.standard
    
    private var dolarValueErrorText: String? = nil {
        didSet {
            let hasDolarValueError = dolarValueErrorText != nil
            
            dolarValueErrorLabel.isHidden = !hasDolarValueError
            dolarValueErrorLabel.text = dolarValueErrorText
            
            self.setupTextFieldWithError(textField: dolarValueTextField)
        }
    }
    
    private var taxValueErrorText: String? = nil {
        didSet {
            let hasTaxValueError = taxValueErrorText != nil
            
            taxValueErrorLabel.isHidden = !hasTaxValueError
            taxValueErrorLabel.text = taxValueErrorText
            
            self.setupTextFieldWithError(textField: taxValueTextField)
        }
    }
    
    var delegate: StateCreatedDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        setupData()

        setupView()
    
        statesTableView.delegate = self
        statesTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSettingsUpdate), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleSettingsUpdate() {
        populateFieldsWithUDValues()
    }
    
    private func setupView() {
        dolarValueTextField.keyboardType = .decimalPad
        taxValueTextField.keyboardType = .decimalPad
        
        let isEmpty = fetchedResultsController.fetchedObjects?.isEmpty ?? true
        
        if (isEmpty) {
            emptyLabel.isHidden = false
            statesTableView.isHidden = true
        }
        
        populateFieldsWithUDValues()
    }
    
    private func populateFieldsWithUDValues() {
        
        let dolar = userDefaults.double(forKey: "dolar")
        
        if (dolar > 0) {
            dolarValueTextField.text = "\(dolar)"
        } else {
            dolarValueTextField.text = "\(defaultDolarValue)"
        }
        
        let iof = userDefaults.double(forKey: "iof")
        
        if (iof > 0) {
            taxValueTextField.text = "\(iof)"
        } else {
            taxValueTextField.text = "\(defaultIOFValue)"
        }
    }
    
    private func setupData() {
        try? fetchedResultsController.performFetch()
    }
    
    @IBAction func onEndEditingDolarTextField(_ sender: UITextField) {
        guard let value = sender.text else {
            dolarValueErrorText = "Campo obrigatório"
            return
        }
        
        if (value.count <= 0) {
            dolarValueErrorText = "Campo obrigatório"
            return
        }
        
        if (value.contains(".")) {
            self.doubleFormatter.decimalSeparator = "."
        } else if (value.contains(",")) {
            self.doubleFormatter.decimalSeparator = ","
        }
    
        guard let doubleValue = doubleFormatter.number(from: value) else {
            dolarValueErrorText = "Valor inválido"
            return
        }
        
        if (doubleValue.doubleValue <= 0) {
            dolarValueErrorText = "Valor não pode ser negativo"
            return
        }
        
        dolarValueErrorText = nil
        
        userDefaults.set(doubleValue, forKey: "dolar")
        
        userDefaults.synchronize()
                
        self.setupInactiveTextField(textField: sender)
    }
    
    @IBAction func onEndEditingTaxValueTextField(_ sender: UITextField) {
        
        guard let value = sender.text else {
            taxValueErrorText = "Campo obrigatório"
            return
        }
        
        if (value.count <= 0) {
            taxValueErrorText = "Campo obrigatório"
            return
        }
        
        if (value.contains(".")) {
            self.doubleFormatter.decimalSeparator = "."
        } else if (value.contains(",")) {
            self.doubleFormatter.decimalSeparator = ","
        }
    
        guard let doubleValue = doubleFormatter.number(from: value) else {
            taxValueErrorText = "Valor inválido"
            return
        }
        
        if (doubleValue.doubleValue <= 0) {
            taxValueErrorText = "Valor não pode ser negativo"
            return
        }
        
        taxValueErrorText = nil
        
        userDefaults.set(doubleValue, forKey: "iof")
        
        userDefaults.synchronize()
                
        self.setupInactiveTextField(textField: sender)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "statesCell", for: indexPath) as? StatesTableViewCell else {
            return UITableViewCell()
        }
        
        let state = fetchedResultsController.object(at: indexPath)
                
        cell.setupView(with: state)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Editar") { [weak self] action, view, completionHandler in
            self?.handleEdit(with: self?.fetchedResultsController.object(at: indexPath))
            
            completionHandler(true)
        }
        
        let delete = UIContextualAction(style: .destructive, title: "Remover") { [weak self] action, view, completionHandler in
            self?.handleDelete(with: self?.fetchedResultsController.object(at: indexPath))
            
            completionHandler(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return config
    }
    
    
    @IBAction func onDolarValueTextFieldBeginEditing(_ sender: UITextField) {
        
        self.setupActiveTextField(textField: sender)
    }
    
    @IBAction func onTaxValueTextFieldBeginEditing(_ sender: UITextField) {
        
        self.setupActiveTextField(textField: sender)
    }
    
    
    @IBAction func onSubmitButtonTap(_ sender: UIButton) {
        let alert = UIAlertController(title: "Adicionar estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nome do estado"
            textField.text = ""
            textField.autocapitalizationType = .words
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Imposto"
            textField.text = ""
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Adicionar", style: .default, handler: { _ in
            guard let stateName = alert.textFields?.first?.text, let taxValue = alert.textFields?.last?.text else {
                self.handleError(with: nil)
                return
            }
            
            if (taxValue.contains(".")) {
                self.doubleFormatter.decimalSeparator = "."
            } else if (taxValue.contains(",")) {
                self.doubleFormatter.decimalSeparator = ","
            }
            
            guard let doubleTaxValue = self.doubleFormatter.number(from: taxValue) else {
                self.handleError(with: nil)
                return
            }
            
            let state = State(context: self.context)
            
            state.taxValue = doubleTaxValue.doubleValue
            state.name = stateName
            
            do {
                try self.context.save()
                
                self.delegate?.onStateCreated()
            } catch {
                self.handleError(with: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleError(with errorMessage: String?) {
        let message = errorMessage ?? "Houve um erro ao registrar o estado"
        
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleEdit(with state: State?) {
        guard let state = state else {
            self.handleError(with: nil)
            return
        }
        
        let alert = UIAlertController(title: "Editar estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nome do estado"
            textField.text = state.name
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Imposto"
            textField.text = String(state.taxValue)
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Confirmar", style: .default, handler: { _ in
            if let stateName = alert.textFields?.first?.text, let taxValue = alert.textFields?.last?.text {
                if (taxValue.contains(".")) {
                    self.doubleFormatter.decimalSeparator = "."
                } else if (taxValue.contains(",")) {
                    self.doubleFormatter.decimalSeparator = ","
                }
                
                guard let doubleTaxValue = self.doubleFormatter.number(from: taxValue) else {
                    self.handleError(with: nil)
                    return
                }
                
                state.taxValue = doubleTaxValue.doubleValue
                state.name = stateName
                
                do {
                    try self.context.save()
                    
                    self.delegate?.onStateCreated()
                } catch {
                    self.handleError(with: nil)
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleDelete(with state: State?) {
        let alert = UIAlertController(title: "Remover estado", message: "Tem certeza que deseja remover o estado?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { [weak self] _ in
            if let state = state {
                self?.context.delete(state)
                
                do {
                    try self?.context.save()
                } catch {
                    self?.handleError(with: "Houve um erro ao apagar o estado")
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension SettingsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let isEmpty = controller.fetchedObjects?.isEmpty ?? true
        
        if (isEmpty) {
            emptyLabel.isHidden = false
            statesTableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            statesTableView.isHidden = false
        }
        
        self.statesTableView.reloadData()
    }
}
