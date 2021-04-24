//
//  ViewController.swift
//  RNIntegration
//
//  Created by Isaac on 24/04/21.
//

import UIKit
import React

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func BtnGoReactView(_ sender: Any) {
        
        let jsCodeLocation = URL(string: "http://localhost:8081/index.bundle?platform=ios")
        let rootView = RCTRootView(
            bundleURL: jsCodeLocation!,
            moduleName: "RNIntegration",
            initialProperties: nil,
            launchOptions: nil)
    
        let reactNativeVC = UIViewController()
        reactNativeVC.view = rootView
        reactNativeVC.modalPresentationStyle = .fullScreen
        present(reactNativeVC, animated: true)
    }
}

