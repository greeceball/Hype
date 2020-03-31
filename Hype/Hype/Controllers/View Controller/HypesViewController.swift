//
//  HypesViewController.swift
//  Hype
//
//  Created by Colby Harris on 3/30/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class HypesViewController: UIViewController {
    
    //MARK: - Outlets and Properties
    @IBOutlet weak var hypesTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadHypes()
    }
    
    //MARK: - Custom Methods
    
    func setupViews() {
        self.hypesTableView.delegate = self
        self.hypesTableView.dataSource = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to see new Hypes")
        refreshControl.addTarget(self, action: #selector(loadHypes), for: .valueChanged)
        hypesTableView.addSubview(refreshControl)
    }
    
    
    @objc func loadHypes () {
        HypeController.shared.fetchAllHypes { (success) in
            DispatchQueue.main.async {
                if success {
                    self.updateViews()
                }
            }
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.hypesTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func presentAddHypeAlert(for hype: Hype?) {
        let alert = UIAlertController(title: "Get Hyped!", message: "What is Hyped may never die", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "hype message"
            textField.autocorrectionType = .yes
            textField.delegate = self
            
            textField.autocapitalizationType = .sentences
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (_) in
            
            guard let body = alert.textFields?.first?.text, !body.isEmpty else { return }
            
            if let hype = hype {
                hype.body = body
                HypeController.shared.update(hype) { (result) in
                    switch result {
                    case .success(_):
                        self.updateViews()
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                
                
                HypeController.shared.saveHype(body: body) { (success) in
                    DispatchQueue.main.async {
                        if success {
                            self.updateViews()
                        }
                        
                    }
                }
            }
        }
        
        
        
        alert.addAction(saveButton)
        
        let cancelButton = UIAlertAction(title: "Nvm", style: .cancel)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
    }
    
    //MARK: - Actions
    
    @IBAction func composeButtonTapped(_ sender: Any) {
        presentAddHypeAlert(for: nil)
        
    }
    
    
    
}

//MARK: - TableView Delegate and dataSource

extension HypesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatDate()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hype = HypeController.shared.hypes[indexPath.row]
        presentAddHypeAlert(for: hype)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hype = HypeController.shared.hypes[indexPath.row]
            guard let index = HypeController.shared.hypes.firstIndex(of: hype) else { return }
            HypeController.shared.delete(hype) { (result) in
                switch result {
                case .success(let success):
                    if success {
                        HypeController.shared.hypes.remove(at: index)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

//MARK: - TextField Delegate

extension HypesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
