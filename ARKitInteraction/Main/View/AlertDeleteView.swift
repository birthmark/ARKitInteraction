//
//  AlertDeleteView.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/29.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class AlertDeleteView: UIView {
    
    var contentView: UIView?
    var title: UILabel?
    var desc: UILabel?
    var btnCancel: UIButton?
    var btnConfirm: UIButton?
    
    var handler: ()-> Void = {}
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color(hexValue: 0x000000, alpha: 0.5)
        setupViews()
        setupListeners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: 90+iPhoneX_T))
        self.addSubview(self.contentView!)
        self.contentView?.backgroundColor = UIColor.color(hexValue: 0xf64b4b)
        
        self.title = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.contentView?.addSubview(self.title!)
        self.title?.text = "重置场景吗"
        self.title?.textColor = UIColor.white
        self.title?.font = UIFont.appBoldFont(fontSize: 16)
        self.title?.sizeToFit()
        self.title?.centerX = (self.contentView?.width)!/2
        self.title?.top = iPhoneX ? 34 : 15
        
        self.desc = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.contentView?.addSubview(self.desc!)
        self.desc?.text = "将去除所有物体"
        self.desc?.textColor = UIColor.white
        self.desc?.font = UIFont.appNormalFont(fontSize: 12)
        self.desc?.sizeToFit()
        self.desc?.centerX = (self.contentView?.width)!/2
        self.desc?.top = (self.title?.bottom)!+3
        
        self.btnCancel = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: 30))
        self.contentView?.addSubview(self.btnCancel!)
        self.btnCancel?.setTitle("取消", for: [])
        self.btnCancel?.titleLabel?.font = UIFont.appNormalFont(fontSize: 14)
        self.btnCancel?.setTitleColor(UIColor.white, for: [])
        self.btnCancel?.left = 10
        self.btnCancel?.bottom = (self.contentView?.height)!-5
        
        self.btnConfirm = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: 30))
        self.contentView?.addSubview(self.btnConfirm!)
        self.btnConfirm?.setTitle("重置", for: [])
        self.btnConfirm?.titleLabel?.font = UIFont.appNormalFont(fontSize: 14)
        self.btnConfirm?.setTitleColor(UIColor.white, for: [])
        self.btnConfirm?.right = (self.contentView?.width)! - 10
        self.btnConfirm?.bottom = (self.btnCancel?.bottom)!
    }
    
    func showAnimation() {
        self.contentView?.top = -(self.contentView?.height)!
        UIView.animate(withDuration: 0.3) {
            self.contentView?.top = 0
        }
    }
    
    private func setupListeners() {
        self.btnCancel?.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        self.btnConfirm?.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }
    
    @objc func cancelAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView?.top = -(self.contentView?.height)!
        }) { (flag) in
            self.removeFromSuperview()
        }
    }
    
    @objc func confirmAction() {
        self.handler()
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView?.top = -(self.contentView?.height)!
        }) { (flag) in
            self.removeFromSuperview()
        }
    }
}
