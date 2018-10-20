//
//  CardCollectionViewCell.swift
//  Hearthbase
//
//  Created by Paulo José on 17/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

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
            
            roundedView.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        noCardLabel.alpha = 0
        
//        roundedView.layer.addRoundedCorner(radius: 10)

    }
    
    func configCellWith(card: NSManagedObject) {
        titleLabel.text = card.value(forKeyPath: "name") as? String
        imageView.image = UIImage(data: (card.value(forKeyPath: "image") as? Data)!)
        activityIndicator.stopAnimating()
        activityIndicator.alpha = 0
    }
    
    func configCellWith(card: CardModel) {
        titleLabel.text = card.name
        if card.image != nil {
            activityIndicator.startAnimating()
            activityIndicator.alpha = 1
            self.noCardLabel.alpha = 0
            imageView.image = nil
            donwload(from: card.image)
        }
        self.card = Card.init(name: card.name, attack: card.attack, defense: card.defense, image: nil, info: card.info)
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
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.alpha = 0
                        self.noCardLabel.alpha = 1
                    }
                    return
            }
            DispatchQueue.main.async {
                self.card.image = image
                self.imageView.image = image
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
                self.noCardLabel.alpha = 0
                
                self.imageView.contentMode = .scaleAspectFill
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
    }

}
