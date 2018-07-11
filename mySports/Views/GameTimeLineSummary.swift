//
//  GameTimeLineSummary.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import Foundation
import UIKit

/// Delegate for GameSegmentsView
public protocol GameSegmentsViewDelegate: class {

    func didSelectGameSegments(forSegment segmentID: Int)
}

class GameSegmentsView: UIView{
    var segmentsScrollView: UIScrollView!
    var segments: TimeLineSegmentedControl!
    var separatorLabel: UILabel!
    
    public weak var delegate: GameSegmentsViewDelegate?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        segmentsScrollView = UIScrollView.init(frame: frame)
        
        self.addSubview(segmentsScrollView)
        segments = TimeLineSegmentedControl(frame: CGRect(x: 20, y: 5,
                                                          width:frame.width + 20, height: self.frame.height - 15))
        self.commonInit()
        
        self.separatorLabel = UILabel.init(frame: CGRect(x: 0, y: segments.frame.origin.y + segments.frame.height + 9,
                                                         width:segments.frame.width + 20, height: 1))
        self.separatorLabel.backgroundColor = UIColor.darkGray
        
        self.segmentsScrollView.addSubview(separatorLabel)
        
        segmentsScrollView.contentSize =  CGSize(width: segments.frame.width + 20, height: self.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func setupSegments(){
        // Initialize
        let items =  ["SCORE SUMMARY", "BOX SCORE", "GAME STATS"]
        // Set up Frame and SegmentedControl
        for (index, item) in items.enumerated(){
            segments.insertSegment(withTitle: item, at: index, animated: false)
        }
        segments.selectedSegmentIndex = 0
        
        // Style the Segmented Control
        segments.backgroundColor = UIColor.black
        
        // Add target action method
        segments.addTarget(self, action: #selector(changeGameSegment), for: .valueChanged)
        
        // Add this custom Segmented Control to our view
        segmentsScrollView.addSubview(segments)
        
    }
    
    @objc func changeGameSegment(sender: UISegmentedControl) {
       
        self.delegate?.didSelectGameSegments(forSegment: self.segments.selectedSegmentIndex)
        
    }
    
    private func commonInit() {
        segmentsScrollView.backgroundColor = UIColor.black
        segmentsScrollView.bounces = false
        segmentsScrollView.showsVerticalScrollIndicator = false
        segmentsScrollView.showsHorizontalScrollIndicator = false
        
        setupSegments()
        self.backgroundColor = UIColor.black
    }
    
}

class TimeLineSegmentedControl: UISegmentedControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }

    func commonInit() {
        self.tintColor = UIColor.clear
        let attributes = [NSAttributedStringKey.foregroundColor : UIColor.darkGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        let attributesSelected = [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
        self.setTitleTextAttributes(attributes, for: .normal)
        self.setTitleTextAttributes(attributesSelected, for: .selected)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.black
    }
}

