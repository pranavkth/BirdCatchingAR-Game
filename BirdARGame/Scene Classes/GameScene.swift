//
//  GameScene.swift
//  LyndaARGame
//
//  Created by Brian Advent on 22.05.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

// SIMD framework is singleinstruction multipledata framework and is optimised to work with matrices.

class GameScene: SKScene {
    
    var numberOfBirds = 10
    var timerLabel    : SKLabelNode!
    var counterLabel  : SKLabelNode!
    
    var remainingTime : Int = 30 {
        didSet{
            timerLabel.text = "\(remainingTime) sec"
        }
    }
    
    var score : Int = 0 {
        didSet {
            counterLabel.text = "\(score) Birds"
        }
    }
    
    static var gameState : GameState = .none
    
    func setUpHUD(){
        timerLabel = self.childNode(withName: "timerLabel") as! SKLabelNode
        counterLabel = self.childNode(withName: "counterLabel") as! SKLabelNode
        timerLabel.position = CGPoint(x: (self.size.width / 2) - 70, y: (self.size.height / 2) - 90)
        counterLabel.position = CGPoint(x: -(self.size.width / 2) + 70, y: (self.size.height / 2) - 90)
        let waitAction = SKAction.wait(forDuration: 1)
        let action = SKAction.run {
            self.remainingTime -= 1
        }
        let timerAction = SKAction.sequence([waitAction,action])
        self.run(SKAction.repeatForever(timerAction))
    }
    
    func gameOver() {
        let revealTransition = SKTransition.crossFade(withDuration: 0.9)
        guard let sceneView = self.view as? ARSKView else { return }
        guard let mainMenu = MainMenuScene(fileNamed: "MainMenuScene") else { return }
        sceneView.presentScene(mainMenu,transition:revealTransition)
    }
    
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self, selector: #selector(spawnBird), name: Notification.Name("add"), object: nil)
        self.setUpHUD()
        let waitAction = SKAction.wait(forDuration: 0.5)
        let spawnAction = SKAction.run {
            self.performInitialSpawn()
        }
        self.run(SKAction.sequence([waitAction,spawnAction]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if remainingTime == 0 {
            self.removeAllActions()
            gameOver()
        }
        guard let sceneView = self.view as? ARSKView else { return }
        // get camera z position
        if let cameraZ = sceneView.session.currentFrame?.camera.transform.columns.3.z {
            for node in nodes(at: CGPoint.zero){
                guard let bird = node as? Bird else { continue }
                guard let anchors = sceneView.session.currentFrame?.anchors else { continue }
                for anchor in anchors {
                    // calc the difference between camera z position and the anchors z position.
                    if abs(cameraZ - anchor.transform.columns.3.z) < 0.2 {
                        guard let potentialTargetBird = sceneView.node(for: anchor) else { continue }
                        if bird == potentialTargetBird {
                            print("birdremoved")
                            bird.removeFromParent()
                            spawnBird()
                            score += 1
                        }
                    }
                }
            }
        }
    }
    
    func performInitialSpawn(){
        GameScene.gameState = .spwanBirds
        for _ in 1...numberOfBirds {
            spawnBird()
        }
    }
    
    @objc func spawnBird(){
        guard let sceneView = self.view as? ARSKView else { return }
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.x = randomPosition(lowerBound: -1.5, upperBound: 1.5)
            translation.columns.3.y = randomPosition(lowerBound: -1.5, upperBound: 1.5)
            translation.columns.3.z = randomPosition(lowerBound: -2, upperBound: 2)
            let transform = simd_mul(currentFrame.camera.transform, translation)
            // TO create an anchor we need a transform object.
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}


