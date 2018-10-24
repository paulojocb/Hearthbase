//
//  CardViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 17/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

enum CollectionViewActivityState {
    case fetching
    case empty
    case dataLoaded
}

enum CardViewControllerContext: String {
    case home = "Hearthbase"
    case myCards = "Minhas Cartas"
}

class CardViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewActivity: UIActivityIndicatorView!
    @IBOutlet weak var noCardsLabel: UILabel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var context: CardViewControllerContext = .home //Sinaliza o context(home ou minhas cartas) que a controller tá sendo usada. Por default, é home
    let requestHandler = RequestHandler() // Objeto responsável por manipular as request da API
    var filteredCards = [Any]()
    var cards = [Any]() // Este array pode assumir a forma de CardModal e NSManagerObject, dependendo do contexto da Controller
    var coreDataHandler : CoreDataHandler!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setView(for: .fetching)
        coreDataHandler = CoreDataHandler()
        
        //Dependendo do contexto, o array cards será preenchido com dados da API ou do CoreData
        switch context {
        case .home:
            setView(for: .fetching)
            requestHandler.delegate = self
            requestHandler.request()
        case .myCards:
            cards = coreDataHandler.load(on: "CardCoreData") ?? [NSManagedObject]()
            cards.count > 0 ? setView(for: .dataLoaded) : setView(for: .empty)
        }
        
        //Métodos de configuração da UI
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
        controller.modalPresentationStyle = .custom
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
}

// MARK: Métodos do delegate do Request Handler
extension CardViewController: RequestHandlerDelegate {
    
    func didReceiveData(data: [CardModel]) {
        cards = data
        collectionView.reloadData()
        cards.count > 0 ? setView(for: .dataLoaded) : setView(for: .empty)
    }
    
    
    func didFetchFail(error: Error) {
        setView(for: .empty)
    }
    
}

extension CardViewController : FilterModalViewControllerDelegate {
    
    func didFinishEditingFilter(filter: Filter) {
        if context == .home {
            cards = [Card]()
            collectionView.reloadData()
            setView(for: .fetching)
            requestHandler.request(with: filter)
        } else if context == .myCards{
            cards = coreDataHandler.load(on: "CardCoreData", with: filter) ?? [NSManagedObject]()
            cards.count > 0 ? setView(for: .dataLoaded) : setView(for: .empty)
            collectionView.reloadData()
        }
    }
    
}

extension CardViewController : UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        filteredCards.count == 0 && !(searchController.searchBar.text?.isEmpty ?? true) ? setView(for: .empty) : setView(for: .dataLoaded)
        collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        setView(for: .dataLoaded)
    }
    
}

// MARK: Métodos do delegate e dataSource da CollectionView
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
        if isFiltering() {
            return filteredCards.count
        }
        
        return cards.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CardCollectionViewCell
        
        if context == .home {
            isFiltering() ? cell.configCellWith(card: filteredCards[indexPath.row] as! CardModel) : cell.configCellWith(card: cards[indexPath.row] as! CardModel)
        } else {
            isFiltering() ? cell.configCellWith(card: filteredCards[indexPath.row] as! NSManagedObject) : cell.configCellWith(card: cards[indexPath.row] as! NSManagedObject)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        let controller = UIStoryboard(name: "CardModalViewController", bundle: nil).instantiateViewController(withIdentifier: "CardModalViewController") as! CardModalViewController
        
        controller.card = cell.card
        
        let modalFrame = cell.roundedView.frame
        let imageFrame = cell.imageView.frame
        
        controller.delegate = self
        controller.isCardSaved = coreDataHandler.isSaved(card: cell.card)

        controller.customTransitionInfo = CustomTransitionInfo.init(modalFrame: modalFrame, imageFrame: imageFrame)
        controller.modalPresentationStyle = .custom
        present(controller, animated: true, completion: nil)
    }
    
}

// MARK: Extensão de métodos da controller
extension CardViewController {
    
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
    
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if context == .home {
            let cardsToFilter = cards as! [CardModel]
            filteredCards = cardsToFilter.filter({ (card) -> Bool in
                return card.name.lowercased().contains(searchText.lowercased())
            })
        } else if context == .myCards {
            let cardsToFilter = cards as! [NSManagedObject]
            filteredCards = cardsToFilter.filter({ (card) -> Bool in
                let cardName = card.value(forKeyPath: "name") as? String ?? ""
                return cardName.lowercased().contains(searchText.lowercased())
            })
        }
    }
    
    
    func setView(for state: CollectionViewActivityState) {
        switch state {
        case .fetching:
            noCardsLabel.alpha = 0
            collectionViewActivity.startAnimating()
            collectionViewActivity.alpha = 1
        case .empty:
            noCardsLabel.alpha = 1
            collectionViewActivity.stopAnimating()
            collectionViewActivity.alpha = 0
        case .dataLoaded:
            noCardsLabel.alpha = 0
            collectionViewActivity.stopAnimating()
            collectionViewActivity.alpha = 0
        }
    }
    
}

extension CardViewController : CardModalActionDelegate {
    
    func didFinishedSaving(card: Card) {
        if context == .myCards {
            cards = coreDataHandler.load(on: "CardCoreData") ?? [NSManagedObject]()
            cards.count > 0 ? setView(for: .dataLoaded) : setView(for: .empty)
            collectionView.reloadData()
        }
        
    }
    
    
    func didFinishedRemoving(card: Card) {
        if context == .myCards {
            cards = coreDataHandler.load(on: "CardCoreData") ?? [NSManagedObject]()
            cards.count > 0 ? setView(for: .dataLoaded) : setView(for: .empty)
            collectionView.reloadData()
        }
    }
}
