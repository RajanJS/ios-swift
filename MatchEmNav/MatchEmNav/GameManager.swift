//
//  GameManager.swift
//  MatchEmNav
//
//  Created by Rajan Maharjan on 25/04/2021.
//
import Foundation

class GameManager {
    static let shared = GameManager()
    var firstHighestScore  = 0
    var secondHighestScore = 0
    var thirdHighestScore = 0
    
    // Random transparency on or off
    var randomAlpha = true
    var isSwitchBackgroundOn: Bool = false
    
    // Rectangle creation interval
    var newRectPairInterval: TimeInterval = 1.5
    let newRectIntervalMin: TimeInterval = 0.5
    let newRectIntervalMax: TimeInterval = 5.0
    
    // Game duration
    var gameDuration: TimeInterval = 12
    
    // How long for the rectangle to fade away
    var fadeDuration: TimeInterval = 0.8
    let newfadeDurMin: TimeInterval = 0.5
    let newfadeDurMax: TimeInterval = 1.5
}
