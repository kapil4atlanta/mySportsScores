//
//  StatsLeadersView.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation
import UIKit


let STATS_DIVIDE_SPACE : CGFloat = 40
let MARGIN : CGFloat = 20.0
typealias STATSMODEL  = ScoreSummaryModel.HomeAwayScore.Leaders.PointTable.Statistics

class GameStatsView: UIView{
    var gameInfo: ScoreSummaryModel!
    var gameList: GameList!
    let categories = ["assists", "points", "rebounds"]
    var stats: (points: String, percentage: String) = ("", "")
    
    init(origin: CGPoint, width: CGFloat, gameInfo: ScoreSummaryModel, gameList: GameList) {
        super.init(frame: CGRect.init(x: origin.x, y: origin.y, width: width, height: 0))
        self.gameInfo = gameInfo
        self.gameList = gameList
        
        self.backgroundColor = UIColor.black
        layoutWithGameStats(gameInfo: self.gameInfo, gameList: gameList)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layoutWithGameStats(gameInfo: ScoreSummaryModel, gameList: GameList) {
        var atY : CGFloat = 8
        
        let title = UILabel.init(frame: CGRect.init(x: MARGIN, y: atY, width: 200, height: 20))
        self.addSubview(title)
        
        atY += (title.frame.origin.y + title.frame.size.height) + 10
        

        for i in 0 ... 2 {
            let categ = categories[i]
            let isLast = i == 2
            var away = self.gameInfo.away.leaders.assists.first?.statistics
            var home = self.gameInfo.home.leaders.assists.first?.statistics
            
            switch i{
            case 0:
                away = self.gameInfo.away.leaders.assists.first?.statistics
                home = self.gameInfo.home.leaders.assists.first?.statistics
            case 1:
                away = self.gameInfo.away.leaders.points.first?.statistics
                home = self.gameInfo.home.leaders.points.first?.statistics
            case 2:
                away = self.gameInfo.away.leaders.rebounds.first?.statistics
                home = self.gameInfo.home.leaders.rebounds.first?.statistics
            default:
                break
            }
            
            if let away = away, let home = home{
                atY = self.addPlayersForCategory(category: categ, homeStats: home, awayStats: away, gameList: self.gameList, yPosition: atY, addDivider: !isLast)
            }
        }
        
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: atY)
    }
    
