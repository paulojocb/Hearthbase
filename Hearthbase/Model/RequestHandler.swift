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
    
    func requestData() {
        
        print("Requesting Data")
        
        let url = URL(string: "https://omgvamp-hearthstone-v1.p.mashape.com/cards/races/Demon")
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
                let result = try decoder.decode([CardModel].self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.didReceiveData(data: result)
                }
            } catch {
                print(error)
            }
            
            
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
    }
    
    private func handlerError(error: Error) {
        
    }
    
}
