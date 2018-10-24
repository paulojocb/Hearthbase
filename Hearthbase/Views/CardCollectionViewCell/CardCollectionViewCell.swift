//
//  CardCollectionViewCell.swift
//  Hearthbase
//
//  Created by Paulo José on 17/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

enum CellActivityState {
    case fetching
    case noImage
    case imageLoaded
}


enum ActivityState {
    case animating
    case stopped
}


class CardCollectionViewCell: UICollectionViewCell {
    
    var card: Card!
    
    var shadowLayer: CAShapeLayer!
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var noCardLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addRoundedBorder(to: roundedView)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configCellWith(card: NSManagedObject) {
        setCell(for: .imageLoaded)
        
        titleLabel.text = card.value(forKeyPath: "name") as? String
        imageView.image = getImageFrom(urlString: card.value(forKey: "image") as? String ?? "")
        
        self.card = Card.init(
            id: card.value(forKeyPath: "id") as? String,
            name: card.value(forKeyPath: "name") as? String,
            attack: card.value(forKeyPath: "attack") as? Int,
            defense: card.value(forKeyPath: "defense") as? Int,
            image: getImageFrom(urlString: card.value(forKey: "image") as? String ?? ""),
            info: card.value(forKeyPath: "info") as? String
        )
    }
    
    
    func configCellWith(card: CardModel) {
        titleLabel.text = card.name
        if card.image != nil {
            set(activityIndicator, for: .animating)
            self.noCardLabel.alpha = 0
            imageView.image = nil
            donwload(from: card.image)
            setCell(for: .fetching)
        } else {
            setCell(for: .noImage)
        }
        self.card = Card.init(id: card.id, name: card.name, attack: card.attack, defense: card.defense, image: nil, info: card.info)
    }
    
    
    func getImageFrom(urlString: String = "") -> UIImage! {
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: urlString) {
           let image = UIImage(contentsOfFile: urlString)
            return image
        }
        
        return nil

    }
    
    
    func donwload(from link: String, content mode: ContentMode = .scaleAspectFit) {
        let url = URL(string: "https" + link.dropFirst(4))!

        let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, err == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async {
                        self.setCell(for: .noImage)
                    }
                    return
            }
            DispatchQueue.main.async {
                self.setCell(for: .imageLoaded)
                
                self.card.image = image
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
    }
    
    
    func addRoundedBorder(to view: UIView) {
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.masksToBounds = false
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            view.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    
    func setCell(for state: CellActivityState) {
        switch state {
        case .fetching:
            set(activityIndicator, for: .animating)
            noCardLabel.alpha = 0
        case .imageLoaded:
            set(activityIndicator, for: .stopped)
            noCardLabel.alpha = 0
        case .noImage:
            imageView.image = nil
            set(activityIndicator, for: .stopped)
            noCardLabel.alpha = 1
        }
    }
    
    
    func set(_ activityIndicator: UIActivityIndicatorView , for state: ActivityState) {
        switch state {
        case .animating:
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1
        case .stopped:
            activityIndicator.stopAnimating()
            activityIndicator.alpha = 0
        }
    }
    
}
