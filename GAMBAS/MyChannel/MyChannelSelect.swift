//
//  MyChannelSelect.swift
//  GAMBAS
//
//  Created by TJ on 2020/09/18.
//  Copyright © 2020 TJ. All rights reserved.
//

import Foundation

// 이 쿼리모델과 테이블뷰 연결해주는 프로토콜 하나 필요함.
// 프로토콜은 따로 스위프트 만들어서 써도 됨.
protocol MyChannelSelectProtocol: class {
    // 함수
    func itemDownload_myChannel(itemChannel: NSArray)
}

// 클래스 하나 필요하죠.
// NSObject : class type. 선언을 마음대로 할 수 있는 그림도 포함되는 class(object).
// NSObject - 모든 클래스 중에 가장 상위 클래스.
class MyChannelSelect: NSObject{
    
    var delegate: MyChannelSelectProtocol!
    var urlPath = "http://127.0.0.1:8080/gambas/" // 이거 실행하면 jsp 파일이 json 으로 만들어짐.
    
    // 우리가 실행할 함수
    func downloadItem_myChannel(userSeqno: String) {
        
        // "jsp" 뒤에 Get 방식으로 ? 물음표 뒤에 넣어줄 부분.
        // 만약 값이 한글일 경우, url 에러가 나기 때문에. (2바이트를 %a1uc어쩌고저쩌고로 바뀌어야함)
        let urlAdd = "MyChannelSelect.jsp?userSeqno=\(userSeqno)"
        // 완전한 url.
        urlPath += urlAdd
        // 한글 url encoding (utf8이랑 아무런 상관없음)
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print(urlPath)
        let url: URL = URL(string: urlPath)!
        
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil{ // '에러 코드가 있었다'라는 걸 의미
                print("Failed to download data")
               
            }else{
                print("Data is downloaded")
                /// -->> 파싱해야죠.
                self.parseJSON(data!)
               
            }
        }

        // 구동.
        task.resume()
     
    }
   
    
    func parseJSON(_ data: Data){
        // 제이슨은 기본적으로 어레이 값이니깐..
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray // 을 어레이 타입으로 바꾼다. (as! NSArray)
        }catch let error as NSError{
            print(error)
        }
        
        var jsonElement = NSDictionary()
        // NSArray : 배열은 Int다. String이다. 정해져있음. 따로 정해져있지 않고 전부 들어갈 때.
        // NSMutableArray : 나온지 얼마 안됨. (어레이는 만들어지면 추가, 삭제가 안되나, NSMutableArray 는 마음대로 추가삭제가 가능.)
        // 퍼포먼스 때문에 구분해서 씀.
        // let var의 차이정도라고 생각하면 되겠네.
        let locations = NSMutableArray()
        
        // 이제 제이슨 하나씩 가져오면 되죠.
        for i in 0..<jsonResult.count{
            jsonElement = jsonResult[i] as! NSDictionary
            // DBModel 형태로 바꿔줌.
            let query = MyChannelModel()
            
            //    chSeqno, chContext, chNickname, chImage, chRegistDate, chValidation, uSeqno
            
            // jsonElement 는 중괄호 처음 값 불러와서 code값, , , , 불러와서 변수에 넣음.
            // 여기에 들어왔다? 이상없다...
            if let chSeqno = jsonElement["channelSeqno"] as? String,
                let chContext = jsonElement["channelContent"] as? String,
                let chNickname = jsonElement["channelNickname"] as? String,
                let chImage = jsonElement["channelImage"] as? String,
                let chRegistDate = jsonElement["channelRegisterDate"] as? String,
                let chValidation = jsonElement["channelValidation"] as? String,
                let uSeqno = jsonElement["userSeqno"] as? String{
                
                query.chSeqno = chSeqno
                query.chContext = chContext
                query.chNickname = chNickname
                query.chImage = chImage
                query.chRegistDate = chRegistDate
                query.chValidation = chValidation
                query.uSeqno = uSeqno
            }
            // for문 안에 if 문 하나 끝남.
            
            // 로케이션 어레이에 넣어줘야지.
            locations.add(query)
        }
        
        // Async로 넣어준다.
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownload_myChannel(itemChannel: locations)
        })

    }
    
    
}//----
