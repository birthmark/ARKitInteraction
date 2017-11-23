//
//  EmojiButton.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class EmojiButton: UIButton {

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return self.bounds
    }

}
