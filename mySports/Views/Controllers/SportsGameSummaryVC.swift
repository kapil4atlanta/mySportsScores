//
//  ViewController.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import UIKit

class SportsGameSummaryVC: UIViewController {
    @IBOutlet weak var gameTableView: UITableView!
    
    var gameID: String!
    var currentGame: Game?
    var gameList: GameList?
    let identifier = "Cell"
    var sportsCarousal: SportsCarousalView? = nil
    var boxScoreView: GameBoxScoreView? = nil
    var gameSegmentsView: GameSegmentsView? = nil
    var gamestatsView: GameStatsView? = nil
    var scoreSummaryView: GameScoreSummaryView? = nil
    var pageTitle: String = "Please Select a Game"
    var numberOfRows: Int = 3
    var cellHeights: [IndexPath : CGFloat] = [:]
    var gameArray: [Game] = []
    var gameInfo: ScoreSummaryModel? = nil
    var sportsCarousalHeight: CGFloat = 135
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = pageTitle
        gameTableView?.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        gameTableView.estimatedRowHeight = 60.0
        gameTableView?.rowHeight = UITableViewAutomaticDimension
        
        gameTableView?.bounces = false
        gameTableView.delegate = self
        gameTableView.dataSource = self
        gameTableView.allowsSelection = false
        gameTableView.backgroundColor = UIColor.black
        gameTableView.separatorColor = UIColor.clear
        
        
        SportsDataManager.shared.delegate = self
        
        SportsDataManager.shared.getSportsScheduleData { (result) in
            if result == true{
                print("Schedule Updated")
            }
        }
        
        self.view.backgroundColor = UIColor.black
        self.populateTableviewForSegment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func populateTableviewForSegment() {

//        self.currentGame = currentGame
//        self.gameList = gameList
        
        sportsCarousal = SportsCarousalView.init(origin: CGPoint(x: 0, y: 0), width: self.view.frame.width, height: 120, info: gameList)
        sportsCarousal?.delegate = self
        gameSegmentsView = GameSegmentsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        gameSegmentsView?.delegate = self
        
        if let currentGame = currentGame{
             loadData(currentGame: currentGame)
        }
       
    }
    
    private func preparedataSource(){
        if let path = Bundle.main.path(forResource: "SportsGames", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonDecoder = JSONDecoder()
                if let gameList = try? jsonDecoder.decode(GameList.self, from: data){
                    self.gameList = gameList
                    for game in gameList.games{
                        gameArray.append(game)
                    }
                }
                
            }catch let testError{
                print(testError)
            }
        }
    }
    
    private func loadData(currentGame: Game){
        if let data = SportsDataManager.shared.getGameDetailsObject(){
            gameInfo = data
        }else if let data = self.getLocalGameTLSScore(){
            gameInfo = data
        }
        
        guard let gameInfo = gameInfo, let gamelist = self.gameList else {
            return
        }
            scoreSummaryView = GameScoreSummaryView(origin: .zero, width: self.view.frame.width, info: gameInfo, gameList: gamelist)
            boxScoreView = GameBoxScoreView(origin: .zero, width: self.view.frame.width, info: gameInfo, gameList: gamelist)
           gamestatsView = GameStatsView(origin: .zero, width: self.view.frame.width, gameInfo: gameInfo, gameList: gamelist)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait //Default interface orientation of iPhone is portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.async{
            self.populateTableviewForSegment()
            self.gameTableView.reloadData()
        }
    }

}

extension SportsGameSummaryVC: SportsCarousalDelegate{
    func didSelectGame(forGameID gameID: String) {
        if gameList?.games.count == 0{
            preparedataSource()
        }
        
        if let currentGame = gameList?.getGameforGameId(gameID: gameID), let gameID = currentGame.id{
            self.currentGame = currentGame
            self.title = String(format: "%@ Vs %@", currentGame.away.name ?? "", currentGame.home.name ?? "")
            SportsDataManager.shared.getGameDetails(gameID: gameID) { (result) in
                print("GameDetails result is %@", result)
            }
        }
    }
}

