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

        let font = UIFont.systemFont(ofSize: size);
        return font;
    }
    
    class func appNormalFont(fontSize size:CGFloat)->UIFont{
        
        let font = UIFont.systemFont(ofSize: size);
        return font;
    }
    
    class func appBoldFont(fontSize size:CGFloat)->UIFont{
        
        let font = UIFont.boldSystemFont(ofSize: size)
        return font;
    }
    
    class func appLanTingFont(fontSize size:CGFloat)->UIFont{
        
//        var font = UIFont(name:"FZLTDHK--GBK1-0",size:size);//Lanting_GBK.ttf
        var font = UIFont(name:"FZLTCHJW--GB1-0",size:size);//Lanting_GBK_II.ttf
        if font == nil {
            font = UIFont.systemFont(ofSize: size);
        }
        return font!;
    }
}
