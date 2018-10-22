//
//  CardModalViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 18/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

struct CustomTransitionInfo {
    var modalFrame: CGRect
    var imageFrame: CGRect
}

class CardModalViewController: UIViewController {
    
    var customTransitionInfo: CustomTransitionInfo!
    var isPresenting = false
    
    var shadowLayer: CAShapeLayer!

    @IBOutlet weak var backdropView: UIView!
   
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var card: Card!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.masksToBounds = false
            
            shadowLayer.path = UIBezierPath(roundedRect: modalView.bounds, cornerRadius: 10).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            modalView.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        modalView.layer.cornerRadius = 16.0
        modalView.layer.masksToBounds = true
        
        modalView.layer.shadowColor = UIColor.black.cgColor
        modalView.layer.shadowPath = UIBezierPath(rect: modalView.bounds).cgPath
        modalView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        modalView.layer.shadowOpacity = 0.2
        modalView.layer.shadowRadius = 3
        modalView.layer.masksToBounds = false
        
        buildView()
        // Do any additional setup after loading the view.
    }
    
    func buildView() {
        imageView.image = card.image
        nameLabel.text = card.name ?? "Nome desconhecido"
        attackLabel.text = card.attack != nil ? "\(card.attack!)" : "Desconhecido"
        defenseLabel.text = card.defense != nil ? "\(card.defense!)" : "Desconhecido"
        descriptionLabel.text = card.info ?? "Sem descrição"
    }
    
    @IBAction func didPressFechar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressAction(_ sender: Any) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "CardCD", in: managedContext)!
        
        let card = NSManagedObject(entity: entity, insertInto: managedContext)
        
        card.setValue(self.card.name, forKeyPath: "name")
        card.setValue(self.card.attack, forKeyPath: "attack")
        card.setValue(self.card.defense, forKeyPath: "defense")
        card.setValue(self.card.image.pngData(), forKeyPath: "image")
        card.setValue(self.card.info, forKey: "info")
        
        do {
            try managedContext.save()
            print("\(self.card.name!) salvo com sucesso")
        } catch let error as NSError {
            print("Não foi possível salvar. \(error), \(error.userInfo)")
        }
    
    }
}

extension CardModalViewController: UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: .to)
        
        guard
            let toVC = toViewController,
            let customInfo = customTransitionInfo
            else { return }
        
        isPresenting = !isPresenting
        
        if isPresenting {
            containerView.addSubview(toVC.view)
            
            modalView.alpha = 0
            
            modalView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            
            print(modalView.frame)
            
            self.backdropView.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.modalView.frame = CGRect(x: 16, y: 200, width: UIScreen.main.bounds.width - 32, height: 400)
                self.imageView.frame = CGRect(x: 200, y: 100, width: 144, height: 228)
                self.modalView.alpha = 1
                self.backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
            
        } else {
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.modalView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.modalView.alpha = 0
                self.backdropView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
            
        }
    }
    
    

    
}

