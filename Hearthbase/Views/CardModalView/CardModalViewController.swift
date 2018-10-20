//
//  CardModalViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 18/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

class CardModalViewController: UIViewController {
    
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

