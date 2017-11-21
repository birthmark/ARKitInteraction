//
//  EmojiVO.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/16.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import HandyJSON

class EmojiConfigVO: HandyJSON {

    var urlString: String?
    var url: URL?
    var icon: String?
    
    required init() {
    }
    
    /// The model name derived from the `referenceURL`.
    var modelName: String {
        var name = url?.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
        name = name?.replacingOccurrences(of: ".dae", with: "")
        return name!
    }
}
