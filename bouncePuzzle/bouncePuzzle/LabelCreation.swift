//
//  LabelCreation.swift
//  bouncePuzzle
//
//  Created by student on 11/15/16.
//  Copyright © 2016 student. All rights reserved.
//

import Foundation
import SpriteKit

// JHAT: Make label creation much easier
func createMontserratLabel(pos: CGPoint, fontSize: CGFloat, text: String, name: String) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: "Montserrat-Bold") // TODO: Change pixeled to new font
    label.position = pos
    label.fontSize = fontSize
    label.text = text
    label.name = name
    label.fontColor = SKColor.white
    label.zPosition = 5
    return label
}

func createCustomLabel(fontString: String, pos: CGPoint, fontSize: CGFloat, text: String, name: String, color: SKColor) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: fontString)
    label.position = pos
    label.fontSize = fontSize
    label.text = text
    label.name = name
    label.zPosition = 5
    label.fontColor = color
    return label
}

func updateLabelProperties(labelToModify: SKLabelNode, pos: CGPoint, vAl: SKLabelVerticalAlignmentMode, hAl: SKLabelHorizontalAlignmentMode, text: String, fontSize: CGFloat, name: String) -> SKLabelNode {
    labelToModify.name = name
    labelToModify.position = pos
    labelToModify.verticalAlignmentMode = vAl
    labelToModify.horizontalAlignmentMode = hAl
    labelToModify.text = text
    labelToModify.fontSize = fontSize
    labelToModify.color = SKColor.white
    labelToModify.zPosition = 5
    if (labelToModify.fontName != "Montserrat-Bold") {
        labelToModify.fontName = "Montserrat-Bold"
    }
    return labelToModify
}
