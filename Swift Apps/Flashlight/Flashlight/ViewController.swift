//
//  ViewController.swift
//  Flashlight
//
//  Created by Doolittle, Jonathan J on 1/12/22.
//

import UIKit

class ViewController: UIViewController {

    var lightOn = true
    
    @IBOutlet weak var lightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUi()
        // Do any additional setup after loading the view.
    }

    fileprivate func updateUi() {
        lightOn.toggle()
        
        if lightOn {
            lightButton.setTitle("Off", for: .normal)
            view.backgroundColor = .white
        } else {
            lightButton.setTitle("On", for: .normal)
            view.backgroundColor = .black
        }
    }
    
    @IBAction func ButtonPressed(_ sender: Any) {
        updateUi()
    }
    
}