extension SportsGameSummaryVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var returnVal = CGFloat((indexPath.row + 1) * 35)
        guard let index = gameSegmentsView?.segments.selectedSegmentIndex, let gameSegmentsView = gameSegmentsView else{
            return returnVal
        }
        switch index {
        case 0:
            switch indexPath.row {
            case 0:
                returnVal = sportsCarousalHeight // Carousal
            case 1:
                returnVal = gameSegmentsView.frame.height
            case 2:
                if let scoreSummaryView = scoreSummaryView{
                    returnVal = scoreSummaryView.frame.height + 20
                }
            default:
                return returnVal
                
            }
        case 1:
            switch indexPath.row {
                
            case 0:
                returnVal = sportsCarousalHeight // Header
            case 1:
                returnVal = gameSegmentsView.frame.height
            case 2:
                if let boxScoreView = boxScoreView{
                    returnVal = boxScoreView.frame.height + 20
                }
            default:
                return returnVal
            }
        case 2:
            switch indexPath.row {
            case 0:
                returnVal = sportsCarousalHeight // Header
            case 1:
                returnVal = gameSegmentsView.frame.height
            case 2:
                if let gamestatsView = gamestatsView{
                    returnVal = gamestatsView.frame.height + 20
                }
            default:
                return returnVal
                
            }
        default:
            return returnVal
        }
        return returnVal
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return sportsCarousalHeight }
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if let subViews = cell?.contentView.subviews{
            for subView in subViews{
                subView.removeFromSuperview()
            }
        }
        cell?.contentView.backgroundColor = UIColor.black
        cell?.backgroundColor = UIColor.black
        
        guard let index = gameSegmentsView?.segments.selectedSegmentIndex else{
            return cell!
        }
        
        switch index {
        case 0:
            switch indexPath.row {
            case 0:
                sportsCarousal?.tag = ((indexPath.row + 1) * 20)
                if let sportsCarousalView = sportsCarousal{
                    cell?.contentView.addSubview(sportsCarousalView)
                }
            case 1:
                gameSegmentsView?.tag = ((indexPath.row + 1) * 20)
                if let gameSegmentsView = gameSegmentsView{
                    cell?.contentView.addSubview(gameSegmentsView)
                }
            case 2:
                scoreSummaryView?.tag = ((indexPath.row + 1) * 20)
                if let scoreSummaryView = scoreSummaryView{
                    cell?.contentView.addSubview(scoreSummaryView)
                }
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0:
                sportsCarousal?.tag = ((indexPath.row + 1) * 20)
                if let sportsCarousalView = sportsCarousal{
                    cell?.contentView.addSubview(sportsCarousalView)
                }
            case 1:
                gameSegmentsView?.tag = ((indexPath.row + 1) * 20)
                if let gameSegmentsView = gameSegmentsView{
                    cell?.contentView.addSubview(gameSegmentsView)
                }
            case 2:
                boxScoreView?.tag = ((indexPath.row + 1) * 20)
                if let boxScoreView = boxScoreView{
                    cell?.contentView.addSubview(boxScoreView)
                }
            default: break
            }
        case 2:
            switch indexPath.row {
            case 0:
                sportsCarousal?.tag = ((indexPath.row + 1) * 20)
                if let sportsCarousalView = sportsCarousal{
                    cell?.contentView.addSubview(sportsCarousalView)
                }
            case 1:
                gameSegmentsView?.tag = ((indexPath.row + 1) * 20)
                if let gameSegmentsView = gameSegmentsView{
                    cell?.contentView.addSubview(gameSegmentsView)
                }
            case 2:
                gamestatsView?.tag = ((indexPath.row + 1) * 20)
                if let gamestatsView = gamestatsView{
                    cell?.contentView.addSubview(gamestatsView)
                }
            default: break
            }
        default:
            return cell!
        }
        
        
        cell?.clipsToBounds = true
        return cell!
    }
    
}
extension SportsGameSummaryVC : GameSegmentsViewDelegate{
    func didSelectGameSegments(forSegment segmentID: Int) {
        self.gameTableView.reloadData()
    }
}

extension SportsGameSummaryVC: SportsDataManagerDelegate{
    func updatedInformationAvailable(isUpdated: Bool) {
        if isUpdated{
            DispatchQueue.main.async{
                if let game = self.currentGame{
                    self.title = String(format: "%@ / %@", game.away.alias ?? "", game.home.alias ?? "")
                    self.loadData(currentGame: game)
                    self.gameTableView.reloadData()
                }
            }
        }else{
            let alert = UIAlertController.init(title: "GameDetails", message: "Unavailable, Please Try Again Later", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
             self.present(alert, animated: true, completion: nil)
        }
    }
    func updatedScheduleInfo(isUpdated: Bool){
        if isUpdated{
            DispatchQueue.main.async {
                if let games = SportsDataManager.shared.getGameScheduleObject(){
                    self.gameList = games
                    self.sportsCarousal?.updateSportsCarousal(info: games)
                    self.gameTableView.beginUpdates()
                    self.gameTableView.reloadSections(IndexSet(integer: 0), with: .fade)
                    self.gameTableView.endUpdates()
                }
            }
        }
    }
}

extension SportsGameSummaryVC{
    func getLocalGameTLSScore() -> ScoreSummaryModel? {
        var returnObject: ScoreSummaryModel? = nil
        
        if let path = Bundle.main.path(forResource: "SportslineScoreData", ofType: "json") {
            //Implement JSON decoding and parsing
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                //Decode retrived data with JSONDecoder and assisting type of Article object
                returnObject = try decoder.decode(ScoreSummaryModel.self, from: data)
                
            } catch let jsonError {
                print(jsonError)
            }
        }
        return returnObject
    }
}
