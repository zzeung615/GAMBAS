//
//  UserPriorityQueryModel.swift
//  ProjectDraw
//
//  Created by SSB on 10/09/2020.
//  Copyright © 2020 SSB. All rights reserved.
//

import Foundation

class UCategoryQueryModel: NSObject{
    var urlPath = "http://localhost:8080/gambas/getUserCategoryList.jsp"
    
    func getUserCategoryList(uSeqno: Int, completion: @escaping ([String]?)->()) {
        let urlAdd = "?seq=\(uSeqno)"
        urlPath += urlAdd
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) {(data, respone, error) in
            if error != nil {
                completion(nil)
            } else {
                completion(self.parseJSON2(data!))
            }
        }
        task.resume()
    }
    
    func parseJSON2(_ data: Data) -> [String] {
        var jsonResult = String(data: data, encoding: .utf8)!
        jsonResult = jsonResult.replacingOccurrences(of: "\r\n", with: "")
        let splitedList = jsonResult.components(separatedBy: ",")
        var resultList: [String] = []
        for i in 0..<splitedList.count {
            resultList.append(splitedList[i])
        }
        
        return resultList
    }
    
    
}