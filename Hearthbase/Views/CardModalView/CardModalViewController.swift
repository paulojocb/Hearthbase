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

    @IBOutlet weak var backdropView: UIView!
   
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.layer.cornerRadius = 16.0
        modalView.layer.masksToBounds = true
        
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

