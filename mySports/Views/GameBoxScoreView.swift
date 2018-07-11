//
//  GameBoxScoreView.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation
import UIKit

class GameBoxScoreView: UIView{
    var gameInfo: ScoreSummaryModel!
    var gameList: GameList!
    var dataSource: [[String]] = []
    var cellHeight: CGFloat = 40
    var collecionViewHeight: CGFloat = 0
    var numberOfColumns: Int = 0
    var yValue: CGFloat = 0
    var teamSegmentView: UIView!
    var boxSegmentsView: UIView!
    var homeButton: UIButton!
    var awayButton: UIButton!
    let columnHeaders = ["Player Name", "FGP", "FGM", "AST", "BLK", "PF", "PTS", "REB", "STL"]
    
    init(origin: CGPoint, width: CGFloat, info: ScoreSummaryModel, gameList: GameList) {
        super.init(frame: CGRect.init(x: origin.x, y: origin.y, width: width, height: 0))
        self.gameInfo = info
        self.gameList = gameList
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit(){
        
        setupTeamSegmentsView()
        setupBoxViews()
        
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: yValue)
        self.backgroundColor = UIColor.black
    }
    
    func setupTeamSegmentsView(){
        self.teamSegmentView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 70))
        teamSegmentView.backgroundColor = UIColor.black
        awayButton = UIButton.init(frame: CGRect(x: 30, y: 20, width: (self.frame.width - 70) / 2, height: 40))
        homeButton = UIButton.init(frame: CGRect(x: awayButton.frame.origin.x + awayButton.frame.width + 10, y: 20, width: (self.frame.width - 70) / 2, height: 40))
        
        self.teamSegmentView.addSubview(awayButton)
        self.teamSegmentView.addSubview(homeButton)
        self.addSubview(teamSegmentView)
        yValue = teamSegmentView.frame.height
        
        awayButton.backgroundColor = UIColor.purple // need to fetch team specific color
        homeButton.backgroundColor = UIColor.lightGray // need to fetch team specific color
        
        awayButton.addTarget(self, action: #selector(awayButtonSelected), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(homeButtonSelected), for: .touchUpInside)
        
        awayButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setupBoxViews(){
        
        boxSegmentsView = UIView.init(frame: CGRect(x: 0, y: yValue, width: self.frame.width, height: 0))
            
        awayButton.setTitle(gameInfo.away.name, for: .normal)
        homeButton.setTitle(gameInfo.home.name, for: .normal)
        
        awayButton.isSelected = true
        self.prepareDataSource(team: "away")
    }
    
    @objc func homeButtonSelected(){
        homeButton.isSelected = true
        awayButton.isSelected = false
        
        awayButton.backgroundColor = UIColor.lightGray
        homeButton.backgroundColor = UIColor.blue
        
        reloadViews(team: "home")
    }
    
    @objc func awayButtonSelected(){
        awayButton.isSelected = true
        homeButton.isSelected = false
        
        awayButton.backgroundColor = UIColor.purple
        homeButton.backgroundColor = UIColor.lightGray
        
        reloadViews(team: "away")
    }
    
    private func reloadViews(team: String){
        yValue = yValue - self.boxSegmentsView.frame.height
        for view in self.boxSegmentsView.subviews{
            view.removeFromSuperview()
        }
        var frame = self.boxSegmentsView.frame
        frame.size.height = 0
        self.boxSegmentsView.frame = frame
        
        prepareDataSource(team: team)
    }
    
    private func prepareDataSource(team: String){
        var boxYVal: CGFloat = 30
        var score: ScoreSummaryModel.HomeAwayScore.Leaders? = nil
        if team == "home"{
            score = self.gameInfo.home.leaders
        }else{
             score = self.gameInfo.away.leaders
        }
        
        guard let scoreValues = score else {
            return
        }
        
        for i in 0 ... 2 {
            var stats = scoreValues.assists.first?.statistics
            var data: [String] = []
            var playerName = ""
            switch i{
            case 0:
                stats = scoreValues.assists.first?.statistics
                playerName = scoreValues.assists.first?.full_name ?? ""
            case 1:
                stats = scoreValues.points.first?.statistics
                 playerName = scoreValues.points.first?.full_name ?? ""
            case 2:
                stats = scoreValues.rebounds.first?.statistics
                 playerName = scoreValues.rebounds.first?.full_name ?? ""
            default:
                break
            }
            
            if let stats = stats,  let statsData = addToData(stats: stats){
                data = statsData
                data.insert(playerName, at: 0)
                dataSource.append(data)
            }
        }
        dataSource.insert(columnHeaders, at: 0) // Add Column Labels
        numberOfColumns = columnHeaders.count
        collecionViewHeight = cellHeight * CGFloat(dataSource.count)
        
        let boxTable = BoxScoreCollectionView(origin: CGPoint(x: 0, y: boxYVal), width: self.frame.width, info: dataSource, numberOfColumns: numberOfColumns, collecionViewHeight: collecionViewHeight )
        boxSegmentsView.addSubview(boxTable)
        dataSource.removeAll()
        boxYVal = boxYVal + boxTable.frame.height + 50
        yValue = yValue + boxTable.frame.height + 50

        self.boxSegmentsView.frame = CGRect(x: self.boxSegmentsView.frame.origin.x, y: self.boxSegmentsView.frame.origin.y , width: self.boxSegmentsView.frame.width, height: boxYVal)
        
        yValue  = boxYVal + 30
        
        self.addSubview(boxSegmentsView)
    }
    
    func addToData(stats: ScoreSummaryModel.HomeAwayScore.Leaders.PointTable.Statistics) -> [String]?{
        var returnStats:[String] = []
        
        returnStats.append(String(format: "%.2f", stats.field_goals_pct ?? 0.0))
        returnStats.append(String(format: "%d", stats.field_goals_made ?? 0.0))
        returnStats.append(String(format: "%d", stats.assists ?? 0.0))
        returnStats.append(String(format: "%d", stats.blocks ?? 0.0))
        returnStats.append(String(format: "%d", stats.personal_fouls ?? 0.0))
        returnStats.append(String(format: "%d", stats.points ?? 0.0))
        returnStats.append(String(format: "%d", stats.rebounds ?? 0.0))
        returnStats.append(String(format: "%d", stats.steals ?? 0.0))
        
        return returnStats
    }
}

