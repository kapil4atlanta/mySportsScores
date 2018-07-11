//
//  SportsDataModels.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation

//http://api.sportradar.us/nba/trial/v4/en/games/2018/04/01/schedule.json?api_key=tvxe3xxsn9yg29tg5pvb4496

struct GameList : Codable {
    public let games : [Game]
    public let date: String?
    public let league: League
    
    
    func getGameforGameId(gameID: String) -> Game? {
        var returnGame: Game? = nil
        for game in games{
            if gameID == game.id{
                returnGame = game
                break
            }
        }
        return returnGame
    }
    
    public struct League: Codable{
        public let id: String?
        public let name: String?
    }
}

public struct Game: Codable {
    
    public let id: String?
    public let status: String?
    public let sport: String? = "NBA"
    public let scheduled: String?
    public let away_points: Int?
    public let home_points: Int?
    public let home: Team
    public let away: Team
    public let venue: Venue
    
    public struct Team: Codable {
        public let name : String?
        public let alias: String?
        public let id: String?
    }
    
    public struct Venue: Codable {
        public let name : String?
        public let city: String?
        public let state : String?
    }
}

//Game BoxScore
//http://api.sportradar.us/nba/trial/v4/en/games/114844aa-3c31-4ac7-9afa-0a4f2ae65e0c/boxscore.json?api_key=tvxe3xxsn9yg29tg5pvb4496

struct ScoreSummaryModel: Codable{
    public let id: String?
    public let status: String?
    public let quarter: Int?
    public let home: HomeAwayScore
    public let away: HomeAwayScore
    
    struct HomeAwayScore: Codable{
        public let name: String?
        public let alias: String?
        public let points: Int?
        public let scoring: [Score]
        public let leaders: Leaders
        
        struct Leaders: Codable{
            public let points: [PointTable]
            public let rebounds: [PointTable]
            public let assists: [PointTable]
            
            struct PointTable: Codable{
                public let full_name: String
                public let statistics: Statistics
                
                struct Statistics: Codable {
                    public let field_goals_pct: Float?
                    public let field_goals_made: Int?
                    public let assists: Int?
                    public let blocks: Int?
                    public let personal_fouls: Int?
                    public let points: Int?
                    public let rebounds: Int?
                    public let steals: Int?
                }
            }
        }
        struct Score: Codable{
            public let type: String?
            public let number: Int?
            public let sequence: Int?
            public let points: Int?
        }
    }
}
