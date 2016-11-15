//
//  PlayerData.swift
//  bouncePuzzle
//
//  Created by student on 11/15/16.
//  Copyright © 2016 student. All rights reserved.
//

import Foundation

class PlayerData {
    // singleton
    static let playerData = PlayerData()
    
    // data
    var highestLevelCompleted: Int = 0
    
    private init() { }
    
    func setHighestLevelComplete(maxLevelComp: Int) {
        self.highestLevelCompleted = maxLevelComp
    }
}
