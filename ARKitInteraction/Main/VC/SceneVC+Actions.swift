/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension SceneVC: UIGestureRecognizerDelegate {
    
    /// Determines if the tap gesture for presenting the `VirtualObjectSelectionViewController` should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return EmojiManager.sharedInstance.arrLoadedNode!.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !EmojiManager.sharedInstance.isLoading! else { return }
        isRestartAvailable = false

        statusVC.cancelAllScheduledMessages()

        EmojiManager.sharedInstance.removeAllNodes()
//        btnAddEmoji.setImage(#imageLiteral(resourceName: "add"), for: [])
//        btnAddEmoji.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])

        resetTracking()

        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
}
