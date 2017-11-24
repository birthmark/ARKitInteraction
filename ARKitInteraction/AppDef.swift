//
//  AppDef.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

import Foundation
import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let MAX_DISTANCE = Float(10.0)
let TARGET_DISTANCE = Float(0.5)//0.5 这个不大合理，为什么要放在0.5米处而不是放在平面上？

let FONT_SIZE = CGFloat(0.5)
let FONT_THICKNESS = CGFloat(0.12)
let FONT_METERIAL_NAME = "rustediron-streaks"

//平行光角度，默认是射向Z轴负方向
let LIGTH_ROTATE_X = -Float(Double.pi/3)
let LIGTH_ROTATE_Y = -Float(Double.pi/4)

//拖动的时候是否自动落到平面上，此处最好为true
let PLACE_NODE_ON_EXISTING_PLANE = false

//显示投影平面
let SHOW_SHADOW_PLANE = false
let PLANE_SCALE = Float(100)

#if DEBUG
#else
#endif
