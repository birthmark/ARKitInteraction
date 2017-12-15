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

let iPhoneX = SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 812
let iPhoneX_Navbar_Height = CGFloat(44)
let iPhoneX_Toolbar_Height = CGFloat(34)
let iPhoneX_E = CGFloat(67)
let iPhoneX_T_Margin = CGFloat(iPhoneX ? 44+iPhoneX_E/2+30 : 30)
let iPhoneX_B_Margin = CGFloat(iPhoneX ? 34+iPhoneX_E/2+30 : 30)
let iPhoneX_T = CGFloat(iPhoneX ? 44 : 20)
let iPhoneX_B = CGFloat(iPhoneX ? 34 : 0)

let MAX_DISTANCE = Float(10.0)
let TARGET_DISTANCE = Float(0.5)//放在0.5米处

let FONT_SIZE = CGFloat(0.5)
let FONT_THICKNESS_SCALE = CGFloat(0.24)
let FONT_METERIAL_NAME = "text-texture"//rustediron-streaks

//平行光角度，默认是射向Z轴负方向
let LIGTH_ROTATE_X = -Float(Double.pi/2-0.12)
let LIGTH_ROTATE_Y = Float(0.0)//-Float(Double.pi/4)

//let LIGTH_ROTATE_X = -Float(Double.pi/3)
//let LIGTH_ROTATE_Y = -Float(Double.pi/4)

//拖动的时候是否自动落到平面上，此处最好为true
let PLACE_NODE_ON_EXISTING_PLANE = false

//显示投影平面
let SHOW_SHADOW_PLANE = false
let PLANE_SCALE = Float(100)

let maxBoxSize = Float(10.0)//最大长边10m
let minBoxSize = Float(0.05)//最小短边5cm

let showFocusSquare = false

#if DEBUG
#else
#endif
