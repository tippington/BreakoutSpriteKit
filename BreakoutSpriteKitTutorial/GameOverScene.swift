//
//  GameOverScene.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Clinton VanSciver on 1/5/15.
//  Copyright (c) 2015 Clinton VanSciver. All rights reserved.
//

import SpriteKit

let GameOverLabelCategoryName = "gameOverLabel"

class GameOverScene: SKScene {
    var gameWon : Bool = false {
        // didSet observer is a Swift particularity called Property Observer. Using that can
        // observe changes in the value of a property and react accordingly. "willSet" is the
        // equivalent but is called just before a property change occurs, while "didSet" is
        // called just after.
        didSet {
            let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as SKLabelNode!
            gameOverLabel.text = gameWon ? "Game Won" : "Game Over"
        }
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let view = view {
            // When user taps anwhere in the GameOver scene, this sends them back to the
            // GameScene. Re-instantiates the GameScene by unarchiving it.
            let gameScene = GameScene.unarchiveFromFile("GameScene") as GameScene!
            view.presentScene(gameScene)
        }
    }
}