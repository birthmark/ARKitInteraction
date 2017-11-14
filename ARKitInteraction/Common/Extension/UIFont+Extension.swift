//
//  UIFont+UserFont.swift
//  FlyReader
//
//  Created by 梁凤英 on 2017/5/6.
//  Copyright © 2017年 ying.com. All rights reserved.
//

import Foundation
import UIKit
public extension UIFont{
    
    class func appLightFont(fontSize size:CGFloat)->UIFont{

        var font = UIFont(name:"PingFangSC-Light",size:size);
        if font == nil {
            font = UIFont.systemFont(ofSize: size);
        }
        return font!;
    }
    
    class func appNormalFont(fontSize size:CGFloat)->UIFont{
        
        var font = UIFont(name:"PingFangSC-Regular",size:size);
        if font == nil {
            font = UIFont.systemFont(ofSize: size);
        }
        return font!;
    }
    
    class func appBoldFont(fontSize size:CGFloat)->UIFont{
        
        var font = UIFont(name:"PingFangSC-Medium",size:size);
        if font == nil {
            font = UIFont.boldSystemFont(ofSize: size)
        }
        return font!;
    }
    
    class func appSanNormalFont(fontSize size:CGFloat)->UIFont{
        
        var font = UIFont(name:".HelveticaNeueDeskInterface-Regular",size:size);
        if font == nil {
            font = UIFont.systemFont(ofSize: size);
        }
        return font!;
    }
    
    class func appSanMediumFont(fontSize size:CGFloat)->UIFont{
        
        var font = UIFont(name:".HelveticaNeueDeskInterface-Regular",size:size);
        if font == nil {
            font = UIFont.boldSystemFont(ofSize: size);
        }
        return font!;
    }
    
    
}
