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
            self.nodeGestureHandler!.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare()
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
        print("node for anchor")
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let node = SCNNode()
            node.geometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.y), length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
            node.geometry?.materials.first?.lightingModel = .constant
            node.geometry?.materials.first?.diffuse.contents = UIColor.color(hexValue: 0xffffff, alpha: 0.1)
            
            if (!SHOW_DETECTED_PLANE) {
                node.geometry?.materials.first?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
            }
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("did add node for anchor")
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.statusVC.cancelScheduledMessage(for: .planeEstimation)
            self.statusVC.showMessage("SURFACE DETECTED")
            if (NodeManager.sharedInstance.arrLoadedNodes?.isEmpty)! {
                self.statusVC.scheduleMessage("NOW TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
            }
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
                object.adjustOntoPlaneAnchor(planeAnchor, using: node)
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusVC.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusVC.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusVC.cancelScheduledMessage(for: .trackingStateEscalation)
        }
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
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        statusVC.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        statusVC.showMessage("RESETTING SESSION")
        
        restartExperience()
    }
}
