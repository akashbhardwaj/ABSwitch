//
//  ViewController.swift
//  ABCustomSwitch
//
//  Created by Akash Bhardwaj on 17/11/18.
//  Copyright © 2018 Akash Bhardwaj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var customSwitch: ABSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwitch()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func setupSwitch () {
        customSwitch.config(onImage: UIImage(named: "onImage")!, offImage: UIImage(named: "offImage")!) { (isOn) in
            print(isOn)
        }
    }

}

