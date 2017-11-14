//
//  BaseVC.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
