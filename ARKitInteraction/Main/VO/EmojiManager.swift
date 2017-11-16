//
//  EmojiManager.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/16.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import ARKit

class EmojiManager: NSObject {

    static let sharedInstance = EmojiManager()
    var arrEmojiVOs: Array<EmojiVO>?
    var arrLoadedNode: Array<BaseNode>? = []
    var isLoading: Bool?
    
    private override init() {
        super.init()
        isLoading = false
        arrEmojiVOs = loadEmojis()
    }
    
    private func loadEmojis() -> Array<EmojiVO> {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
        
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        
        return fileEnumerator.flatMap { element in
            let url = element as! URL
            
            guard url.pathExtension == "scn" || url.pathExtension == "dae" else { return nil }
            
            let emojiVO: EmojiVO = EmojiVO()
            emojiVO.url = url
            return emojiVO
        }
    }
    
    public func addNode(node: BaseNode) {
        arrLoadedNode?.append(node)
    }
    
    public func removeAllNodes() {
        for node in arrLoadedNode! {
            node.removeFromParentNode()
        }
        
        arrLoadedNode?.removeAll()
    }
    
    public func removeNode(node: BaseNode) {
        let index = arrLoadedNode?.index(of: node)
        guard (arrLoadedNode?.indices.contains(index!))! else { return }
        arrLoadedNode?.remove(at: index!)
        node.removeFromParentNode()
    }
    
    func loadEmojiObject(_ object: EmojiVO, loadedHandler: @escaping (BaseNode) -> Void) {
        let node: EmojiNode = EmojiNode()
        node.referenceURL = object.url!
        arrLoadedNode?.append(node)
        isLoading = true
        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            node.reset()
            node.load()
            self.isLoading = false
            loadedHandler(node)
        }
    }
}