    func addPlayersForCategory(category: String, homeStats: STATSMODEL, awayStats: STATSMODEL, gameList: GameList, yPosition: CGFloat, addDivider: Bool) -> CGFloat {
        
        var atY = yPosition+8
        let HALF_WIDTH : CGFloat = (self.frame.size.width - MARGIN*2 - STATS_DIVIDE_SPACE)/2.0
        
        let titleView = UIView.init(frame: CGRect.init(x: MARGIN/2.0, y: atY, width: self.frame.width, height: 20))
        let title = UILabel.init()
        title.text = category
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.gray
        title.sizeToFit()
        titleView.addSubview(title)
        self.addSubview(titleView)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        let constraints:[NSLayoutConstraint] = [
            (title.centerXAnchor.constraint(equalTo: titleView.centerXAnchor)),
            (title.centerYAnchor.constraint(equalTo: titleView.centerYAnchor))
        ]
        NSLayoutConstraint.activate(constraints)
        
        atY = (titleView.frame.origin.y + titleView.frame.size.height) + 5
        
        var sport: String = ""
        var awayTeamCode: String = ""
        var homeTeamCode: String = ""
        if let type = gameList.league.name, let awayCode = gameInfo.away.alias, let homeCode = gameInfo.home.alias{
            sport = type
            awayTeamCode = awayCode
            homeTeamCode = homeCode
        }
        
        let teamNameImagePath = sport + "TeamLogos/"
        
        //add away player info
        let awayImageContainer = UIView.init(frame: CGRect.init(x: MARGIN, y: atY + 10, width: HALF_WIDTH*0.3, height: HALF_WIDTH*0.3))
        awayImageContainer.layer.cornerRadius = (HALF_WIDTH*0.3) / 2
        awayImageContainer.alpha = 0.8
        awayImageContainer.layer.borderWidth = 1
        awayImageContainer.clipsToBounds = true
        awayImageContainer.backgroundColor = UIColor.gray
        let awayImg = UIImageView.init(frame: CGRect.init(x: HALF_WIDTH*0.05, y: HALF_WIDTH*0.05, width: HALF_WIDTH*0.2, height: HALF_WIDTH*0.2))
        awayImg.image = UIImage.init(named: teamNameImagePath + awayTeamCode.lowercased())
        awayImageContainer.addSubview(awayImg)
        self.addSubview(awayImageContainer)
        
        let awayName = UILabel.init(frame: CGRect.init(x: (awayImageContainer.frame.origin.x + awayImageContainer.frame.size.width) + 5, y: 0, width: HALF_WIDTH*0.6, height: 30))
        awayName.textAlignment = NSTextAlignment.right
        awayName.font = UIFont.systemFont(ofSize: 13)
        awayName.text = awayTeamCode
        awayName.textColor = UIColor.clear
        awayName.sizeToFit()
        self.addSubview(awayName)
        
        let awayTotal = UILabel.init(frame: CGRect.init(x: (awayImageContainer.frame.origin.x + awayImageContainer.frame.size.width) + 5, y: 0, width: HALF_WIDTH*0.6, height: 30))
        awayTotal.textAlignment = NSTextAlignment.right
        awayTotal.font = UIFont.boldSystemFont(ofSize: 18)
        awayTotal.text = String(format: "%d", awayStats.points ?? "")
        awayTotal.textColor = UIColor.white
        awayTotal.sizeToFit()
        self.addSubview(awayTotal)
        
        let awayY = awayImageContainer.frame.origin.y + (awayImageContainer.frame.size.height - (awayName.frame.size.height + awayTotal.frame.size.height + 5))/2.0
        var f = awayName.frame
        awayName.frame = CGRect.init(x: f.origin.x, y: awayY, width: f.size.width, height: f.size.height)
        f = awayTotal.frame
        awayTotal.frame = CGRect.init(x: f.origin.x, y: (awayName.frame.origin.y + awayName.frame.size.height) + 5, width: f.size.width, height: f.size.height)
        
        let awayProgressView = UIProgressView.init(frame: CGRect.init(x: f.origin.x, y: (awayTotal.frame.origin.y + awayTotal.frame.size.height) + 5, width: HALF_WIDTH, height: 30))
        awayProgressView.progressViewStyle = .bar
        awayProgressView.progressTintColor = UIColor.purple
        if let value = awayStats.field_goals_pct{
            awayProgressView.progress = Float(value)/100
        }
        self.addSubview(awayProgressView)
        
        //add home player info
        let homeImageContainer = UIView.init(frame: CGRect.init(x: self.frame.size.width - MARGIN - HALF_WIDTH*0.3, y: atY + 10, width: HALF_WIDTH*0.3, height: HALF_WIDTH*0.3))
        homeImageContainer.layer.cornerRadius = (HALF_WIDTH*0.3) / 2
        homeImageContainer.alpha = 0.8
        homeImageContainer.layer.borderWidth = 1
        homeImageContainer.clipsToBounds = true
        homeImageContainer.backgroundColor = UIColor.gray
        let homeImg = UIImageView.init(frame: CGRect.init(x: HALF_WIDTH*0.05, y: HALF_WIDTH*0.05, width: HALF_WIDTH*0.2, height: HALF_WIDTH*0.2))
        homeImg.image = UIImage.init(named: teamNameImagePath + homeTeamCode.lowercased())
        homeImg.layer.masksToBounds = true
        homeImageContainer.addSubview(homeImg)
        self.addSubview(homeImageContainer)
        
        let homeNameView = UIView.init(frame: CGRect.init(x: homeImageContainer.frame.origin.x - (HALF_WIDTH*0.6) - 5, y: 0, width: HALF_WIDTH*0.6, height: 30))
        let homeName = UILabel.init(frame: CGRect.init(x: 0, y: 15, width: HALF_WIDTH*0.6, height: 13))
        homeName.text = homeTeamCode
        homeName.font = UIFont.systemFont(ofSize: 13)
        homeName.textColor = UIColor.clear
        homeName.textAlignment = .right
        homeNameView.backgroundColor = UIColor.clear
        homeNameView.addSubview(homeName)
        self.addSubview(homeNameView)
        
        let homeTotalView = UIView.init(frame: CGRect.init(x: homeNameView.frame.origin.x, y: 0, width: HALF_WIDTH*0.6, height: 30))
        let homeTotal = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: HALF_WIDTH*0.6, height: 18))
        homeTotal.font = UIFont.boldSystemFont(ofSize: 18)
        homeTotal.text = String(format: "%d", self.gameInfo.home.points ?? "")
        homeTotal.textAlignment = .right
        homeTotal.textColor = UIColor.white
        homeTotalView.backgroundColor = UIColor.clear
        homeTotalView.addSubview(homeTotal)
        self.addSubview(homeTotalView)
        
        let homeY = homeImageContainer.frame.origin.y + (homeImageContainer.frame.size.height - (homeNameView.frame.size.height + homeTotalView.frame.size.height + 5))/2.0
        f = homeNameView.frame
        homeNameView.frame = CGRect.init(x: f.origin.x, y: homeY, width: f.size.width, height: f.size.height)
        f = homeTotalView.frame
        homeTotalView.frame = CGRect.init(x: f.origin.x, y: (homeNameView.frame.origin.y + homeNameView.frame.size.height) + 5, width: f.size.width, height: f.size.height)
        
        let homeProgressView = UIProgressView.init(frame: CGRect.init(x: awayProgressView.frame.origin.x + awayProgressView.frame.width + 3, y: (homeTotalView.frame.origin.y + homeTotalView.frame.size.height) + 5, width: HALF_WIDTH, height: 30))
        homeProgressView.progressViewStyle = .bar
        if let pct = homeStats.field_goals_pct{
            homeProgressView.progress = Float(pct)/100
        }
        homeProgressView.progressTintColor = UIColor.blue
        self.addSubview(homeProgressView)
        
        let progressF = awayProgressView.frame
        let progressWidth = homeImageContainer.frame.origin.x - (awayImageContainer.frame.origin.x + awayImageContainer.frame.width)
        awayProgressView.frame = CGRect.init(x: progressF.origin.x, y: progressF.origin.y, width: progressWidth - 5, height: progressF.height)
        homeProgressView.frame = CGRect.init(x: progressF.origin.x + 5, y: progressF.origin.y, width: progressWidth - 10, height: progressF.height)
        awayProgressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        homeProgressView.transform = CGAffineTransform(scaleX: -1.0, y: 2.0)
        
        if addDivider {
            let tmp = UIView.init(frame: CGRect.init(x: 0, y: (homeProgressView.frame.origin.y + homeProgressView.frame.size.height) + 25.0, width: self.frame.size.width, height: 1))
            tmp.backgroundColor = UIColor.darkGray
            self.addSubview(tmp)
            return tmp.frame.origin.y + tmp.frame.size.height
        }
        else {
            return (homeProgressView.frame.origin.y + homeProgressView.frame.size.height) + 25.0
        }
    }
}
