//
//  ScoreSummaryView.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import UIKit

let TITLE_FONT : UIFont = UIFont.systemFont(ofSize: 20)

//
//  Score Summary CollectionViewLayout
//  DFW
//

enum RowType {
    case scoreLables
    case awayScores
    case homeScores
}
class GameScoreSummaryView: UIView {
    
    var boxCollectionView: UICollectionView?
    let contentCellIdentifier = "ScoreSummaryCollectionViewCellIdentifier"
    var scoreDictArray = [ScoreSummaryModel.HomeAwayScore.Score]()
    var dataSource = [[String]]()
    var teamImage: UIImageView?
    var teamName: UILabel?
    var cellHeight: CGFloat = 30
    var itemHeight: CGFloat = 0
    var collecionViewHeight: CGFloat = 0
    var numberOfColumns: Int = 0
    var firstColumnWidth: CGFloat = 0
    var itemWidth: CGFloat = 0
    var gameInfo: ScoreSummaryModel!
    var gameList: GameList!
    var titleLbl : UILabel = UILabel.init(frame: CGRect.zero)
    
    init(origin: CGPoint, width: CGFloat, info: ScoreSummaryModel, gameList: GameList) {
        super.init(frame: CGRect.init(x: origin.x, y: origin.y, width: width, height: 0))
        
        self.gameInfo = info
        self.gameList = gameList
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit() {
        
        titleLbl.frame = CGRect.init(x: MARGIN, y: MARGIN, width: 200, height: 30)
        titleLbl.text = "Scoring Summary"
        titleLbl.textColor = UIColor.white
        titleLbl.font = TITLE_FONT
        titleLbl.sizeToFit()
        self.addSubview(titleLbl)
        
        self.preparedataSource()
        
        let collectionViewLayout = BoxScoreCollectionViewLayout()
        collectionViewLayout.delegate = self
        boxCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: (titleLbl.frame.origin.y + titleLbl.frame.size.height) + 20, width: self.frame.size.width, height: collecionViewHeight), collectionViewLayout: collectionViewLayout)
        boxCollectionView?.delegate = self
        boxCollectionView?.dataSource = self
        boxCollectionView?.bounces = false
        boxCollectionView?.allowsSelection = false
        boxCollectionView?.register(GameScoreSummaryCell.self, forCellWithReuseIdentifier: contentCellIdentifier)
        boxCollectionView?.backgroundColor = UIColor.black
        boxCollectionView?.showsHorizontalScrollIndicator = false
        
        self.addSubview(boxCollectionView!)
        
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: titleLbl.frame.size.height + 40 + (boxCollectionView?.frame.size.height)!)
        self.backgroundColor = UIColor.black
    }
    
    
    private func preparedataSource(){
        
        if gameInfo != nil{
            
            addRowToDataSource(rowType: .scoreLables)
            addRowToDataSource(rowType: .awayScores)
            addRowToDataSource(rowType: .homeScores)

            numberOfColumns = scoreDictArray.count + 2 // extra two for team name and Total
            collecionViewHeight = cellHeight * CGFloat(dataSource.count)
        }
                
        itemHeight = CGFloat(30)
        firstColumnWidth = (self.frame.width / 2) - 15
        itemWidth = scoreDictArray.count  < 4 ? CGFloat(firstColumnWidth / CGFloat(scoreDictArray.count)) : CGFloat(firstColumnWidth / 4)
    }
    
    private func addRowToDataSource(rowType: RowType){
        var scoreDataSource = [String]()
        
        switch rowType {
        case .scoreLables:
            scoreDictArray = gameInfo.away.scoring
            for scoreArray in scoreDictArray{
                scoreDataSource.append("\(scoreArray.number ?? 0)")
            }
            scoreDataSource.append("T") // Total column
            scoreDataSource.insert("Team Name", at: 0) // First Column
            
            dataSource.append(scoreDataSource)
        case .awayScores:
            scoreDictArray = gameInfo.away.scoring
            for scoreArray in scoreDictArray{
                scoreDataSource.append("\(scoreArray.points ?? 0)")
            }
            scoreDataSource.append("\(gameInfo.away.points ?? 0)")
            scoreDataSource.insert(gameInfo.away.name ?? "", at: 0)
            
            dataSource.append(scoreDataSource)
        case .homeScores:
            scoreDictArray = gameInfo.home.scoring
            for scoreArray in scoreDictArray{
                scoreDataSource.append("\(scoreArray.points ?? 0)")
            }
            scoreDataSource.append("\(gameInfo.home.points ?? 0)")
            scoreDataSource.insert(gameInfo.home.name ?? "", at: 0)
            
            dataSource.append(scoreDataSource)
        }
    }
    

}


