/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for handling virtual object loading and movement
*/

import UIKit
import SceneKit

extension SceneVC: EmojiSelectionDelegate {
    /**
     Adds the specified virtual object to the scene, placed using
     the focus square's estimate of the world-space position
     currently corresponding to the center of the screen.
     
     - Tag: PlaceVirtualObject
     */
    func placeVirtualObject(_ virtualObject: BaseNode) {
        guard let cameraTransform = session.currentFrame?.camera.transform,
            let focusSquarePosition = focusSquare.lastPosition else {
            statusVC.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
            return
        }
        
        nodeGestureHandler.selectedNode = virtualObject
        virtualObject.setPosition(focusSquarePosition, relativeTo: cameraTransform, smoothMovement: false)
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(virtualObject)
        }
    }
    
    // MARK: - VirtualObjectSelectionViewControllerDelegate
    
    func emojiSelectionVC(_: EmojiSelectionVC, didSelectObject object: EmojiVO) {
        EmojiManager.sharedInstance.loadEmojiObject(object, loadedHandler: { [unowned self] loadedObject in
            DispatchQueue.main.async {
                self.placeVirtualObject(loadedObject)
            }
        })
    }
}
