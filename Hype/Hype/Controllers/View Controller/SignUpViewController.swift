//
//  SignUpViewController.swift
//  Hype
//
//  Created by Colby Harris on 4/1/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    //MARK: - Outlets and Properties
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        
        UserController.sharedInstance.createUserWith(username) { (result) in
            switch result {
                
            case .success(let user):
                UserController.sharedInstance.currentUser = user
                
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    func fetchUser() {
        UserController.sharedInstance.fetchUser { (result) in
            switch result {
                
            case .success(let user):
                UserController.sharedInstance.currentUser = user
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }

    func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
            
        }
    }

}
