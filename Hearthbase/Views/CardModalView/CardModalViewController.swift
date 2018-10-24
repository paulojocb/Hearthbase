//
//  CardModalViewController.swift
//  Hearthbase
//
//  Created by Paulo José on 18/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import UIKit
import CoreData

// Struct para preparar valores de referência para a CustomTransition
struct CustomTransitionInfo {
    var modalFrame: CGRect
    var imageFrame: CGRect
}

protocol CardModalActionDelegate {
    func didFinishedSaving(card: Card)
    func didFinishedRemoving(card: Card)
}

class CardModalViewController: UIViewController {
    
    var customTransitionInfo: CustomTransitionInfo! // Variável para reter valores de referência para a CustomTransition
    var transitionState: TransitionState = .dismiss
    
    var shadowLayer: CAShapeLayer!

    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var coreDataHandler : CoreDataHandler!
    var card: Card!
    var isCardSaved = false
    
    var delegate : CardModalActionDelegate!
    
    // Init para preparar view para a custom transition
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        coreDataHandler = CoreDataHandler()
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addShadow(to: modalView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        setInitialState()
        addRoundedBorder(to: modalView)
        buildView()
    }
    
    
    @IBAction func didPressFechar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didPressAction(_ sender: Any) {
        
        var alertController : UIAlertController!
        var completion: ((UIAlertAction) -> Void)? = nil
        
        if !isCardSaved {
            if coreDataHandler.save(card) {
                alertController = UIAlertController(title: "Adicionada", message: "A carta \(String(describing: card.name!)) foi adicionada as suas cartas", preferredStyle: .alert)
                completion = { (action) in
                    self.dismiss(animated: true, completion: nil)
                    self.delegate.didFinishedSaving(card: self.card)
                }
            } else {
                alertController = UIAlertController(title: "Erro", message: "Não foi possível remover a carta \(String(describing: card.name!))", preferredStyle: .alert)
            }
        } else {
            if coreDataHandler.remove(card) {
                alertController = UIAlertController(title: "Removida", message: "A carta \(String(describing: card.name!)) foi removida das suas cartaas", preferredStyle: .alert)
                completion = { (action) in
                    self.dismiss(animated: true, completion: nil)
                    self.delegate.didFinishedRemoving(card: self.card)
                }
            } else {
                alertController = UIAlertController(title: "Erro", message: "Não foi possível remover a carta \(String(describing: card.name!))", preferredStyle: .alert)
            }
        }
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: completion)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK : Extensão de Delegates e métodos de CustomTransition
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
            let toVC = toViewController
            else { return }
        
        transitionState = transitionState == .dismiss ? .present : .dismiss
        
        if transitionState == .present {
            containerView.addSubview(toVC.view)
            setInitialState()
        }
        
        animate(with: transitionState, using: transitionContext)
        
    }
    
}


// MARK: Extensão de métodos da ViewController
extension CardModalViewController {
    
    func addShadow(to view: UIView) {
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
            
            view.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    
    func addRoundedBorder(to view: UIView) {
        view.layer.cornerRadius = 16.0
        view.layer.masksToBounds = true
    }
    
    
    func buildView() {
        imageView.image = card.image
        nameLabel.text = card.name ?? "Nome desconhecido"
        attackLabel.text = card.attack != nil ? "\(card.attack!)" : "Desconhecido"
        defenseLabel.text = card.defense != nil ? "\(card.defense!)" : "Desconhecido"
        descriptionLabel.text = card.info ?? "Sem descrição"
        
        if isCardSaved {
            actionButton.setTitle("Remover carta", for: .normal)
        } else {
            actionButton.setTitle("Adicionar carta", for: .normal)
        }
    }
    
    //Função para setar a view para o estado inicial da custom transition
    func setInitialState() {
        modalView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0)
    }
    
    
    //Função para setar a view para o estado final da custom transition
    func setFinalState() {
        modalView.frame = CGRect(x: 16, y: 200, width: UIScreen.main.bounds.width - 32, height: 400)
        imageView.frame = CGRect(x: 200, y: 100, width: 144, height: 228)
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    
    //Função para animar a custom transition
    func animate(with state: TransitionState, using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
            state == .present ? self.setFinalState() : self.setInitialState()
        }) { (finished) in
            transitionContext.completeTransition(true)
        }
    }
    
}

