//
//  scene.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024
//

import Foundation
import SpriteKit

class scene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        let sprite = SKSpriteNode(color: SKColor.red, size: CGSize(width: 100, height: 100))
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(sprite)
    }
}

