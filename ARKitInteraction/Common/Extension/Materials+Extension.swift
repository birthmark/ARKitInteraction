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
        mat.diffuse.contents = UIImage(named: "\(name)-albedo")
        mat.roughness.contents = UIImage(named: "\(name)-roughness")
        mat.metalness.contents = UIImage(named: "\(name)-metal")
        mat.normal.contents = UIImage(named: "\(name)-normal")
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
