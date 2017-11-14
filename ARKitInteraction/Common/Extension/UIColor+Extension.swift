//
//  UIColor+Extension.swift
//  FlyReader
//
//  Created by 梁凤英 on 2017/5/6.
//  Copyright © 2017年 ying.com. All rights reserved.
//

import Foundation
import UIKit
public extension UIColor{
    class func color(hexValue hex:NSInteger)->UIColor{
        
        return UIColor.color(hexValue: hex, alpha: 1.0);
    
    }
    class func color(hexValue hex:NSInteger,alpha:CGFloat)->UIColor{
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((hex & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: alpha)
    }
    
    func reverseColor()->UIColor{
        var R:CGFloat = 0.0,G:CGFloat = 0.0,B:CGFloat = 0.0,A:CGFloat = 0.0;
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        return UIColor.init(red: 1.0-R, green: 1.0-G, blue: 1.0-B, alpha: A)
    }
    
    class func randomColor()->UIColor{
        let red = CGFloat(arc4random_uniform(255))/CGFloat(255.0)
        let green = CGFloat(arc4random_uniform(255))/CGFloat(255.0)
        let blue = CGFloat(arc4random_uniform(255))/CGFloat(255.0)
        let randomColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
        return randomColor;
    }

}
