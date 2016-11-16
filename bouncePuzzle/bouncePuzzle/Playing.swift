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
            ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        scene.enumerateChildNodes(withName: TriangleCategoryName){ // automatically filters out nil
            node, _ in
            node.zRotation = node.zRotation - 0.05;
        }
        
        let ball = scene.childNode(withName: BallCategoryName) as! SKSpriteNode
        let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
        let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        let speed = sqrt(xSpeed + ySpeed)
        let gravityOn = scene.physicsWorld.gravity.dy < 0
        
        if (xSpeed <= 100.0 && !gravityOn) {
            ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: 0.0))
        }
        if (ySpeed <= 100.0 && !gravityOn) {
            ball.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: randomDirection()))
        }
        print("Speed: \(speed)")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type
    }
    
    func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = 2.0
        print("Adding Impulse")
        if (scene.randomFloat(from: 0.0, to: 100.0) >= 50) {
            return -speedFactor
        }
        else {
            return speedFactor
        }
    }
}
