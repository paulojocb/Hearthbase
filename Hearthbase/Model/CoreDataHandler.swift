//
//  CoreDataHandler.swift
//  Hearthbase
//
//  Created by Paulo José on 23/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHandler {
    var appDelegate : AppDelegate!
    var managedContext : NSManagedObjectContext!
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        self.appDelegate = appDelegate
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func save(_ card: Card) -> Bool {
        
        let imagePath = saveToFileManager(image: card.image, with: card.id ?? "")
    
        let entity = NSEntityDescription.entity(forEntityName: "CardCoreData", in: managedContext)!
        let cardToSave = NSManagedObject(entity: entity, insertInto: managedContext)
        
        print(imagePath ?? "")
        
        cardToSave.setValue(card.id, forKey: "id")
        cardToSave.setValue(card.name, forKeyPath: "name")
        cardToSave.setValue(card.attack, forKeyPath: "attack")
        cardToSave.setValue(card.defense, forKeyPath: "defense")
        cardToSave.setValue(imagePath ?? "", forKeyPath: "image")
        cardToSave.setValue(card.info, forKey: "info")
        
        do {
            try managedContext.save()
            print("\(card.name!) salvo com sucesso")
            return true
        } catch let error as NSError {
            print("Não foi possível salvar. \(error), \(error.userInfo)")
            return false
        }
        
    }
    
    func load(cardName: String = "", on entity: String, with filter: Filter! = nil) -> [NSManagedObject]! {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        
        do {
            let fetchedCards = try managedContext.fetch(fetchRequest)
            
            let filterFetchedCards = fetchedCards.filter { (card) -> Bool in
                guard cardName != "" else {return true}
                let name = card.value(forKeyPath: "name") as? String ?? ""
                return name.lowercased().contains(cardName.lowercased())
            }
            
            if filter == nil {
                return filterFetchedCards
            } else {
                
                return filterFetchedCards.filter { $0.value(forKeyPath: "attack") as? Int ?? 0 > filter.minAttack && $0.value(forKeyPath: "defense") as? Int ?? 0 > filter.minDefense }
            }
           
        } catch {
            return nil
        }
    }
    
    func remove(_ card: Card) -> Bool {
        let cardsSaved = load(on: "CardCoreData") ?? [NSManagedObject]()
        
        let cardToDelete = cardsSaved.filter { $0.value(forKeyPath: "id") as? String == card.id }.first! 
        
        managedContext.delete(cardToDelete)
        
        do {
            try managedContext.save()
            return true
        } catch {
            return false
        }
    }
    
    func saveToFileManager(image: UIImage!, with id: String) -> String! {
        let fileManager = FileManager.default
        let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var imagePathToSave: String!
        
        if let image = image {
            if let data = image.pngData() {
                let url =  path.appendingPathComponent("\(String(describing: id)).png")
                fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
                imagePathToSave = url.path
            }
        }
        
        return imagePathToSave
    }
    
    func isSaved(card: Card) -> Bool{
        let cardsSaved = load(on: "CardCoreData") ?? [NSManagedObject]()
        return cardsSaved.filter { $0.value(forKeyPath: "id") as? String == card.id }.count == 0 ? false : true
    }
}
