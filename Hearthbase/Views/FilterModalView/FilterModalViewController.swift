//
//  FilterModalViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 19/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit

class FilterModalViewController: UIViewController {

    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var modalView: UIView!
    
    @IBOutlet weak var pickerLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var manaSlider: UISlider!
    @IBOutlet weak var attackSlider: UISlider!
    @IBOutlet weak var defenseSlider: UISlider!
    
    var pickerViewData = [String]() {
        didSet {
            pickerView?.reloadAllComponents()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.layer.cornerRadius = 16
        modalView.layer.masksToBounds = true
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerViewData = CardClass.allCases.map({ (c) -> String in
            c.rawValue
        })
    }
    

    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didChangSegmentedControl(_ sender: Any) {
        pickerViewData = dataSourceFor(segmentedControl: sender as? UISegmentedControl)
        update(label: pickerLabel, basedOn: sender as? UISegmentedControl)
    }
    
}

extension FilterModalViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return pickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    
}

extension FilterModalViewController {
    
    func dataSourceFor(segmentedControl: UISegmentedControl?) -> [String] {
        
        guard let segmentedControl = segmentedControl else {
            return [String]()
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let data = CardClass.allCases.map({ (c) -> String in
                c.rawValue
            })
            
            return data
            
        case 1:
            let data = Type.allCases.map({ (c) -> String in
                c.rawValue
            })
            
            return data
        case 2:
            let data = Quality.allCases.map({ (c) -> String in
                c.rawValue
            })
            
            return data
        case 3:
            let data = Race.allCases.map({ (c) -> String in
                c.rawValue
            })
            
            return data
            
        default:
            print("Segmented Control index inválido")
            return [String]()
        }
        
    }
    
    func update(label: UILabel, basedOn segmented: UISegmentedControl?) {
        
        guard let segmentedControl = segmentedControl else {
            return
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            label.text = "Classe"
        case 1:
            label.text = "Tipo"
        case 2:
            label.text = "Qualidade"
        case 3:
            label.text = "Raça"
        default:
            print("Segmented Control index inválido")
        
        }
        
    }

}
