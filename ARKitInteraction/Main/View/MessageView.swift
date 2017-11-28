//
//  MessageView.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/28.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class MessageView: UIView {

    let messageDuration = 3.0
    var label: UILabel?
    var timeInterval: Int?
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color(hexValue: 0xfdf187)
        self.setCorner(cornerRadius: self.height/2)
        
        label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(label!)
        label?.font = UIFont.appNormalFont(fontSize: 12)
        label?.textColor = UIColor.color(hexValue: 0x767676)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessag(message: String) -> Void {
        
        if (timer != nil) {
            timer?.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: messageDuration, repeats: false, block: { [weak self] _ in
            print("Timer affire")
            UIView.animate(withDuration: 0.3, animations: {
                self?.alpha = 0.0
            })
        })
    
        
        label?.text = message;
        label?.sizeToFit()
        
        layoutSubview()
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    func layoutSubview() {
        self.width = (label?.width)!+32
        label?.centerX = self.width/2
        label?.centerY = self.height/2
        
        if self.superview != nil {
            self.centerX = (self.superview?.width)!/2
        }
    }
}
