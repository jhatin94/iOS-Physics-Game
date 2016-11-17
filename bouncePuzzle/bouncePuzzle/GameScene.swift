//
//  GameScene.swift
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

import SpriteKit
import GameplayKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let TriangleCategoryName = "triangle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

// category bitmasks
let BallCategory: UInt32 = 0x1 << 0
let BottomCategory: UInt32 = 0x1 << 1
let BlockCategory: UInt32 = 0x1 << 2
let PaddleCategory: UInt32 = 0x1 << 3
let BorderCategory: UInt32 = 0x1 << 4



class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    var isFingerOnPaddle = false
    lazy var gameState: GKStateMachine = GKStateMachine(states: [WaitingForTap(scene: self), Playing(scene: self), GameOver(scene: self)])
    var gameWon: Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWon ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture), SKAction.scale(to: 0.8, duration: 0.25)])
            run(gameWon ? gameWonSound : gameOverSound)
            gameOver.run(actionSequence)
        }
    }
    var gameLost: Bool = false // JHAT: used to disable win checking
    var ball: SKSpriteNode!
    var currentLevel: Int!
    var sceneManager: GameViewController!
    var movingParts: [SKNode] = []
    var isGamePaused: Bool = false
    
    // pause labels
    var pauseTitle = SKLabelNode(fontNamed: "Montserrat-Bold")
    var returnToMain = SKLabelNode(fontNamed: "Montserrat-Bold")
    var restart = SKLabelNode(fontNamed: "Montserrat-Bold")
    
    // sounds
    let blipSound = SKAction.playSoundFileNamed("ball", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddle", waitForCompletion: false)
    let gameWonSound = SKAction.playSoundFileNamed("won", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("lost", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        
        // failure boundary
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        
        // assign category masks
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode   
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        paddle.physicsBody!.collisionBitMask = BallCategory
        borderBody.categoryBitMask = BorderCategory
        
        // get ball/bottom collision
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory | BorderCategory | PaddleCategory
        
        // add trail to ball
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        
        // create launch state
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.05)
        addChild(gameMessage)
        
        initGestures() // init pause gesture
        
        // create pause labels
        pauseTitle = createMontserratLabel(pos: CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 80), fontSize: 30, text: "PAUSED", name: "paused")
        
        returnToMain = createMontserratLabel(pos: CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 10), fontSize: 20, text: "Return to Menu", name: "pausedToMain")
        
        restart = createMontserratLabel(pos: CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 50), fontSize: 20, text: "Restart Level", name: "pausedRestart")
        
        // set up moving block actions
        enumerateChildNodes(withName: "*", using: {
            node, _ in
            let nodeName = node.name
            
            if (nodeName != nil && (nodeName!.contains("path") || nodeName!.contains("sq"))) {
                self.movingParts.append(node)
            }
        })
        
        if (movingParts.count > 1) {
            for node in movingParts {
                let nodeName = node.name!
                if (nodeName.contains("sqv")) { // get corresponding path node
                    let numv = nodeName.substring(from: nodeName.index(nodeName.endIndex, offsetBy: -1))
                    let pathvNode = self.childNode(withName: "pathv\(numv)") as! SKSpriteNode
                    let sqvNode = node
                    sqvNode.physicsBody!.collisionBitMask = BallCategory
                    
                    let actionMoveOnev = SKAction.move(to: CGPoint(x: sqvNode.position.x, y: sqvNode.position.y - (pathvNode.frame.size.height)), duration: 2.0)
                    
                    let actionMoveBackv = SKAction.move(to: CGPoint(x: sqvNode.position.x, y: (pathvNode.position.y) + (pathvNode.frame.size.height)/2), duration: 2.0)
                
                    sqvNode.run(SKAction.repeatForever(SKAction.sequence([actionMoveOnev, actionMoveBackv])))
                }
                else if (nodeName.contains("sqh")) {
                    let numh = nodeName.substring(from: nodeName.index(nodeName.endIndex, offsetBy: -1))
                    let pathhNode = self.childNode(withName: "pathh\(numh)")
                    let sqhNode = node
                    sqhNode.physicsBody!.collisionBitMask = BallCategory
                    
                    let actionMoveOneh = SKAction.move(to: CGPoint(x: sqhNode.position.x + (pathhNode?.frame.size.width)!, y: sqhNode.position.y), duration: 2.0)
                    let actionMoveBackh = SKAction.move(to: CGPoint(x: (pathhNode?.position.x)! - (pathhNode?.frame.size.width)!/2, y: sqhNode.position.y), duration: 2.0)
                    
                    sqhNode.run(SKAction.repeatForever(SKAction.sequence([actionMoveOneh, actionMoveBackh])))
                }
            }
        }
        
        gameState.enter(WaitingForTap.self)
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch (gameState.currentState) {
        case is WaitingForTap:
            gameState.enter(Playing.self)
            isFingerOnPaddle = true
            break
        case is Playing:
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            
            if let body = physicsWorld.body(at: touchLocation) {
                if (body.node!.name == PaddleCategoryName) {
                    isFingerOnPaddle = true
                }
            }
            if (isGamePaused) {
                let node = self.atPoint(touchLocation)
                if (node.name == "pausedToMain") {
                    togglePause()
                    sceneManager.loadMenu(menuToLoad: MenuScene.MenuType.main)
                }
                else if (node.name == "pausedRestart") {
                    togglePause()
                    sceneManager.loadGameScene(lvl: currentLevel)
                }
            }
            
            break
        case is GameOver:
            if (currentLevel >= 10 && gameWon) { // TODO: Change cap as levels increase
                // Show Game Complete Screen
                sceneManager.loadMenu(menuToLoad: MenuScene.MenuType.completed)
            }
            else {
                // Call ViewController to change Scene
                gameWon ? sceneManager.loadGameScene(lvl: currentLevel + 1) : sceneManager.loadGameScene(lvl: currentLevel)
            }
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFingerOnPaddle && !isGamePaused) {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
            
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (!isGamePaused) {
            gameState.update(deltaTime: currentTime)
            let complete = isGameWon()
            if (complete && !gameLost) {
                gameWon = true
                gameState.enter(GameOver.self)
                
            }
        }
        else {
            physicsWorld.speed = 0.0
            self.view?.isPaused = true
        }
    }
    
    // create gesture functions
    func initGestures() {
        // setup pause two finger touch
        let pauseTap = UITapGestureRecognizer(target: self, action: #selector(togglePause))
        pauseTap.numberOfTapsRequired = 1
        pauseTap.numberOfTouchesRequired = 2
        pauseTap.delegate = self
        view!.addGestureRecognizer(pauseTap)
    }
    
    func togglePause() {
        if (gameState.currentState! is Playing) {
            isGamePaused = !isGamePaused
            showHidePauseLabels(show: isGamePaused)
        }
    }
    
    func showHidePauseLabels(show: Bool) {
        if (!show) {
            pauseTitle.removeFromParent()
            returnToMain.removeFromParent()
            restart.removeFromParent()
            
            self.view?.isPaused = false
            physicsWorld.speed = 1.0
        }
        else {
            addChild(pauseTitle)
            addChild(returnToMain)
            addChild(restart)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }
            else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            // determine collisions for sound            
            if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory) {
                run(blipSound)
            }
            else if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory) {
                run(blipPaddleSound)
            }
            
            // determine collisions for gameplay
            if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory) {
                // failed
                gameState.enter(GameOver.self)
                gameWon = false
                gameLost = true
            }
            else if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory) {
                // determine which half of paddle collided
                if (contact.contactPoint.x > (secondBody.node?.position.x)!) { // right side contact
                    physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.2)
                }
                else if (contact.contactPoint.x < (secondBody.node?.position.x)!) { // left side contact
                    physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.8)
                }
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }
            else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory){
                // determine which half of paddle hit
                if (contact.contactPoint.x > (secondBody.node?.position.x)!) { // right side contact
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
                    })
                }
                else if (contact.contactPoint.x < (secondBody.node?.position.x)!) { // left side contact
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
                    })
                }
            }}
    }
    
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return rand * (to - from) + from
    }
    
    func isGameWon() -> Bool {
        return ball.position.x >= self.frame.width - ball.frame.size.width
    }
}
