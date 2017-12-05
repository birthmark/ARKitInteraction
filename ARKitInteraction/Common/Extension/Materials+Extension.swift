//
//  Materials.swift
//  ARKitExample
//
//  Created by Zoë Smith on 8/21/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit


extension SCNMaterial {
    static func material(named name: String) -> SCNMaterial {
        let mat = SCNMaterial()
        
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = UIColor(red: 253/255, green: 241/255, blue: 135/255, alpha: 1)
        mat.roughness.contents = 0.8
        mat.metalness.contents = 0.2
        mat.normal.contents = UIColor.white
        
//        mat.lightingModel = .physicallyBased
//        mat.diffuse.contents = UIImage(named: "\(name)-diffuse")
//        mat.roughness.contents = UIImage(named: "\(name)-roughness")
//        mat.metalness.contents = UIImage(named: "\(name)-metalness")
//        mat.normal.contents = UIImage(named: "\(name)-normal")
        mat.diffuse.wrapS = .repeat
        mat.diffuse.wrapT = .repeat
        mat.roughness.wrapS = .repeat
        mat.roughness.wrapT = .repeat
        mat.metalness.wrapS = .repeat
        mat.metalness.wrapT = .repeat
        mat.normal.wrapS = .repeat
        mat.normal.wrapT = .repeat
        return mat
    }
}
