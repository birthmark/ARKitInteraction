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
    
    func emojiSelectionVC(_: EmojiSelectionVC, didSelectObject object: BaseNode) {
        emojiLoader.loadEmojiObject(object, loadedHandler: { [unowned self] loadedObject in
            DispatchQueue.main.async {
                self.hideObjectLoadingUI()
                self.placeVirtualObject(loadedObject)
            }
        })

        displayObjectLoadingUI()
    }
    
    func emojiSelectionVC(_: EmojiSelectionVC, didDeselectObject object: BaseNode) {
        guard let objectIndex = emojiLoader.loadedObjects.index(of: object) else {
            fatalError("Programmer error: Failed to lookup virtual object in scene.")
        }
        emojiLoader.removeVirtualObject(at: objectIndex)
    }

    // MARK: Object Loading UI

    func displayObjectLoadingUI() {
//        btnAddEmoji.setImage(#imageLiteral(resourceName: "buttonring"), for: [])

        btnAddEmoji.isHidden = true
        btnVideoCapture.isHidden = true
        btn3DText.isHidden = true
        
        btnAddEmoji.isEnabled = false
        isRestartAvailable = false
    }

    func hideObjectLoadingUI() {
//        btnAddEmoji.setImage(#imageLiteral(resourceName: "add"), for: [])
//        btnAddEmoji.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])

        btnAddEmoji.isHidden = false
        btnVideoCapture.isHidden = false
        btn3DText.isHidden = false
        
        btnAddEmoji.isEnabled = true
        isRestartAvailable = true
    }
}
