//
//  SportsCarousalView.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation
import UIKit

fileprivate let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
fileprivate var cellSize:CGSize = .zero

/// Delegate for SportsCarousalDelegate
public protocol SportsCarousalDelegate: class {
    
    func didSelectGame(forGameID gameID: String)
}


class SportsCarousalView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var sportsCollectionView: UICollectionView?
    private let contentCellIdentifier = "sportsCarousalCellID"
    private var cellHeight: CGFloat = 135
    private var gameArray: [Game] = []
    private var GameInfo: GameList!
    public weak var delegate: SportsCarousalDelegate?
    
    init(origin: CGPoint, width: CGFloat, height: CGFloat, info: GameList?) {
        super.init(frame: CGRect.init(x: origin.x, y: origin.y, width: width, height: height))
        
        if let info = info{
            GameInfo = info
            for game in info.games{
                gameArray.append(game)
            }
        }
        self.commonInit()
        if gameArray.count == 0{
            self.preparedataSource()
        }
        
        if let lastGame = gameArray.last, gameArray.count < 3{
            while gameArray.count < 3{
                gameArray.append(lastGame)
            }
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = sectionInsets
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumInteritemSpacing = sectionInsets.right
        layout.minimumLineSpacing = sectionInsets.right
        
        let itemsPerRow: CGFloat = 3 //gameArray.count > 2 ? 3 : CGFloat(gameArray.count)
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = self.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        layout.itemSize =  CGSize(width: widthPerItem, height: cellHeight - 6)
        cellSize = layout.itemSize
        
        sportsCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: cellHeight), collectionViewLayout: layout)
        sportsCollectionView?.delegate = self
        sportsCollectionView?.dataSource = self
        sportsCollectionView?.bounces = false
        sportsCollectionView?.register(UINib(nibName: "SportsCarousalCell", bundle: nil),
                                       forCellWithReuseIdentifier: contentCellIdentifier)
        sportsCollectionView?.backgroundColor = UIColor.white
        
        self.addSubview(sportsCollectionView!)
        
        self.backgroundColor = UIColor.white
        
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: (sportsCollectionView?.frame.size.height)!)
    }
    
    
    private func preparedataSource(){
        if let path = Bundle.main.path(forResource: "SportsGames", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonDecoder = JSONDecoder()
                if let gameList = try? jsonDecoder.decode(GameList.self, from: data){
                    GameInfo = gameList
                    for game in gameList.games{
                        gameArray.append(game)
                    }
                }
                
            }catch let testError{
                print(testError)
            }
        }

    }
    
    func updateSportsCarousal(info: GameList){
        guard let sportsCollectionView = self.sportsCollectionView, info.games.count > 0 else {
            return
        }
        
        gameArray.removeAll()
        for game in info.games{
            gameArray.append(game)
        }
        
        if let lastGame = gameArray.last, gameArray.count < 3{
            while gameArray.count < 3{
                gameArray.append(lastGame)
            }
        }
        
        if !gameArray.isEmpty{
            DispatchQueue.main.async{
                let previousOffset = sportsCollectionView.contentSize.width - sportsCollectionView.contentOffset.x
                self.sportsCollectionView?.reloadData()
                sportsCollectionView.contentOffset = CGPoint(x: sportsCollectionView.contentSize.width - previousOffset, y: 0)
            }
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 5 // default
        if gameArray.count != 0{
            count = gameArray.count
        }
        return count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                      for: indexPath) as! sportsCarousalCell
        cell.backgroundColor = UIColor.black
        // Configure the cell
        let game = gameArray[indexPath.row]
       
        if  let gameName  = GameInfo.league.name, let awayTeamCode =  game.away.alias, let homeTeamCode = game.home.alias, let awayImage = UIImage.init(named: gameName + "TeamLogos/" + (awayTeamCode.lowercased())), let homeImage = UIImage.init(named: gameName + "TeamLogos/" + (homeTeamCode.lowercased())){
            cell.awayTeamImage.image = awayImage
            cell.homeTeamImage.image = homeImage
        }
        if let awayScore = game.away_points, let homeScore = game.home_points{
            cell.awayTeamScore.text = "\(awayScore)"
            cell.homeTeamScore.text = "\(homeScore)"
        }

        if let gameName  = GameInfo.league.name, let phase = game.status{
            cell.gameLabel.text = gameName + " " + phase
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = gameArray[indexPath.row]
        if let gameID = game.id{
             self.delegate?.didSelectGame(forGameID: gameID)
        }
       
    }
    
}


class sportsCarousalCell: UICollectionViewCell{
    
    @IBOutlet weak var sportsCellView: UIView!
    
    @IBOutlet weak var homeTeamScore: UILabel!
    @IBOutlet weak var awayTeamScore: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var gameLabel: UILabel!
  
    @IBOutlet weak var backgroungImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        let frame = CGRect.init(origin: .zero, size: cellSize)
        sportsCellView.frame = frame
    }

}
