//
//  ViewController.swift
//  ColorPicker
//
//  Created by Doolittle, Jonathan J on 2/2/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var RedSwitch: UISwitch!
    @IBOutlet weak var RedSlider: UISlider!
    @IBOutlet weak var GreenSwitch: UISwitch!
    @IBOutlet weak var GreenSlider: UISlider!
    @IBOutlet weak var BlueSwitch: UISwitch!
    @IBOutlet weak var BlueSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorView.layer.borderWidth = 5
        ColorView.layer.borderColor = UIColor.black.cgColor
        ColorView.layer.cornerRadius = 25
        updateColor()
    }
    

    @IBAction func SwitchChanged(_ sender: UISwitch) {
        updateColor()
    }
    
    @IBAction func SliderChanged(_ sender: Any) {
        updateColor()
    }
    
    @IBAction func ResetUi(_ sender: Any) {
        RedSlider.value = 0.5
        BlueSlider.value = 0.5
        GreenSlider.value = 0.5
        RedSwitch.isOn = false
        BlueSwitch.isOn = false
        GreenSwitch.isOn = false
        updateColor()
    }
    
    func updateColor() {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        
        if RedSwitch.isOn {
            red = CGFloat(RedSlider.value)
        }
        
        if GreenSwitch.isOn {
            green = CGFloat(GreenSlider.value)
        }
        
        if BlueSwitch.isOn {
            blue = CGFloat(BlueSlider.value)
        }
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        ColorView.backgroundColor = color
        UpdateControls()
    }
    
    func UpdateControls() {
        RedSlider.isEnabled = RedSwitch.isOn
        GreenSlider.isEnabled = GreenSwitch.isOn
        BlueSlider.isEnabled = BlueSwitch.isOn
    }
    
}

