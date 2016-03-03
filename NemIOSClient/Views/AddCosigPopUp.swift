//
//  AddCosigPopUp.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 23.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

protocol AddCosigPopUptDelegate
{
    func addCosig(publicKey :String)
}

class AddCosigPopUp: AbstractViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var publicKey: NEMTextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicKey.placeholder = "   " + "INPUT_PUBLIC_KEY".localized()
        _setSuggestions()
        saveBtn.setTitle("ADD_COSIGNATORY".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func _setSuggestions() {
        var suggestions :[NEMTextField.Suggestion] = []
        let dataManager = CoreDataManager()
        
        for wallet in dataManager.getWallets() {
            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
            let publicKey = KeyGenerator.generatePublicKey(privateKey!)
            let account_address = AddressGenerator.generateAddress(publicKey)
            
            var find = false
            
            for suggestion in suggestions {
                if suggestion.key == account_address {
                    find = true
                    break
                }
            }
            
            if !find {
                var sugest = NEMTextField.Suggestion()
                
                sugest.key = account_address
                sugest.value = publicKey
                suggestions.append(sugest)
                
                sugest.key = publicKey
                sugest.value = publicKey
                suggestions.append(sugest)

            }
            
            find = false
            
            for suggestion in suggestions {
                if suggestion.key == wallet.login {
                    find = true
                    break
                }
            }
            
            if !find {
                var sugest = NEMTextField.Suggestion()
                
                sugest.key = wallet.login
                sugest.value = publicKey
                suggestions.append(sugest)
            }
        }
        
        if AddressBookManager.isAllowed ?? false {
            for contact in AddressBookManager.contacts {
                var name = ""
                if contact.givenName != "" {
                    name = contact.givenName
                }
                
                if contact.familyName != "" {
                    name += " " + contact.familyName
                }
                
                for email in contact.emailAddresses{
                    if email.label == "NEM" {
                        let account_address = email.value as? String ?? " "
                        
                        var find = false
                        
                        for suggestion in suggestions {
                            if suggestion.key == account_address {
                                find = true
                                break
                            }
                        }
                        if !find {
                            var sugest = NEMTextField.Suggestion()
                            sugest.key = account_address
                            sugest.value = account_address
                            suggestions.append(sugest)
                        }
                        
                        find = false
                        
                        for suggestion in suggestions {
                            if suggestion.key == name {
                                find = true
                                break
                            }
                        }
                        if !find {
                            var sugest = NEMTextField.Suggestion()
                            sugest.key = name
                            sugest.value = account_address
                            suggestions.append(sugest)
                        }
                    }
                }
            }
        }
        
        publicKey.suggestions = suggestions
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func addCosig(sender: AnyObject) {
        if Validate.stringNotEmpty(publicKey.text) && Validate.hexString(publicKey.text!){
            (self.delegate as? AddCosigPopUptDelegate)?.addCosig(publicKey.text!)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}

