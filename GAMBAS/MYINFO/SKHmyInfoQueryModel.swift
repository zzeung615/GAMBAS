//
//  SKHmyInfoQueryModel.swift
//  GAMBAS
//
//  Created by 신경환 on 2020/09/22.
//  Copyright © 2020 TJ. All rights reserved.
//

import Foundation

protocol SKHmyInfoQueryModelProtocol: class {
    func itemDownloaded(items: NSArray)
}

class QueryModel:NSObject {
    
    var delegate: SKHmyInfoQueryModelProtocol!
    
    func downloadItems(seq: String) {
        var urlPath = "http://localhost:8080/gambas/gambas_query_ios.jsp?uSeqno=\(seq)"
        
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print(urlPath)
        let url: URL = URL(string: urlPath)!

        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil {
                print("failed to download data")
            } else {
                print("Data is downloaded")
                self.parseJSON(data!)
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data) {
        var jsonResult = NSArray()
        
        do {
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        var jsonElement = NSDictionary()
        let locations = NSMutableArray()
        
        for i in 0..<jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let query = SKHmyInfoModel()
            
            if let name = jsonElement["name"] as? String,
               let email = jsonElement["birth"] as? String,
               let phone = jsonElement["phone"] as? String,
               let image = jsonElement["image"] as? String,
               let interest = jsonElement["interest"] as? String {
                
                query.ivSKHname = name
                query.ivSKHemail = email
                query.ivSKHphone = phone
                query.ivSKHimage = image
                query.ivSKHinterestCategory = interest
            }
        
            locations.add(query)
        }
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownloaded(items: locations)
        })
    }

}

