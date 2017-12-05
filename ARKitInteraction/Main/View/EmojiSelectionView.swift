//
//  EmojiSelectionView.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

protocol EmojiSelectionViewDelegate: class {
    func emojiSelectionView(_ view: EmojiSelectionView, didSelectAt index: Int)
}

class EmojiSelectionView: UIView {

    var scrollView: UIScrollView?
    var bkMask: UIView?
    var btnClose: UIButton?
    var delegate: EmojiSelectionViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
//        self.backgroundColor = UIColor.color(hexValue: 0x000000, alpha: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        //
        let effectView: UIVisualEffectView = UIVisualEffectView.init(effect: UIBlurEffect(style: .dark))
        effectView.frame = self.bounds
        self.addSubview(effectView);
    
        scrollView = UIScrollView.init(frame: self.bounds)
        self.addSubview(scrollView!)
        
        bkMask = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: 60))
        bkMask?.isUserInteractionEnabled = false
        
//        let gradientLayer = CAGradientLayer.init()
//        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.width, height: 60)
//        gradientLayer.colors = [UIColor.color(hexValue: 0x000000, alpha: 0.0).cgColor,
//                                UIColor.color(hexValue: 0x000000, alpha: 0.5).cgColor]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
//        bkMask?.layer.addSublayer(gradientLayer)
        self.addSubview(bkMask!)
        
        btnClose = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
        self.addSubview(btnClose!)
        btnClose?.setImage(UIImage.init(named: "emoji_close"), for: [])
        btnClose?.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
    }
    
    func setConfigs(configs: Array<EmojiConfigVO>) {
        scrollView?.removeAllSubviews()
        
        let size: Int = 70
        let marginH = Int((SCREEN_WIDTH-CGFloat(size*2))/3)
        let marginV = 60
        
        
        for (index, item) in configs.enumerated() {
            let button: UIButton = EmojiButton.init(frame: CGRect.init(x: 0, y: 0, width: size, height: size))
            scrollView?.addSubview(button)
            button.tag = index;
            
            button.addTarget(self, action:#selector(EmojiSelectionView.clickAction(_:)), for: UIControlEvents.touchUpInside)
            
            if let icon = UIImage(named: item.icon!) {
                button.setImage(icon, for: [])
            } else {
                if let icon = UIImage(named: item.modelName) {
                    button.setImage(icon, for: [])
                } else {
                    button.setImage(UIImage(named: "emoji_3d"), for: [])
                }
            }
        
            button.top = CGFloat(marginV + index/2 * (marginV+size))
            button.left = CGFloat(marginH + index%2 * (marginH+size))
            
            scrollView?.contentSize = CGSize.init(width: (scrollView?.width)!, height: button.bottom+60)
        }
    }
    
    @objc func clickAction(_ sender: UIButton) {
        let index = sender.tag;
        delegate?.emojiSelectionView(self, didSelectAt: index)
        closeAction()
    }
    
    @objc func closeAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.top = self.height
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scrollView?.frame = self.bounds
        scrollView?.height = self.height-68
        self.bkMask?.centerX = self.width/2;
        self.bkMask?.bottom = self.height-68
        self.btnClose?.centerX = self.width/2
        self.btnClose?.centerY = (self.bkMask?.bottom)! + (self.height-(self.bkMask?.bottom)!)/2
    }
}
