//
//  Text3DNode.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import ARKit

class Text3DNode: BaseNode {
    
    var text: String?
    override var modelName: String {
        return "3D文字";
    }

    override func load() {
        
    }
    
    func setText(text: String) {
        if let textNode: SCNText = self.geometry as? SCNText {
            textNode.string = text;
        } else {
            let textNode = SCNText.init(string: text, extrusionDepth: 0.2)
            textNode.firstMaterial?.diffuse.contents = UIColor.blue
            textNode.font = UIFont.appNormalFont(fontSize: 0.5)
            let material = SCNMaterial.material(named: "rustediron-streaks")
            textNode.materials = [material]
            self.geometry = textNode
        }
        
        updatePivot()
    }
    
}
