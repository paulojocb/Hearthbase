//
//  FilterModalViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 19/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit

protocol FilterModalViewControllerDelegate {
    func didFinishEditingFilter(filter: Filter)
}

class FilterModalViewController: UIViewController {
    
    var transitionState : TransitionState = .dismiss
    var modalHeight = UIScreen.main.bounds.height * 0.8

    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var modalView: UIView!
    
    @IBOutlet weak var pickerLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var attackSlider: UISlider!
    @IBOutlet weak var defenseSlider: UISlider!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    
    var filter: Filter!
    
    var delegate : FilterModalViewControllerDelegate!
    
    var pickerViewData = [String]() {
        didSet {
            filter.parameter = pickerViewData[0]
            pickerView?.reloadAllComponents()
            print(filter)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        filter = Filter.init(parameterType: .cardClass, parameter: CardClass.cavaleiroDaMorte.rawValue, minAttack: 0, minDefense: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        setViewForInitialState()
        
        modalView.layer.cornerRadius = 16
        modalView.layer.masksToBounds = true
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerViewData = CardClass.allCases.map({ (c) -> String in
            c.rawValue
        })
    
        backdropView.addGestureRecognizer(UITapGestureRecognizer(target: self
            , action: #selector(didPressBackdropView)))
    }
    
    @objc func didPressBackdropView() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressPesquisar(_ sender: Any) {
        delegate?.didFinishEditingFilter(filter: filter!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didChangSegmentedControl(_ sender: Any) {
        pickerViewData = dataSourceFor(segmentedControl: sender as? UISegmentedControl)
        update(label: pickerLabel, basedOn: sender as? UISegmentedControl)
        updateFilter(with: sender as? UISegmentedControl)
    }
    
    @IBAction func didChangAttackSlider(_ sender: Any) {
        let slider = sender as? UISlider
        attackLabel.text = "\(String(describing: Int(slider?.value ?? 0)))"
        filter.minAttack = Int(slider?.value ?? 0)
    }
    
    @IBAction func didChangeDefenseSlider(_ sender: Any) {
        let slider = sender as? UISlider
        defenseLabel.text = "\(String(describing: Int(slider?.value ?? 0)))"
        filter.minDefense = Int(slider?.value ?? 0)
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filter.parameter = pickerViewData[pickerView.selectedRow(inComponent: component)]
        print(filter)
    }
    
}

extension FilterModalViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: .to)
        
        guard let toVC = toViewController else { return }
        
        transitionState = transitionState == .dismiss ? .present : .dismiss
        
        if transitionState == .present {
            containerView.addSubview(toVC.view)
            setViewForInitialState()
        }
        
        animate(with: transitionState, using: transitionContext)
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
    
    func updateFilter(with segment: UISegmentedControl!) {
        
        guard let segment = segment else {
            return
        }
        
        switch segment.selectedSegmentIndex {
        case 0:
            filter.parameterType = .cardClass
        case 1:
            filter.parameterType = .type
        case 2:
            filter.parameterType = .quality
        case 3:
            filter.parameterType = .race
        default:
            print("SegmentedIndex invalido")
        }
    }
    
    func setViewForInitialState() {
        modalView.frame.origin.y += modalHeight
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0)
    }
    
    func setViewForFinalState() {
        modalView.frame.origin.y -= modalHeight
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    func animate(with state: TransitionState, using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
            state == .present ? self.setViewForFinalState(): self.setViewForInitialState()
        }) { (finished) in
            transitionContext.completeTransition(true)
        }
    }
    
}
