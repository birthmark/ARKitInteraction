/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARSCNViewDelegate interactions for `ViewController`.
*/

import ARKit

extension SceneVC: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.planeDetected()
            self.nodeGestureHandler!.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare()
            self.updateDeleteButton()
            self.autoFocus()
        }
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        let baseIntensity: CGFloat = 40
        let lightingEnvironment = sceneView.scene.lightingEnvironment
        if let lightEstimate = session.currentFrame?.lightEstimate {
            lightingEnvironment.intensity = lightEstimate.ambientIntensity / baseIntensity
        } else {
            lightingEnvironment.intensity = baseIntensity
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            print("planeAnchor detected x: \(planeAnchor.center.x) y: \(planeAnchor.center.y) z: \(planeAnchor.center.z)")
            let node = SCNNode()
            
            node.geometry = SCNBox(width: CGFloat(planeAnchor.extent.x*1), height: CGFloat(planeAnchor.extent.y), length: CGFloat(planeAnchor.extent.z*1), chamferRadius: 0)
            node.geometry?.materials.first?.lightingModel = .lambert
            node.geometry?.materials.first?.diffuse.contents = UIColor.color(hexValue: 0xffffff, alpha: 0.0)
            node.geometry?.materials.first?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
            
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print("did add plane")
        DispatchQueue.main.async {
            
//            self.msgView.setMessag(message: "SURFACE DETECTED")
//            if (NodeManager.sharedInstance.arrLoadedNodes?.isEmpty)! {
//                self.msgView.setMessag(message: "NOW TO PLACE AN OBJECT")
//            }
//            self.msgView.hideStickingMessage()
        }
        updateQueue.async {
            for object in NodeManager.sharedInstance.arrLoadedNodes! {
                object.adjustOntoPlaneAnchor(planeAnchor, using: node)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            for object in NodeManager.sharedInstance.arrLoadedNodes! {
//                object.adjustOntoPlaneAnchor(planeAnchor, using: node)//不更新 防抖动?
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.flatMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
//            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
            self.isPlaneDetected = false
            self.msgView.setMessage(message: "黑科技初始化失败，点上方重置按钮也许有用")
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
//        self.msgView.setMessag(message: "SESSION INTERRUPTED")
        self.isPlaneDetected = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
//        self.msgView.setMessag(message: "RESETTING SESSION")
        
        resetScene()
    }
}
