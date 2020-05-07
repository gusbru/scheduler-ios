//
//  SchedulerClient.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

class SchedulerClient {
    
    struct Auth {
        static var email: String = ""
        static var token: String =  ""
    }
    
    enum Endpoints {
        static let base = "https://schedule-api.gustavobrunetto.com"
        
        case getTerm
        case login
        case signIn
        case getSubject(term: String)
        case getList(subject: String, term: String)
        
        var stringVaue: String {
            switch self {
            case .getTerm:
                return "\(Endpoints.base)/api/admin/terms"
            case .login:
                return "\(Endpoints.base)/api/user/authenticate"
            case .signIn:
                return "\(Endpoints.base)/api/user/register"
            case .getSubject(term: let term):
                return "\(Endpoints.base)/api/classes/subjectbyterm?term=\(term)"
            case .getList(subject: let subject, term: let term):
                return "\(Endpoints.base)/api/classes/subjectCourse?subject=\(subject)&term=\(term)"
            }
        }
        
        var url: URL {
            return URL(string: stringVaue)!
        }
    }
    
    
    // MARK:- GET requests
    class func getTerms(completion: @escaping ([TermsRequest], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getTerm.url, ResponseType: [TermsRequest].self) { (response, error) in
            if let response = response {
                completion(response, nil)
            }
            
            if let error = error {
                completion([], error)
            }
        }
    }
    
    class func getSubject(term: String, completion: @escaping ([SubjectResponse], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getSubject(term: term).url, ResponseType: [SubjectResponse].self) { (response, error) in
            if let response = response {
                completion(response, nil)
            }
            
            if let error = error {
                completion([], error)
            }
        }
    }
    
    // MARK:- POST requests
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let userInfo = LoginRequest(email: email, password: password)
        
        
        
        taskForPOSTRequest(url: Endpoints.login.url, body: userInfo, reponseType: LoginResponse.self) { (response, error) in
            if let response = response {
                Auth.token = response.token
                Auth.email = email
                completion(true, nil)
            }
            
            if let error = error {
                completion(false, error)
            }
        }
    }
    
    class func signIn(name: String, email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let newUserInfo = SignInRequest(name: name, email: email, password: password)
        
        taskForPOSTRequest(url: Endpoints.signIn.url, body: newUserInfo, reponseType: SignInResponse.self) { (response, error) in
            if let response = response {
                Auth.token = response.token
                Auth.email = response.email
                completion(true, nil)
            }
            
            if let error = error {
                completion(false, error)
            }
        }
    }
    
    
    
    
    
    // MARK:- Private functions
    
    // MARK: GET
    private class func taskForGETRequest<ResponseType: Decodable>(url: URL, ResponseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            
            do {
                
                let responseObject = try decoder.decode(ResponseType.self, from: data)

                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    
                    let errorObject = try decoder.decode(ErrorResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil, errorObject)
                    }
                } catch {
                    
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: POST request
    private class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, reponseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let body = try encoder.encode(body)
            request.httpBody = body
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let objectResponse = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(objectResponse, nil)
                }
            } catch {
                do {
                    let errorObject = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorObject)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        
        task.resume()
    }
}
