//
//  CGPath&UIBazierPath.swift
//  PenguinSlicer
//
//  Created by Alisher Abdukarimov on 6/30/17.
//  Copyright © 2017 MrAliGorithm. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

extension GameScene {
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "enemy" {
                //1 Create a particle effect over the penguin
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                emitter.position = node.position
                addChild(emitter)
                
                //2 Clear its node name so that it can't be swiped repeatedly
                node.name = ""
                
                //3 Disable the isDynamic of its physics body so that it does not carry on falling
                node.physicsBody!.isDynamic = false
                
                //4 Make the penguin scale out and fade out at the same time
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                //5 After making the penguin scale out and fade out, we should remove it from the scene
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(seq)
                
                //6 Add one to the players score
                score += 1
                
                //7 Remove the enemy from the active enemies array
                let index = activeEnemies.index(of: node as! SKSpriteNode)!
                activeEnemies.remove(at: index)
                
                //8 Play a sound so the player knows they hit the penguin
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }else if node.name == "bomb" {
                
                // 1
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.parent!.position
                addChild(emitter)
                
                node.name = ""
                node.parent!.physicsBody!.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                node.parent!.run(seq)
                
                let index = activeEnemies.index(of: node.parent as! SKSpriteNode)!
                activeEnemies.remove(at: index)
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func redrawActiveSlice() {
        //1 If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method.
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        //2 If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long.
        while activeSlicePoints.count > 12 {
            activeSlicePoints.remove(at: 0)
        }
        
        // 3 It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point.
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        //4 Finally, it needs to update the slice shape paths so they get drawn using their designs – i.e., line width and color.
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func endGame(triggeredByBomb: Bool) {
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        if triggeredByBomb {
            livesImage[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImage[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImage[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
    
}
