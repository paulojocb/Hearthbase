//
//  RequestHandler.swift
//  Hearthbase
//
//  Created by Paulo José on 17/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import Foundation

protocol RequestHandlerDelegate {
    func didReceiveData(data: [CardModel])
    func didFetchFail(error: Error)
}

class RequestHandler: NSObject {
    
    var delegate: RequestHandlerDelegate?
    
    func request(card: String = "", with filter: Filter! = nil) {
        
        print("Requesting Data")
        
        let params = card == "" ? "/classes/Neutral" : "/search/\(card)"
 
        let url = URL(string: "https://omgvamp-hearthstone-v1.p.mashape.com/cards\(params)?locale=ptBR")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.addValue("I8kb0E2twMmshvMxzbXnNl36NTSHp1KDahRjsn5ZjlfnDRfM5h", forHTTPHeaderField: "X-Mashape-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            
            guard err == nil else {
                self.delegate?.didFetchFail(error: err!)
                return
            }
            
            guard let data = data else {
                print("ta nil")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                var result = try decoder.decode([CardModel].self, from: data)
                
                if filter != nil {
                    result = result.filter { $0.attack ?? 0 > filter.minAttack && $0.defense ?? 0 > filter.minDefense }
                }
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveData(data: result)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFetchFail(error: error)
                }

            }
            
            
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
    }
    
    private func handlerError(error: Error) {
        
    }
    
}
