//
//  GameScene.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Clinton VanSciver on 1/5/15.
//  Copyright (c) 2015 Clinton VanSciver. All rights reserved.
//

import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let BlockNodeCategoryName = "blockNode"

let BallCategory    : UInt32 = 0x1 << 0
let BottomCategory  : UInt32 = 0x1 << 1
let BlockCategory   : UInt32 = 0x1 << 2
let PaddleCategory  : UInt32 = 0x1 << 3


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isFingerOnPaddle = false
    
    
    
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
    
        // Create a physics body that borders the screen.
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // Set the friction of that physics body to 0.
        borderBody.friction = 0
        // Set physicsBody of scene to borderBody
        self.physicsBody = borderBody
        
        // Create physics body stretching across bottom of screen for
        // collision detection with the ball.
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        addChild(bottom)
    
        // Remove all gravity from scene
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        physicsWorld.contactDelegate = self
    
        // Gets the ball from scene's child nodes, applies an impulse.
        let ball = childNodeWithName(BallCategoryName) as SKSpriteNode
        ball.physicsBody!.applyImpulse(CGVectorMake(10, -10))
        
        let paddle = childNodeWithName(PaddleCategoryName) as SKSpriteNode!
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
    
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory
        
        // Store some useful constants
        let numberOfBlocks = 5
        
        let blockWidth = SKSpriteNode(imageNamed: "block.png").size.width
        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        
        let padding: CGFloat = 10.0
        let totalPadding = padding * CGFloat(numberOfBlocks - 1)
        
        // Calculate the xOffset
        let xOffset = (CGRectGetWidth(frame) - totalBlocksWidth - totalPadding) / 2
        
        // Create the blocks and add them to the scene
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "block.png")
            block.position = CGPointMake(xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth + CGFloat(i - 1)*padding, CGRectGetHeight(frame) * 0.8)
            block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.dynamic = false
            block.name = BlockCategoryName
            block.physicsBody!.categoryBitMask = BlockCategory
            addChild(block)
        }
        
    }
    
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch!
        var touchLocation = touch.locationInNode(self)
        
        if let body = physicsWorld.bodyAtPoint(touchLocation) {
            if body.node!.name == PaddleCategoryName {
                println("Began touch on paddle")
                isFingerOnPaddle = true
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // Check whether user touched the paddle.
        if isFingerOnPaddle {
            // Get touch location.
            var touch = touches.anyObject() as UITouch!
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            
            // Get node for paddle.
            var paddle = childNodeWithName(PaddleCategoryName) as SKSpriteNode!
            
            // Calculate new position along x for paddle.
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            
            // Limit x so that paddle won't leave screen to left or right.
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            
            // Update paddle position.
            paddle.position = CGPointMake(paddleX, paddle.position.y)
        }
        
    }
    
    
    
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent){
        isFingerOnPaddle = false
    }
    
    
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Create local variables for two physics bodies.
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // Assign the two physics bodies so that the one with the lower category is always stored in firstBody.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // React to the contact between ball and bottom.
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            // TODO: Replace the log statement with display of Game Over Scene.
            if let mainView = view {
                let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as GameOverScene!
                gameOverScene.gameWon = false
                mainView.presentScene(gameOverScene)
            }
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            secondBody.node!.removeFromParent()
            if isGameWon() {
                if let mainView = view {
                    let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as GameOverScene!
                    gameOverScene.gameWon = true
                    mainView.presentScene(gameOverScene)
                }
            }
        }
    }
    
    
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodesWithName(BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        // Will return "true" if player has cleared all blocks
        return numberOfBricks == 0
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}