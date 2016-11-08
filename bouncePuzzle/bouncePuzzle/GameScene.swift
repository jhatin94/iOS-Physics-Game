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
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture), SKAction.scale(to: 1.0, duration: 0.25)])
            run(gameWon ? gameWonSound : gameOverSound)
            gameOver.run(actionSequence)
        }
    }
    
    // sounds
    let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
    let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
    let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        
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
        
        // add blocks
        let numberOfBlocks = 8
        let blockWidth = SKSpriteNode(imageNamed: "block").size.width
        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        
        let xOffset = (frame.width - totalBlocksWidth)/2
        
        /*for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "block.png")
            block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth, y: frame.height * 0.8)
            
            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.isDynamic = false
            block.name = BlockCategoryName
            block.physicsBody!.categoryBitMask = BlockCategory
            block.zPosition = 2
            addChild(block)
        }*/
        
        // create launch state
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
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
            let newScene = GameScene(fileNamed: "GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
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
            }
            else if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory) {
                breakBlock(node: secondBody.node!)
                // check if game is won
                if (isGameWon()) {
                    gameState.enter(GameOver.self)
                    gameWon = true
                }
            }
        }
    }
    
    func breakBlock(node: SKNode) {
        run(bambooBreakSound)
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return rand * (to - from) + from
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BlockCategoryName) {
            node, stop in
            numberOfBricks += 1
        }
        return numberOfBricks == 0
    }
}
