//
//  EmojiManager.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/16.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import ARKit

class NodeManager: NSObject {

    static let sharedInstance = NodeManager()
    var arrEmojiConfigVOs: Array<EmojiConfigVO>?
    var arrLoadedNodes: Array<BaseNode>? = []
    var isLoading: Bool?
    
    private override init() {
        super.init()
        isLoading = false
        arrEmojiConfigVOs = loadEmojiConfigs()
    }
    
    private func loadEmojiConfigs() -> Array<EmojiConfigVO> {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
        
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        
        return fileEnumerator.flatMap { element in
            let url = element as! URL
            
            guard url.pathExtension == "scn" || url.pathExtension == "dae" else { return nil }
            
            let emojiVO: EmojiConfigVO = EmojiConfigVO()
            emojiVO.url = url
            return emojiVO
        }
    }
    
    func addNode(node: BaseNode) {
        arrLoadedNodes?.append(node)
    }
    
    func removeAllNodes() {
        for node in arrLoadedNodes! {
            node.removeFromParentNode()
        }
        
        arrLoadedNodes?.removeAll()
    }
    
    func removeNode(node: BaseNode) {
        let index = arrLoadedNodes?.index(of: node)
        guard (arrLoadedNodes?.indices.contains(index!))! else { return }
        arrLoadedNodes?.remove(at: index!)
        node.removeFromParentNode()
    }
    
    // 加载模型
    func loadNode(_ object: EmojiConfigVO, loadedHandler: @escaping (BaseNode) -> Void) {
        let node: EmojiNode = EmojiNode()
        node.referenceURL = object.url!
        arrLoadedNodes?.append(node)
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            node.reset()
            node.load()
            self.isLoading = false
            loadedHandler(node)
        }
    }
}
