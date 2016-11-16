//
//  GameViewController.swift
//  Bamboo Breakout
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    let screenSize = CGSize(width: 568, height: 320)
    var gameScene: GameScene?
    var menuScene: MenuScene?
    var skView: SKView!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        
        // load player profile
        loadPlayerData()
        
        // register profile to save when app is closed
        NotificationCenter.default.addObserver(self, selector: #selector(saveUserDataOnExit), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        // Load menu
        loadMenu(menuToLoad: MenuScene.MenuType.main)
    }
    
    // MARK: Scene loading funcs
    func loadMenu(menuToLoad: MenuScene.MenuType) {
        // clear other scenes from memory
        clearGameSceneFromMemory()
        menuScene = MenuScene(menuToDisplay: menuToLoad, sceneManager: self, size: screenSize)
        let reveal = SKTransition.fade(withDuration: 2)
        skView.presentScene(menuScene!, transition: reveal)
    }
    
    func loadGameScene(lvl: Int) {
        // clear other scenes from memory
        clearMenuSceneFromMemory()
        updateLevelsComplete(lvlLoading: lvl) // update playerData if new level is complete
        gameScene = GameScene(fileNamed: "level\(lvl)")
        gameScene?.scaleMode = .aspectFit    /* Set the scale mode to scale to fit the window */
        gameScene?.sceneManager = self
        gameScene?.currentLevel = lvl
        let reveal = SKTransition.fade(withDuration: 2)
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func loadCompleteScene() {
        // clear other scenes from memory
        clearGameSceneFromMemory()
        clearMenuSceneFromMemory()
    }
    
    // MARK: Model interaction functions
    private func loadPlayerData() {
        let lvlsCompleted = defaults.integer(forKey: "level")
        
        PlayerData.playerData.setHighestLevelComplete(maxLevelComp: lvlsCompleted)
    }
    
    func saveProgress(dataToSave: PlayerData) {
        defaults.set(dataToSave.highestLevelCompleted, forKey: "level")
    }
    
    func saveUserDataOnExit() {
        saveProgress(dataToSave: PlayerData.playerData)
    }
    
    private func updateLevelsComplete(lvlLoading: Int) {
        // JHAT: check if the level prior to the level loading has been beaten
        let priorCompletedLevel = lvlLoading - 1;
        
        if (priorCompletedLevel > PlayerData.playerData.highestLevelCompleted) {
            PlayerData.playerData.setHighestLevelComplete(maxLevelComp: priorCompletedLevel)
            saveUserDataOnExit() // JHAT: method is simpler to use here even though not leaving app
        }
    }
        
    // MARK: memory freeing functions
    private func clearGameSceneFromMemory() {
        if (gameScene != nil) {
            gameScene = nil
        }
    }
    
    private func clearMenuSceneFromMemory() {
        if (menuScene != nil) {
            menuScene = nil
        }
    }
    
    // MARK: Standard funcs
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
