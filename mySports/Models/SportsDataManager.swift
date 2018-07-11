//
//  SportsDataManager.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation
import UIKit


enum Urls: String {
    //Using Authentication
    case GameDataHost = "http://api.sportradar.us/nba/trial/v4/en/games"
    
}

protocol SportsDataManagerDelegate: class {
    func updatedInformationAvailable(isUpdated: Bool)
    func updatedScheduleInfo(isUpdated: Bool)
}

class SportsDataManager: NSObject {
    
    public static let shared = SportsDataManager()
    public weak var delegate: SportsDataManagerDelegate?

    private var gameDetailsObject: ScoreSummaryModel?
    private var gameScheduleObject: GameList?
    private var NBAGameTimeLineDict = [String]()
    private var gameScheduleDict = Dictionary<String, Any>()
    private var GameDetailsDict = Dictionary<String, Any>()

    private var gameId: String = ""
    private var gamePhase: String = ""
    private var currentData: String = ""
    private var currentScheduleData: String = ""
    private let sportsScheduleData = "SportsSchedule"
    
    var gameScheduleData: Dictionary<String, Any>?{
        get{
            return gameScheduleDict
        }
    }
    
    var GameDetailsData: Dictionary<String, Any>?{
        get{
            return GameDetailsDict
        }
    }
    
    public func getGameScheduleObject() -> GameList?{
        if self.gameScheduleObject != nil{
            return self.gameScheduleObject
        }
        return nil
    }
    
    public func getGameDetailsObject() -> ScoreSummaryModel?{
        if self.gameDetailsObject != nil{
            return self.gameDetailsObject
        }
        return nil
    }
    
    public func getGamesFromLocal() -> GameList?{
        if let path = Bundle.main.path(forResource: "SportsGames", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonDecoder = JSONDecoder()
                let gamelist = try jsonDecoder.decode(GameList.self, from: data)
                return gamelist
            }catch let testError{
                print(testError)
            }
        }
        return nil
    }
    
    var NBAGameTimeLine: [String]?{
        get{
            return NBAGameTimeLineDict
        }
    }
    
    fileprivate override init(){
        super.init()
    }
    

    
    public func getSportsScheduleData(completion: @escaping (Bool) -> Void){
        
        //Fetch All Schedules
        
        HttpHandler.fetchGameSchdule(urlString: Urls.GameDataHost.rawValue) { [weak self] (data, json, error) in
            guard let strongSelf = self else { return }
            
            if error != nil{
                completion(false)
            }
            else{
                guard let response = json else{
                    completion(false)
                    return
                }
                strongSelf.gameScheduleDict = response
                
                do{
                    let decoder = JSONDecoder()
                    let scheduleObject = try decoder.decode(GameList.self, from: data)
                    strongSelf.gameScheduleObject = scheduleObject
                    
                    if strongSelf.gameScheduleObject != nil{
                        completion(true)
                        strongSelf.delegate?.updatedScheduleInfo(isUpdated: true)
                    }
                    
                }catch let error{
                    print (error)
                }
            }
        }
        
    }
    
    public func getGameDetails(gameID: String, completion: @escaping (Bool) -> Void){
        self.gameId = gameID
        self.gameDetailsObject = nil
        
        HttpHandler.fetchGameDetails(urlString: Urls.GameDataHost.rawValue, gameID: gameID, closure: { [weak self] (data, json, error) in
            guard let strongSelf = self else { return }
            
            if error == nil{
                if let responseData = json{
                    strongSelf.GameDetailsDict = responseData
                }
                do {
                    let decoder = JSONDecoder()
                    //Decode retrived data with JSONDecoder and assisting type of Article object
                    let json = try decoder.decode(ScoreSummaryModel.self, from: data)
                    strongSelf.gameDetailsObject = json
                    strongSelf.delegate?.updatedInformationAvailable(isUpdated: true)
                    completion(true)
                    
                }catch let error{
                    print (error)
                    strongSelf.delegate?.updatedInformationAvailable(isUpdated: false)
                }
                
            }else{
                completion(false)
            }
        })
    }
}