// MARK: - UICollectionViewDataSource
extension GameScoreSummaryView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                      for: indexPath) as! GameScoreSummaryCell
    
        cell.backgroundColor = UIColor.black
        
        cell.isFirstSectionLastRow(isFirstSection: (indexPath.section == 0) && ((numberOfColumns - 1) == indexPath.row))
        
        var data = dataSource[indexPath.section]
        cell.lblScore.text = data[indexPath.row]
        
        cell.imgTeam.isHidden = true
        cell.bottomDivider.isHidden = true

        var teamNameImagePath = ""
        if let sportType = gameList.league.name, let awayCode = gameInfo.away.alias, let homeCode = gameInfo.home.alias {
            teamNameImagePath = sportType + "TeamLogos/"
            if indexPath.row == 0 {
                if indexPath.section == 1{
                    cell.imgTeam.isHidden = false
                    cell.imgTeam.image = UIImage.init(named: teamNameImagePath + awayCode.lowercased())
                }else if indexPath.section == 2{
                    cell.imgTeam.isHidden = false
                     cell.imgTeam.image = UIImage.init(named: teamNameImagePath + homeCode.lowercased())
                }else{
                    cell.imgTeam.isHidden = true
                    cell.imgTeam.frame = .zero
                }
            }
        }
        
        if indexPath.section == 0{
            cell.bottomDivider.isHidden = false
            if indexPath.row == 0{
                var frame = cell.bottomDivider.frame
                frame.origin.x = frame.origin.x + 10
                frame.size.width = frame.size.width  - 10
                cell.bottomDivider.frame = frame
            }else if indexPath.row == (scoreDictArray.count + 1){
                var frame = cell.bottomDivider.frame
                frame.size.width = frame.size.width - 10
                cell.bottomDivider.frame = frame
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension GameScoreSummaryView: UICollectionViewDelegate {
    
}


// MARK: - BoxScoreCollectionViewLayoutDelegate methods
extension GameScoreSummaryView: BoxScoreCollectionViewLayoutDelegate{
    
    func LayoutNumberOfColumns() -> Int {
        return numberOfColumns
    }
    
    func LayoutItemHeight() -> CGFloat {
        return itemHeight
    }
    
    func LayoutItemWidths() -> (firstColumnWidth: CGFloat, itemWidth: CGFloat){
        return (firstColumnWidth, itemWidth)
    }
}




class GameScoreSummaryCell : UICollectionViewCell {
    var imgTeam : UIImageView
    var lblScore : UILabel
    var bottomDivider: UILabel
    var isFirstSection: Bool = false
    
    override init(frame: CGRect) {
        imgTeam = UIImageView.init(frame: CGRect.zero)
        lblScore = UILabel.init(frame: CGRect.zero)
        bottomDivider = UILabel.init(frame: CGRect.zero)
        
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        imgTeam = UIImageView.init(frame: CGRect.zero)
        lblScore = UILabel.init(frame: CGRect.zero)
         bottomDivider = UILabel.init(frame: CGRect.zero)
        
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func isFirstSectionLastRow(isFirstSection: Bool){
        self.isFirstSection = isFirstSection
    }
    
    func commonInit() {
        imgTeam.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width * 0.4, height: self.frame.height)
        self.addSubview(imgTeam)
        
        lblScore.frame = CGRect.init(x: imgTeam.isHidden ? 0 : (imgTeam.frame.origin.x + imgTeam.frame.size.width), y: 0, width: (self.frame.size.width - imgTeam.frame.width) + 5 , height: self.frame.height - 10)
        lblScore.font = UIFont.systemFont(ofSize: 16)
        lblScore.textColor = UIColor.white
        self.addSubview(lblScore)
        self.backgroundColor = UIColor.black
        
        bottomDivider.frame =  CGRect.init(x: 0, y: (lblScore.frame.origin.y + lblScore.frame.height) + 5, width: self.frame.size.width, height: 2)
       // bottomDivider.backgroundColor = UIColor.gray
        self.addSubview(bottomDivider)
        
    }
    
    override func layoutSubviews() {
        imgTeam.frame = CGRect.init(x: 0, y: 0, width: imgTeam.frame.width, height: imgTeam.frame.height)
        imgTeam.contentMode = .scaleAspectFit
        lblScore.frame = CGRect.init(x: imgTeam.isHidden ? 0 : (imgTeam.frame.origin.x + imgTeam.frame.size.width), y: 0, width: lblScore.frame.width, height: lblScore.frame.height)
        if self.isFirstSection{
            lblScore.contentMode = .center
        }else{
            lblScore.contentMode = .left
        }
        bottomDivider.frame =  CGRect.init(x: bottomDivider.frame.origin.x, y: (lblScore.frame.origin.y + lblScore.frame.height) + 5, width: isFirstSection ? (bottomDivider.frame.size.width - bottomDivider.frame.origin.y) :  bottomDivider.frame.size.width, height: 2)

    }
    
    override func prepareForReuse() {
        imgTeam.frame =  CGRect.init(x: 0, y: 0, width: self.frame.size.width * 0.4, height: self.frame.height)
        lblScore.frame = CGRect.init(x: imgTeam.isHidden ? 0 : (imgTeam.frame.origin.x + imgTeam.frame.size.width), y: 0, width: (self.frame.size.width - imgTeam.frame.width) + 5, height: self.frame.height - 10)
        bottomDivider.frame =  CGRect.init(x: 0, y: (lblScore.frame.origin.y + lblScore.frame.height) + 5, width: self.frame.size.width, height: 2)
        imgTeam.image = nil
        lblScore.text = ""
    }
}


