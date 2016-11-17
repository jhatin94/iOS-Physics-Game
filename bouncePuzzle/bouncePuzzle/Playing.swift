//
//  Created by Justin on 1/16/16.
//

import SpriteKit
import GameplayKit

class Playing: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState is WaitingForTap {
            let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
            ball.physicsBody!.pinned = false
            ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(isNeg: false), dy: randomDirection(isNeg: false)))
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let paused = scene.isGamePaused
        
        if (!paused) {
            scene.enumerateChildNodes(withName: TriangleCategoryName){ // automatically filters out nil
                node, _ in
                node.zRotation = node.zRotation - 0.05;
            }
            
            let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
            let xNeg = ball.physicsBody!.velocity.dx < 0
            let yNeg = ball.physicsBody!.velocity.dy < 0
            let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
            let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
            
            //let speed = sqrt(xSpeed + ySpeed)
            
            if (xSpeed <= 100.0) {
                ball.physicsBody!.velocity = (CGVector(dx: randomDirection(isNeg: xNeg) * 40, dy: ball.physicsBody!.velocity.dy))
            }
            if (ySpeed <= 100.0) {
                ball.physicsBody!.velocity = (CGVector(dx: ball.physicsBody!.velocity.dx, dy: randomDirection(isNeg: yNeg) * 40))
            }
            //print("Speed: \(speed)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type
    }
    
    func randomDirection(isNeg: Bool) -> CGFloat {
        let speedFactor: CGFloat = 2.0
        //print("Adding Impulse")
        if (isNeg) {
            return -speedFactor
        }
        else {
            return speedFactor
        }
    }
}
