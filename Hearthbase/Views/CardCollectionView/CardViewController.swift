//
//  CardViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 17/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

enum CardViewControllerContext: String {
    case home = "Hearthbase"
    case myCards = "Minhas Cartas"
}

class CardViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewActivity: UIActivityIndicatorView!
    
    var context: CardViewControllerContext = .home
    let requestHandler = RequestHandler()

    var cards = [Any]()
    
    convenience init(withContext: CardViewControllerContext? = nil) {
        self.init()
        guard let withContext = withContext else {return}
        self.context = withContext
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        switch context {
        case .home:
            requestHandler.delegate = self
            requestHandler.requestData()
        case .myCards:
            loadFromCoreData()
        }
        
        setupNavbar()
        setup(collectionView)
        
    
    }
    
    @objc func didPressMinhasCartas() {
        let controller = UIStoryboard(name: "CardViewController", bundle: nil).instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
        controller.context = .myCards
        navigationController?.pushViewController(controller, animated: true)
    }
        
    @IBAction func didPressFiltrar(_ sender: Any) {
        let controller = UIStoryboard(name: "FilterModalViewController", bundle: nil).instantiateViewController(withIdentifier: "FilterModalViewController") as! FilterModalViewController
        present(controller, animated: true, completion: nil)
    }
    
    func setup(_ collection: UICollectionView?) {

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")

    }
    
    func setupNavbar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.title = context.rawValue
        
        if context == .home {
            navigationItem.largeTitleDisplayMode = .always
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Minhas cartas", style: .plain, target: self, action: #selector(didPressMinhasCartas))
        } else {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self as? UISearchBarDelegate
        
        navigationItem.searchController = searchController
    }
    
    func loadFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardCD")
        
        do {
            cards = try managedContext.fetch(fetchRequest)
            collectionViewActivity.stopAnimating()
            collectionViewActivity.alpha = 0
        } catch let error as NSError{
            print(error)
        }
    }
    
}

extension CardViewController: RequestHandlerDelegate {
    
    func didReceiveData(data: [CardModel]) {
        cards = data
        collectionView.reloadData()
        collectionViewActivity.stopAnimating()
        collectionViewActivity.alpha = 0
    }
    
    func didFetchFail(error: Error) {
        
    }
    
}

extension CardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellAcross : CGFloat = 2
        let spaceBetween: CGFloat = 20
        let ratio : CGFloat = 1.58
        
        let width = (collectionView.bounds.width - spaceBetween) / cellAcross
        let cellSize = CGSize(width: width, height: width * ratio)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CardCollectionViewCell
        
        if context == .home {
            cell.configCellWith(card: cards[indexPath.row] as! CardModel)
        } else {
            cell.configCellWith(card: cards[indexPath.row] as! NSManagedObject)
        }
       
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        let controller = UIStoryboard(name: "CardModalViewController", bundle: nil).instantiateViewController(withIdentifier: "CardModalViewController") as! CardModalViewController
        
        controller.card = cell.card
        
        present(controller, animated: true, completion: nil)
        
    }
    
}
