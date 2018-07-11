//
//  HttpHandler.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation

class HttpHandler{
    static fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    static fileprivate let mainQueue = DispatchQueue.main
    
    fileprivate class func make(session: URLSession = URLSession.shared, request: URLRequest, closure: @escaping (_ data: Data, _ json: [String: Any]?, _ error: Error?)->()) {
        
        let task = session.dataTask(with: request) { data, response, error in
            queue.async {
                guard error == nil, let data = data else {
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        mainQueue.async {
                            closure(data, json, nil)
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                    mainQueue.async {
                        closure(data, nil, error)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    class func fetchGameSchdule(urlString: String, closure: @escaping (_ data: Data, _ json: [String: Any]?, _ error: Error?)->()) {
        let urlWithDate = String(format: "%@/%@/%@", urlString, dateFormatter(),"schedule.json")
        let URLParams = ["api_key" : "tvxe3xxsn9yg29tg5pvb4496"]
        guard let url = URL(string: (urlWithDate.replacingOccurrences(of: " ", with: "+"))),  let schedule = NSURLByAppendingQueryParameters(url: url, parameters: URLParams) else {
            return
        }
           
        var request = URLRequest(url: schedule)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        HttpHandler.make(request: request) { data, json, error in
            closure(data, json, error)
        }

    }
    
    class func fetchGameDetails(urlString: String, gameID: String, closure: @escaping (_ data: Data, _ json: [String: Any]?, _ error: Error?)->()) {
        let urlWithDate = String(format: "%@/%@/%@", urlString, gameID,"boxscore.json")
        let URLParams = ["api_key" : "tvxe3xxsn9yg29tg5pvb4496"]
        guard let url = URL(string: (urlWithDate.replacingOccurrences(of: " ", with: "+"))),  let schedule = NSURLByAppendingQueryParameters(url: url, parameters: URLParams) else {
            return
        }
        
        var request = URLRequest(url: schedule)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        HttpHandler.make(request: request) { data, json, error in
            closure(data, json, error)
        }
        
    }
    

    class func dateFormatter() -> String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let date = Date()
        return dateformatter.string(from: date)
    }
    
    class func NSStringFromQueryParameters(queryParameters: Dictionary<String, String>) -> String? {
        var parts = [String]()
        for (key, element) in queryParameters{
            
            let parameter = "\(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"+"="+"\(element.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
            parts.append(parameter)
        }
        return parts.joined(separator: "&")
    }
    
    class func NSURLByAppendingQueryParameters(url: URL, parameters: Dictionary<String, String>)  -> URL?{
        if let params = NSStringFromQueryParameters(queryParameters: parameters),let urlString = URL(string: url.absoluteString+"?"+params){
            return urlString
        }
        return nil
    }
}

