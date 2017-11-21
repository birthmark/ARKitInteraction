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
//        loadEmojiFromAssets()
        loadEmojiConfigs()
    }
    
    //从文件目录Models.scnassets加载
    func loadEmojiFromAssets() {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
        
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        
        arrEmojiConfigVOs = fileEnumerator.flatMap { element in
            let url = element as! URL
            
            guard url.pathExtension == "scn" || url.pathExtension == "dae" else { return nil }
            
            let emojiVO: EmojiConfigVO = EmojiConfigVO()
            emojiVO.url = url
            return emojiVO
        }
    }
    
    //从配置文件加载
    func loadEmojiConfigs() {
        if let path = Bundle.main.path(forResource:"EmojiConfig", ofType: "json") {
            do {
                let content: NSString = try NSString.init(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                if let config = EmojiConfig.deserialize(from: content as String) {
                    arrEmojiConfigVOs = config.emojiData
                
                    //设置全路径
                    for item in arrEmojiConfigVOs! {
                        item.url = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
                        item.url?.appendPathComponent(item.urlString!)
                    }
                }
                
            } catch let err as Error!{
                print("读取本地数据出现错误！", err)
            }
        } else {
            print("读取本地数据出现错误！")
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
