//
//  InputPanelView.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class InputPanelView: UIView {

    var btnConfirm: UIButton?
    var textView: UITextView?
    
    var inputFinishHandler: (_ text: String?) -> Void = {_ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.color(hexValue: 0xf0f0f0)
        setupViews()
        setupListeners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        textView = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(textView!)
        self.textView?.font = UIFont.systemFont(ofSize: 18)
        self.textView?.textColor = UIColor.color(hexValue: 0x4e4e4e)
        
        btnConfirm = UIButton.init(frame: CGRect.init())
        self.addSubview(btnConfirm!)
        btnConfirm?.setImage(UIImage.init(named: "yes"), for: [])
        btnConfirm?.backgroundColor = UIColor.color(hexValue: 0xfcf186)
    }
    
    func setupListeners() {
        self.btnConfirm?.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    @objc func confirmAction() {
        
        if self.textView?.text?.lengthOfBytes(using: .utf8) != 0 {
            inputFinishHandler(self.textView?.text)
            self.textView?.text = ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.btnConfirm?.frame = CGRect.init(x: self.width-45, y: 0, width: 45, height: self.height)
        self.textView?.frame = CGRect.init(x: 0, y: 0, width: self.width-45, height: self.height)
    }
}
