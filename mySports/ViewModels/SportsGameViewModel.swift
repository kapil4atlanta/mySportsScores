//
//  SportsGameViewModel.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation

open class SportsGameViewModel: NSObject {
    
    var gameID: String
    var phase: String? = "Final"
    var pageTitle: String? = "Game"
    var currentGame: Game?
    var gameList: GameList?
    let identifier = "Cell"

    
    public init(gameId: String, phase: String, pageTitle: String){
        self.gameID = gameId
        self.phase = phase
        self.pageTitle = pageTitle
       
        if let gamelist = SportsDataManager.shared.getGameScheduleObject(){
            if let cgame = gamelist.getGameforGameId(gameID: gameID){
                currentGame = cgame
                gameList = gamelist
            }
        }
        if currentGame == nil, let list =  SportsDataManager.shared.getGamesFromLocal() {
            gameList = list
            currentGame =  list.getGameforGameId(gameID: gameID)
        }
        
        super.init()
        
    }
    
    func updateCurrentGame(){
        if let gamelist = SportsDataManager.shared.getGameScheduleObject(){
            currentGame = nil
            if let cgame = gamelist.getGameforGameId(gameID: gameID){
                currentGame = cgame
                gameList = gamelist
            }
            if currentGame == nil, let list =  SportsDataManager.shared.getGamesFromLocal() {
                gameList = list
                currentGame =  list.getGameforGameId(gameID: gameID)
            }
        }
    }
}
