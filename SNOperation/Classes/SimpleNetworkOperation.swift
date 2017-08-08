 //
 //  SimpleNetworkOperation.swift
 //  MyAngel
 //
 //  Created by Andrea Belli on 08/03/16.
 //  Copyright © 2016 Groupama. All rights reserved.
 //
 
 
 public enum RequestMethodType : String{
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case get = "GET"
 }
 
 public extension URLRequest{
    
    /*Ritorna base64EncodedData risultato da username & password
     Aggiunge il parametro per la BasicAthentication nel HTTPHeaderField "Authorization"
     */
    @discardableResult
    public mutating func setBasicAuthentication(username: String, password: String) ->  String{
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!  //loginString.dataUsingEncoding(NSUTF8StringEncoding.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: .lineLength64Characters)
        self.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        return base64LoginString
    }
 }
 
 public class SimpleNetworkOperation {
    
    public var session: URLSession // = NSURLSession.sharedSession();
    public var queryURL =  NSURL()
    public var urlString : String!
    public var debug : Bool = false
    
    static let DEFAULT_TIMEOUT : Double = 15
    
    public typealias JSONDictionaryCompletion = (Any?, Int?, Error?) -> Void
    public typealias JSONDictionaryCompletionAndDataTask = (Any?, Int?, Error?, URLSessionDataTask?) -> Void
    
    public init(url: String, timeout : Double) {
        self.urlString = url
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = timeout
        urlconfig.timeoutIntervalForResource = timeout
        
        self.session = URLSession(configuration: urlconfig)
        if let queryURL = NSURL(string: url){
            self.queryURL = queryURL
        }
    }
    
    public convenience init (url: String){
        self.init(url: url, timeout : SimpleNetworkOperation.DEFAULT_TIMEOUT)
    }
    
    public func operationWithAuthorization(requestMethodType type: RequestMethodType, body: Data?,  completion: @escaping JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, username : String, password: String) {
        var request = getPreparedRequest(requestMethodType: type, headerParams: headerParams, body: body)
        request.setBasicAuthentication(username: username, password: password)
        executeDataTask(request: request, completion: completion, type: type)
    }
    
    public func operationWithAuthorization(requestMethodType type: RequestMethodType, body: Data?,  completion: @escaping JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, username : String, password: String, queryStringParameters : Dictionary<String, String>) {
        
        var queryString : String = "?"
        var keyCount = 0
        queryStringParameters.forEach({ (body: (key: String, value: String)) in
            if keyCount != 0 {
                queryString.append("&")
            }
            queryString.append(body.key)
            queryString.append("=")
            queryString.append(body.value)
            keyCount = keyCount + 1
        })
        
        var request = getPreparedRequest(requestMethodType: type, headerParams: headerParams, body: body, whit: queryString)
        request.setBasicAuthentication(username: username, password: password)
        executeDataTask(request: request, completion: completion, type: type)
    }
    
    public func operationWithAuthorization(requestMethodType type: RequestMethodType,  completion: @escaping JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, username : String, password: String, queryStringParameters : Dictionary<String, String>) {
        
        var queryString : String = "?"
        var keyCount = 0
        queryStringParameters.forEach({ (body: (key: String, value: String)) in
            if keyCount != 0 {
                queryString.append("&")
            }
            queryString.append(body.key)
            queryString.append("=")
            queryString.append(body.value)
            keyCount = keyCount + 1
        })
        
        var request = getPreparedRequest(requestMethodType: type, headerParams: headerParams, body: nil, whit: queryString)
        request.setBasicAuthentication(username: username, password: password)
        executeDataTask(request: request, completion: completion, type: type)
    }
    
    
    public func operation(requestMethodType type: RequestMethodType, body: Data?,  completion: @escaping JSONDictionaryCompletion, headerParams: Dictionary<String, String>?) {
        let request = getPreparedRequest(requestMethodType: type, headerParams: headerParams, body: body)
        executeDataTask(request: request, completion: completion, type: type)
    }
    
    public func operation(requestMethodType type: RequestMethodType, body: Data?,  completion:  @escaping JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, queryStringParameters : Dictionary<String, String>) {
        
        var queryString : String = "?"
        var keyCount = 0
        queryStringParameters.forEach({ (body: (key: String, value: String)) in
            if keyCount != 0 {
                queryString.append("&")
            }
            queryString.append(body.key)
            queryString.append("=")
            queryString.append(body.value)
            keyCount = keyCount + 1
        })
        
        let request = getPreparedRequest(requestMethodType: type, headerParams: headerParams, body: body, whit: queryString)
        executeDataTask(request: request, completion: completion, type: type)
    }
    
    
    public func operation(requestMethodType type: RequestMethodType,  completion:  @escaping JSONDictionaryCompletion, headerParams: Dictionary<String, String>?, queryStringParameters : Dictionary<String, String>) {
        
        var queryString : String = "?"
        var keyCount = 0
        queryStringParameters.forEach({ (body: (key: String, value: String)) in
            if keyCount != 0 {
                queryString.append("&")
            }
            queryString.append(body.key)
            queryString.append("=")
            queryString.append(body.value)
            keyCount = keyCount + 1
        })
        
        let request = getPreparedRequest(requestMethodType: type, headerParams: headerParams, body: nil, whit: queryString)
        executeDataTask(request: request, completion: completion, type: type)
    }
    
    public func getPreparedRequest(requestMethodType type: RequestMethodType, headerParams: Dictionary<String, String>?, body: Data?) -> URLRequest{
        var request = URLRequest(url: queryURL as URL)
        request.httpMethod = type.rawValue
        request.httpBody = body as Data?
        
        NSLog(type.rawValue + " FOR URL " + self.queryURL.absoluteString!)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        return request
    }
    
    public func getPreparedRequest(requestMethodType type: RequestMethodType, headerParams: Dictionary<String, String>?, body: Data?, whit queryString: String) -> URLRequest{
        
        let url = NSURL(string: urlString.appending(queryString))
        NSLog(urlString.appending(queryString))
        
        var request = URLRequest(url: url! as URL)
        request.httpMethod = type.rawValue
        request.httpBody = body as Data?
        
        NSLog(type.rawValue + " FOR URL " + self.queryURL.absoluteString!)
        
        headerParams?.forEach({ (body: (key: String, value: String)) -> () in
            request.addValue(body.value, forHTTPHeaderField: body.key)
        })
        
        return request
    }
    
    public func executeDataTask(request: URLRequest, completion: @escaping JSONDictionaryCompletion, type: RequestMethodType){
        
        session.dataTask(with: request) { (data, response, error) in
            var jsonObject : Any?
            
            guard let httpResponse = response as? HTTPURLResponse, let recievedData = data else{
                self.snoDebug(response as? HTTPURLResponse, data )
                
                completion(nil, 0, nil)
                return
            }
            
            do {
                jsonObject = try JSONSerialization.jsonObject(with: recievedData, options: .allowFragments)
            }catch{}
            
            completion(jsonObject, httpResponse.statusCode, error)
            
            }.resume()
    }
    
    public func snoDebug(_ items : Any?...){
        if debug {
            print(items)
        }
    }
    
 }
