//
//  CaptureButton.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

import Foundation
import UIKit

class CaptureButton: UIButton {
    
    var yellowView: UIView?
    var progress: Double!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.progress = 0.0
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        yellowView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        self.addSubview(yellowView!)
        yellowView?.isUserInteractionEnabled = false
        yellowView?.backgroundColor = UIColor.color(hexValue: 0xfdf187)
        yellowView?.layer.cornerRadius = (yellowView?.width)!/2
        yellowView?.layer.masksToBounds = true
        yellowView?.layer.borderWidth = 2
        yellowView?.layer.borderColor = UIColor.white.cgColor
        yellowView?.centerX = self.width/2
        yellowView?.centerY = self.height/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        yellowView?.centerX = self.width/2
        yellowView?.centerY = self.height/2
    }
    
    func resizeYellowCircle() {
        yellowView?.size = CGSize.init(width: 50, height: 50)
        yellowView?.layer.cornerRadius = (yellowView?.width)!/2
        yellowView?.centerX = self.width/2
        yellowView?.centerY = self.height/2
    }
    
    func resetYellowCircle() {
        yellowView?.size = CGSize.init(width: 60, height: 60)
        yellowView?.layer.cornerRadius = (yellowView?.width)!/2
        yellowView?.centerX = self.width/2
        yellowView?.centerY = self.height/2
    }
    
    func setProgress(progress: Double) {
        self.progress = progress
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath: UIBezierPath = UIBezierPath.init(roundedRect: CGRect.init(x: 2, y: 2, width: self.width-4, height: self.height-4), cornerRadius: (self.width-4)/2)
        UIColor.color(hexValue: 0xffffff, alpha: 0.4).setFill()
        circlePath.fill()
        
        let path: UIBezierPath = UIBezierPath.init(arcCenter: CGPoint(x:self.width/2,y:self.height/2), radius: self.width/2-2.5, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(self.progress*Double.pi*2-Double.pi/2), clockwise: true)
        UIColor.color(hexValue: 0xfdf187).setStroke()
        path.lineCapStyle = .round
        path.lineWidth = 4
        path.stroke()
    }
}
