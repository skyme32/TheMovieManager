//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "YOUR_TMDB_API_KEY"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getFavorites
        case getRequestToken
        case login
        case createSessionId
        case logout
        case webAuth
        case search(String)
        case markWatchlist
        case markFavorite
        case posterImage(String)
        
        var stringValue: String {
            switch self {
                case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
                case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
                case .createSessionId:return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
                case .logout:return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
                case .webAuth: return "https://www.themoviedb.org/authenticate/\(Auth.requestToken)?redirect_to=themoviemanager:authenticate"
                case .search(let query): return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))"
                case .markWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .markFavorite: return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .posterImage(let posterPath): return "https://image.tmdb.org/t/p/w500/" + posterPath
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void) {
        let body = PostSession(requestToken: Auth.requestToken)
        
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            guard let data = data else {
                completion(false, error)
                return
            }
            
            do {
                print(request)
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(SessionResponse.self, from: data)
                Auth.sessionId = responseObject.sessionId
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    class func postLogin(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(username: "skyme32", password: "Momotobias123$", requestToken: Auth.requestToken)
                
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
                
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            guard let data = data else {
                completion(false, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = responseObject.requestToken
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }
    
    /*
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { data, response, error in
            guard let data = data else {
                completion(false, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = responseObject.requestToken
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }*/
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        MethodRequest.taskForGETRequest(url: TMDBClient.Endpoints.getRequestToken.url, response: RequestTokenResponse.self) { response, error in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        MethodRequest.taskForGETRequest(url: TMDBClient.Endpoints.getWatchlist.url, response: MovieResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getSearchlist(query: String, completion: @escaping ([Movie], Error?) -> Void) {
        MethodRequest.taskForGETRequest(url: TMDBClient.Endpoints.search(query).url, response: MovieResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
}
