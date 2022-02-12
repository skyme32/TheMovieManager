//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "completeLogin", sender: nil)
        TMDBClient.getRequestToken(completion: handleRequestTokenResponse(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        performSegue(withIdentifier: "completeLogin", sender: nil)
    }
    
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
            DispatchQueue.main.async {
                TMDBClient.postLogin(
                    username: self.emailTextField.text ?? "",
                    password: self.passwordTextField.text ?? "",
                    completion: self.handleLoginResponsecompletion(success:error:)
                )
            }
        }
    }
    
    func handleLoginResponsecompletion(success: Bool, error: Error?) {
        if success {
            TMDBClient.createSessionId(completion: handleSessionResponsecompletion(success:error:))
            print(TMDBClient.Auth.requestToken)
        } else {
            print(error!)
        }
    }
    
    func handleSessionResponsecompletion(success: Bool, error: Error?) {
        if success {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
                print("Session succesfully!!!")
                print(TMDBClient.Auth.sessionId)
            }
        }  else {
            print(error!)
        }
    }
}
