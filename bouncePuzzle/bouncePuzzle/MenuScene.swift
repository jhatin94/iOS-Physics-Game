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
        case completed
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
        case MenuType.completed:
            drawComplete()
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
        case "play"?: // main menu selectables
            sceneManager.loadMenu(menuToLoad: MenuType.levelSelect)
            break
        case "instr"?:
            sceneManager.loadMenu(menuToLoad: MenuType.instructions)
            break
        case "returnHTP"?: // how to play selectables
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "lvl1"?: // Level Select Selectables
            sceneManager.loadGameScene(lvl: 1)
            break
        case "lvl2"?:
            sceneManager.loadGameScene(lvl: 2)
            break
        case "lvl3"?:
            sceneManager.loadGameScene(lvl: 3)
            break
        case "lvl4"?:
            sceneManager.loadGameScene(lvl: 4)
            break
        case "lvl5"?:
            sceneManager.loadGameScene(lvl: 5)
            break
        case "lvl6"?:
            sceneManager.loadGameScene(lvl: 6)
            break
        case "lvl7"?:
            sceneManager.loadGameScene(lvl: 7)
            break
        case "lvl8"?:
            sceneManager.loadGameScene(lvl: 8)
            break
        case "lvl9"?:
            sceneManager.loadGameScene(lvl: 9)
            break
        case "lvl10"?:
            sceneManager.loadGameScene(lvl: 10)
            break
        case "lvl11"?:
            sceneManager.loadGameScene(lvl: 11)
            break
        case "lvl12"?:
            sceneManager.loadGameScene(lvl: 12)
            break
        case "lvl13"?:
            sceneManager.loadGameScene(lvl: 13)
            break
        case "lvl14"?:
            sceneManager.loadGameScene(lvl: 14)
            break
        case "lvl15"?:
            sceneManager.loadGameScene(lvl: 15)
            break
        case "returnLS"?:
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "returnC"?: // Game complete selectables
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        default:
            break
        }
    }
    
    // MARK: menu drawing methods
    func drawMainMenu() {
        backgroundColor = SKColor.black
        
    
        let logo = SKSpriteNode(imageNamed: "rebound")
        logo.position = CGPoint(x: frame.size.width / 2, y: size.height-50)
        logo.setScale(0.3)
        logo.zPosition = 1
        addChild(logo)
        
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 10), fontSize: 30, text: "Play", name: "play"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 90), fontSize: 30, text: "How To Play", name: "instr"))
    }
    
    func drawLevelSelect() {
        backgroundColor = SKColor.black
        let levelsUnlocked = PlayerData.playerData.highestLevelCompleted + 1
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height - 50), fontSize: 36, text: "Level Select", name: "lvlSelectTitle"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/5, y: size.height/2 + 60), fontSize: 30, text: "Level 1", name: "lvl1"))
        
        if (levelsUnlocked > 1) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/5, y: size.height/2 + 20), fontSize: 30, text: "Level 2", name: "lvl2"))
        }
        
        if (levelsUnlocked > 2) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/5, y: size.height/2 - 20), fontSize: 30, text: "Level 3", name: "lvl3"))
        }
        
        if (levelsUnlocked > 3) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/5, y: size.height/2 - 60), fontSize: 30, text: "Level 4", name: "lvl4"))
        }
        
        if (levelsUnlocked > 4) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/5, y: size.height/2 - 100), fontSize: 30, text: "Level 5", name: "lvl5"))
        }
        
        if (levelsUnlocked > 5) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 60), fontSize: 30, text: "Level 6", name: "lvl6"))
        }
        
        if (levelsUnlocked > 6) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 20), fontSize: 30, text: "Level 7", name: "lvl7"))
        }
        
        if (levelsUnlocked > 7) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 20), fontSize: 30, text: "Level 8", name: "lvl8"))
        }
        
        if (levelsUnlocked > 8) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 60), fontSize: 30, text: "Level 9", name: "lvl9"))
        }
        
        if (levelsUnlocked > 9) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 30, text: "Level 10", name: "lvl10"))
        }
        
        if (levelsUnlocked > 10) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width * 4/5, y: size.height/2 + 60), fontSize: 30, text: "Level 11", name: "lvl11"))
        }
        
        if (levelsUnlocked > 11) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width * 4/5, y: size.height/2 + 20), fontSize: 30, text: "Level 12", name: "lvl12"))
        }
        
        if (levelsUnlocked > 12) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width * 4/5, y: size.height/2 - 20), fontSize: 30, text: "Level 13", name: "lvl13"))
        }
        
        if (levelsUnlocked > 13) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width * 4/5, y: size.height/2 - 60), fontSize: 30, text: "Level 14", name: "lvl14"))
        }
        
        if (levelsUnlocked > 14) {
            addChild(createMontserratLabel(pos: CGPoint(x: size.width * 4/5, y: size.height/2 - 100), fontSize: 30, text: "Level 15", name: "lvl15"))
        }
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/7, y: 20), fontSize: 14, text: "Return to Main Menu", name: "returnLS"))
    }
    
    func drawInstr() {
        backgroundColor = SKColor.black
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height - 50), fontSize: 36, text: "How To Play", name: "instrTitle"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 50), fontSize: 20, text: "Try and get the ball to the right edge of the screen!", name: "instr1"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 20, text: "The right side of the paddle makes the ball bounce higher", name: "instr2"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 50), fontSize: 20, text: "The left side of the paddle makes the ball bounce lower", name: "instr3"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 20, text: "Touch the screen with two fingers to pause", name: "instr4"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/7, y: 20), fontSize: 14, text: "Return to Main Menu", name: "returnHTP"))
    }
    
    func drawComplete() {
        backgroundColor = SKColor.black
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height - 50), fontSize: 36, text: "Congratulations!", name: "compTitle"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 50), fontSize: 20, text: "You have finished all of the levels!", name: "comp1"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 20, text: "Thank you for playing!", name: "comp2"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 50), fontSize: 20, text: "You can now replay any level in Level Select", name: "comp3"))
        
        addChild(createMontserratLabel(pos: CGPoint(x: size.width/7, y: 20), fontSize: 14, text: "Return to Main Menu", name: "returnC"))
    }
}
