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



class GameScene: SKScene, SKPhysicsContactDelegate {
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
            break
        case is GameOver:
            if (currentLevel < 5) { // TODO: Change cap as levels increase
                // Call ViewController to change Scene
                gameWon ? sceneManager.loadGameScene(lvl: currentLevel + 1) : sceneManager.loadGameScene(lvl: currentLevel)
            }
            else {
                // TODO: Show Game Complete Screen
            }
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFingerOnPaddle) {
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
        gameState.update(deltaTime: currentTime)
        let complete = isGameWon()
        if (complete && !gameLost) {
            gameWon = true
            gameState.enter(GameOver.self)
            
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
