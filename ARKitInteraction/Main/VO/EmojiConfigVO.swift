//
//  EmojiVO.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/16.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class EmojiConfigVO: NSObject {

    var url: URL?
    
    /// The model name derived from the `referenceURL`.
    var modelName: String {
        var name = url?.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
        name = name?.replacingOccurrences(of: ".dae", with: "")
        return name!
    }
}