class BoxScoreCollectionView: UIView {
    
    var boxCollectionView: UICollectionView?
    let contentCellIdentifier = "BoxScoreCollectionViewCellIdentifier"
    var dataSource: [[String]] = []
    var cellHeight: CGFloat = 40
    var itemHeight: CGFloat = 0
    var collecionViewHeight: CGFloat = 0
    var numberOfColumns: Int = 0
    var firstColumnWidth: CGFloat = 0
    var itemWidth: CGFloat = 0
    
    init(origin: CGPoint, width: CGFloat, info: [[String]], numberOfColumns: Int, collecionViewHeight: CGFloat) {
        super.init(frame: CGRect.init(x: origin.x, y: origin.y, width: width, height: 0))
        self.dataSource = info
        self.numberOfColumns = numberOfColumns
        self.collecionViewHeight = collecionViewHeight
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit() {
        
        let collectionViewLayout = BoxScoreCollectionViewLayout()
        collectionViewLayout.delegate = self
        boxCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 20, width: self.frame.width, height: collecionViewHeight), collectionViewLayout: collectionViewLayout)
        boxCollectionView?.delegate = self
        boxCollectionView?.dataSource = self
        boxCollectionView?.bounces = false
        boxCollectionView?.allowsSelection = false
        boxCollectionView?.backgroundColor = UIColor.black
        
        boxCollectionView?.register(UINib(nibName: "BoxScoreCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: contentCellIdentifier)
        
        self.addSubview(boxCollectionView!)
        
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: (boxCollectionView?.frame.size.height)!)
        
        itemHeight = CGFloat(40)
        firstColumnWidth = CGFloat(155)
        itemWidth = CGFloat(50)
    }
    
    
}


// MARK: - UICollectionViewDataSource
extension BoxScoreCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numOfItems =  dataSource.first?.count else {
            return 1
        }
        return numOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                      for: indexPath) as! BoxScoreCollectionViewCell
        var data = dataSource[indexPath.section]
        cell.backgroundColor = UIColor.black
        cell.contentLabel.text = data[indexPath.row]
        
        cell.teamPosition.isHidden = true
        cell.topDivider.isHidden = true
        cell.bottomDivider.isEnabled = true
        cell.bottomDivider.isHidden = true
        cell.bottomDivider.textColor = UIColor.lightGray
        
        if indexPath.section != 0 && indexPath.row != 0 {
            cell.contentLabel.textColor = UIColor.gray
        }else{
            cell.contentLabel.textColor = UIColor.white
        }
        
        if let numOfSections = self.boxCollectionView?.numberOfSections{
            if indexPath.section < numOfSections - 1{
                cell.bottomDivider.isHidden = false
            }else{
                cell.bottomDivider.isHidden = true
            }
        }

        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension BoxScoreCollectionView: UICollectionViewDelegate {
    
}


// MARK: - BoxScoreCollectionViewLayoutDelegate methods
extension BoxScoreCollectionView: BoxScoreCollectionViewLayoutDelegate{
    
    func LayoutNumberOfColumns() -> Int {
        return numberOfColumns
    }
    
    func LayoutItemHeight() -> CGFloat {
        return itemHeight
    }
    
    func LayoutItemWidths() -> (firstColumnWidth: CGFloat, itemWidth: CGFloat){
        itemWidth = numberOfColumns < 6 ? CGFloat(55) : CGFloat(50)
        return (firstColumnWidth, itemWidth)
    }
}


