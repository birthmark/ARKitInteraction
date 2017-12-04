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
    
    var isAnimating: Bool = false
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
            let textNode = SCNText.init(string: text, extrusionDepth: FONT_SIZE*FONT_THICKNESS_SCALE)
            textNode.firstMaterial?.diffuse.contents = UIColor.blue
            textNode.flatness = 0.0001
            textNode.font = UIFont.appLanTingFont(fontSize: FONT_SIZE)
            let material = SCNMaterial.material(named: FONT_METERIAL_NAME)
            textNode.materials = [material]
            self.geometry = textNode
            self.eulerAngles.y = 0
        }
        
        updatePivot()
    }
    
    override func updatePivot() {
        let (min, max) = boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y
        let dz = min.z + 0.5 * (max.z - min.z)
        pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
    
    override func pivotHeight() -> Float {
        return 0;
    }
}
