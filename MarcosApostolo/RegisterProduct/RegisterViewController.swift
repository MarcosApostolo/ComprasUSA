//
//  RegisterViewController.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 14/11/21.
//

import UIKit
import CoreData

protocol RegisterViewControllerDelegate {
    func didFinishEditing()
}

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var purchaseNameTextField: UITextField!
    @IBOutlet weak var purchaseImageView: UIImageView!
    @IBOutlet weak var purchaseValuetextField: UITextField!
    @IBOutlet weak var stateInfoLabel: UILabel!
    @IBOutlet weak var stateInfoContainer: UIView!
    @IBOutlet weak var purchaseCardPaymentSwitch: UISwitch!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var purchaseNameErrorText: UILabel!
    @IBOutlet weak var purchaseImageErrorText: UILabel!
    @IBOutlet weak var purchaseStateErrorText: UILabel!
    @IBOutlet weak var purchaseValueErrorText: UILabel!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var stateContainer: UIView!
    
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
    
    private var purchaseNameError: String? = nil {
        didSet {
            let hasPurchaseNameError = purchaseNameError != nil
            
            purchaseNameErrorText.isHidden = !hasPurchaseNameError
            hasError = hasPurchaseNameError
            purchaseNameErrorText.text = purchaseNameError
            
            self.setupTextFieldWithError(textField: purchaseNameTextField)
        }
    }
    
    private var purchaseImageError: String? = nil {
        didSet {
            let hasPurchaseImageError = purchaseImageError != nil
            
            purchaseImageErrorText.isHidden = !hasPurchaseImageError
            hasError = hasPurchaseImageError
            purchaseImageErrorText.text = purchaseImageError
        }
    }
    private var purchaseStateError: String? = nil {
        didSet {
            let hasPurchaseStateError = purchaseStateError != nil
            
            purchaseStateErrorText.isHidden = !hasPurchaseStateError
            hasError = hasPurchaseStateError
            purchaseStateErrorText.text = purchaseStateError
            
            setupStateViewWithError()
        }
    }
    private var purchaseValueError: String? = nil {
        didSet {
            let hasPurchaseValueError = purchaseValueError != nil
            
            purchaseValueErrorText.isHidden = !hasPurchaseValueError
            hasError = hasPurchaseValueError
            purchaseValueErrorText.text = purchaseValueError
            
            self.setupTextFieldWithError(textField: purchaseValuetextField)
        }
    }
    
    private var hasError: Bool = false {
        didSet {
            submitButton.isEnabled = !hasError
        }
    }
    
    var statesPickerPresenter: StatesPickerPresenter?
    
    var purchase: Purchase?
    
    var delegate: RegisterViewControllerDelegate?
    
    var selectedState: State? {
        didSet {
            self.setStateLabel(with: selectedState?.name)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        setupData()

        setupView()
    }
    
    private func setupData() {
        try? fetchedResultsController.performFetch()
    }
    
    private func setupView() {
        
        purchaseNameTextField.keyboardType = .default
        purchaseValuetextField.keyboardType = .decimalPad
        
        setupInactiveStateView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        stateContainer.addGestureRecognizer(tap)
        
        let states = fetchedResultsController.fetchedObjects
        
        if let states = states {
            let picker = StatesPickerPresenter(states: states)
            
            picker.delegate = self
            
            statesPickerPresenter = picker
            
            view.addSubview(picker)
        }
        
        guard let purchase = purchase else {
            purchaseImageView.isHidden = true
            addImageButton.isHidden = false
            
            return
        }
        
        purchaseImageView.isHidden = false
        purchaseImageView.image = purchase.productImage
        addImageButton.isHidden = true
        purchaseNameTextField.text = purchase.name
        purchaseValuetextField.text = "\(purchase.value)"
        purchaseCardPaymentSwitch.isOn = purchase.isCardPurchase
        selectedState = purchase.state
        submitButton.isEnabled = true
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        statesPickerPresenter?.showPicker()
    }
    
    private func setStateLabel(with info: String?) {
        stateInfoLabel.text = info
        stateInfoLabel.textColor = UIColor.label
    }
    
    private func setupStateViewWithError() {
        stateInfoContainer.layer.borderWidth = 1
        stateInfoContainer.layer.borderColor = UIColor.systemRed.cgColor
        stateInfoContainer.layer.cornerRadius = 4
    }
    
    private func setupInactiveStateView() {
        stateInfoContainer.layer.borderWidth = 0.5
        stateInfoContainer.layer.borderColor = CGColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0)
        stateInfoContainer.layer.cornerRadius = 4
    }
    
    private func selectPictureFrom(_ sourceType: UIImagePickerController.SourceType) {
        view.endEditing(true)
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func handleError(with errorMessage: String?) {
        let message = errorMessage ?? "Houve um erro ao registrar a compra"
        
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onEndEditingNameTextField(_ sender: UITextField) {
        let value = sender.text
                
        if (value == nil || value?.count == 0) {
            purchaseNameError = "Nome do produto é obrigatório"
            return
        }
        
        purchaseNameError = nil
        
        self.setupInactiveTextField(textField: sender)
    }
    
    @IBAction func onEndEditingValueTextField(_ sender: UITextField) {
        let value = sender.text
                
        if (value == nil || value?.count == 0) {
            purchaseValueError = "Valor é obrigatório"
            return
        }
        
        purchaseValueError = nil
        
        self.setupInactiveTextField(textField: sender)
    }
    
    @IBAction func onSubmitButtonTap(_ sender: UIButton) {
        if (hasError) {
            handleError(with: nil)
            return
        }
        
        guard let purchaseName = purchaseNameTextField.text, let purchaseValue = purchaseValuetextField.text, let purchaseImage = purchaseImageView.image, let selectedState = self.selectedState else {
            
            handleError(with: nil)
            return
        }
        
        if (purchaseValue.contains(".")) {
            self.doubleFormatter.decimalSeparator = "."
        } else if (purchaseValue.contains(",")) {
            self.doubleFormatter.decimalSeparator = ","
        }
        
        guard let purchaseDoubleValue = doubleFormatter.number(from: purchaseValue) else {
            handleError(with: nil)
            return
        }
        
        let purchase = purchase ?? Purchase(context: context)
        
        purchase.state = selectedState
        purchase.name = purchaseName
        purchase.value = purchaseDoubleValue.doubleValue
        purchase.image = purchaseImage.jpegData(compressionQuality: 0.8)
        purchase.isCardPurchase = purchaseCardPaymentSwitch.isOn
        
        do {
            try context.save()
            
            navigationController?.popViewController(animated: true)
        } catch {
            handleError(with: nil)
        }
    }
    
    @IBAction func onPurchaseNameTextFieldBeginEditing(_ sender: UITextField) {
        
        self.setupActiveTextField(textField: sender)
    }
    
    @IBAction func onPurchaseValueTextFieldBeginEditing(_ sender: UITextField) {
        
        self.setupActiveTextField(textField: sender)
    }
    
    @IBAction func onSelectStateTap(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            vc.delegate = self
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onAddImageButtonTap(_ sender: UIButton) {
        let alert = UIAlertController(title: "Escolher imagem", message: "De onde você deseja escolher a imagem?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { _ in
                self.selectPictureFrom(.camera)
            }
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de Fotos", style: .default) { _ in
            self.selectPictureFrom(.photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de Fotos", style: .default) { _ in
            self.selectPictureFrom(.savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {
            purchaseImageView.image = image
            addImageButton.isHidden = true
            purchaseImageView.isHidden = false
            purchaseImageView.backgroundColor = .white
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}

extension RegisterViewController: StatesPickerPresenterProtocol {
    func onDoneButtonTap(selectedValue: State) {
        self.selectedState = selectedValue
    }
}

extension RegisterViewController: StateCreatedDelegate {
    func onStateCreated() {
        try? fetchedResultsController.performFetch()
        
        if let states = fetchedResultsController.fetchedObjects {
            statesPickerPresenter?.setStates(with: states)
        }
    }
}
