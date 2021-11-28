//
//  ViewController.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 14/11/21.
//

import UIKit
import CoreData

class PurchasesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var purchasesTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Purchase> = {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchasesTableView.delegate = self
        purchasesTableView.dataSource = self
        
        loadPurchases()
    }

    private func loadPurchases() {
        try? fetchedResultsController.performFetch()
    }
    
    private func setupView() {
        let isEmpty = fetchedResultsController.fetchedObjects?.isEmpty ?? true
        
        if (isEmpty) {
            emptyLabel.isHidden = false
            purchasesTableView.isHidden = true
        }
    }
    
    private func handleDelete(with purchase: Purchase?) {
        let alert = UIAlertController(title: "Remover Compra", message: "Tem certeza que deseja remover a compra?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { [weak self] _ in
            guard let purchase = purchase else {
                self?.handleError(with: nil)
                return
            }

            self?.context.delete(purchase)
            
            do {
                try self?.context.save()
            } catch {
                self?.handleError(with: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleError(with errorMessage: String?) {
        let message = errorMessage ?? "Houve um erro ao deletar a compra"
        
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = fetchedResultsController.fetchedObjects?.count ?? 0
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PurchasesTableViewCell else {
            return UITableViewCell()
        }

        let purchase = fetchedResultsController.object(at: indexPath)
        cell.setupView(with: purchase)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let purchase = fetchedResultsController.object(at: indexPath)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            vc.purchase = purchase
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Remover") { [weak self] action, view, completionHandler in
            self?.handleDelete(with: self?.fetchedResultsController.object(at: indexPath))
            
            completionHandler(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        
        return config
    }
}

extension PurchasesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let isEmpty = fetchedResultsController.fetchedObjects?.isEmpty ?? true
        
        if (isEmpty) {
            emptyLabel.isHidden = false
            purchasesTableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            purchasesTableView.isHidden = false
        }
        
        self.purchasesTableView.reloadData()
    }
}

extension PurchasesViewController: RegisterViewControllerDelegate {
    func didFinishEditing() {
        print("passou aqui")
    }
}
