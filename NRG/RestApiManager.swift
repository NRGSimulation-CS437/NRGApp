//
//  RestApiManager.swift
//  NRG
//
//  Created by kevin on 1/15/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//


import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager : NSObject {
    
    static let sharedInstance = RestApiManager()
    
    //edit url in register as well
    let link = "http://172.249.231.197:1337/"
    
    //gets the specified user
    func getUser(let user: String, let pass: String, onCompletion: (JSON) -> Void) {
        
        let searchUser = link+"user/?username="+user+"&password="+pass
        print(searchUser)
        makeHTTPGetRequest(searchUser, onCompletion: { json , err -> Void in
            onCompletion(json)
            print(json)
            
        })
    }
    
    //gets all houses linked to that owner
    func getHouses(let owner: String, onCompletion: (JSON) -> Void) {
        
        let houseLink = link+"house/?&owner="+owner
        print(houseLink)
        makeHTTPGetRequest(houseLink, onCompletion: { json , err -> Void in
            onCompletion(json)
            print(json)
            
        })
    }
    
    //gets all rooms linked to that owner
    func getRooms(let owner: String, let house: String, onCompletion: (JSON) -> Void) {
        
        let houseLink = link+"room/?&owner="+owner+"&house="+house
        print(houseLink)
        makeHTTPGetRequest(houseLink, onCompletion: { json , err -> Void in
            onCompletion(json)
            print(json)
            
        })
    }
    
    //makes the HTTPRequest
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            print(data)
            
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
            print("yay")
        })
        
        task.resume()
    }
}