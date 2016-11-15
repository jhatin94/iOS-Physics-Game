//
//  MenuScene.swift
//  bouncePuzzle
//
//  Created by student on 11/15/16.
//  Copyright © 2016 student. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    let sceneManager: GameViewController
    
    enum MenuType {
        case main
        case instructions
        case levelSelect
    }
    
    init(menuToDisplay: MenuType, sceneManager: GameViewController, size: CGSize) {
        self.sceneManager = sceneManager
        super.init(size: size)
        
        // draw menu based on MenuType
        switch (menuToDisplay) {
        case MenuType.main:
            drawMainMenu()
            break
        case MenuType.levelSelect:
            drawLevelSelect()
            break
        case MenuType.instructions:
            drawInstr()
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // JHAT: override touchesBegan to detect if options were selected
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Choose a touch to work with
        guard let touch = touches.first else { return };
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        switch (node.name) {
        case "play"?:
            sceneManager.loadGameScene(lvl: 1)
            break
        default:
            break
        }
    }
    
    // MARK: menu drawing methods
    func drawMainMenu() {
        backgroundColor = SKColor.black
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 700), fontSize: 108, text: "REBOUND", name: "title"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 2), fontSize: 50, text: "Play", name: "play"))
    }
    
    func drawLevelSelect() {
        
    }
    
    func drawInstr() {
        
    }
}
