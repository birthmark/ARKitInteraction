/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Coordinates movement and gesture interactions with nodes.
*/

import UIKit
import ARKit

/// - Tag: NodeGestureHandler
class NodeGestureHandler: NSObject, UIGestureRecognizerDelegate {
    
    /// Developer setting to translate assuming the detected plane extends infinitely.
    let translateAssumingInfinitePlane = true
    /// The scene view to hit test against when moving virtual content.
    let sceneView: ARView
    weak var sceneVC: SceneVC?
    
    var inputBeginHandler: (_ text: String) -> Void = {_ in}
    var longPressHandler: (_ node: BaseNode, _ point: CGPoint) -> Void = {_,_  in }
    
    /**
     The object that has been most recently intereacted with.
     The `selectedObject` can be moved at any time with the tap gesture.
     */
    var selectedNode: BaseNode?
    var currentScale: SCNVector3?
    
    /// The object that is tracked for use by the pan and rotation gestures.
    private var trackedObject: BaseNode? {
        didSet {
            guard trackedObject != nil else { return }
            selectedNode = trackedObject
        }
    }
    
    /// The tracked screen position used to update the `trackedObject`'s position in `updateObjectToCurrentTrackingPosition()`.
    private var currentTrackingPosition: CGPoint?

    init(sceneView: ARView) {
        self.sceneView = sceneView
        super.init()
        
        let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotationGesture.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
//        longPressGesture.minimumPressDuration = 1.5;
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(didPinch(_:)))
        
        // Add gestures to the `sceneView`.
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(rotationGesture)
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(doubleTapGesture)
        sceneView.addGestureRecognizer(longPressGesture)
        sceneView.addGestureRecognizer(pinchGesture)
        
        tapGesture.require(toFail: doubleTapGesture)
    }

    func setText(text: String) {
        if let node: Text3DNode = selectedNode as? Text3DNode {
            node.setText(text: text)
        }
    }
    // MARK: - Gesture Actions
    @objc
    func didPinch(_ gesture: UIPinchGestureRecognizer) {
        sceneVC?.endEditing()
//        print("pinch: \(gesture.scale)")
        
        switch gesture.state {
        case .began:
            // Check for interaction with a new object.
            if let object = objectInteracting(with: gesture, in: sceneView) {
                sceneVC?.anyAction()
                trackedObject = object
                currentScale = trackedObject?.scale
            }
            
        case .changed:
            guard trackedObject != nil else { return }
            let (min, max) = (trackedObject?.boundingBox)!
            var minDistance = Float.minimum(Float.minimum(max.x-min.x, max.y-min.y), max.z-min.z)//最小边
            let maxDistance = Float.maximum(Float.maximum(max.x-min.x, max.y-min.y), max.z-min.z)//最大边
        
            if let _: Text3DNode = trackedObject as? Text3DNode   {//文字用高度判定
                minDistance = max.y - min.y
            }
            let minScale = minBoxSize / minDistance
            let maxScale = maxBoxSize / maxDistance
            
            var scale = gesture.scale
            
            if (scale * CGFloat((currentScale?.x)!) < CGFloat(minScale)) {
                scale = CGFloat(minScale) / CGFloat((currentScale?.x)!)
            }
            
            if (scale * CGFloat((currentScale?.x)!) > CGFloat(maxScale)) {
                scale = CGFloat(maxScale) / CGFloat((currentScale?.x)!)
            }
            trackedObject?.scale = SCNVector3Make(Float(scale*CGFloat((currentScale?.x)!)), Float(scale*CGFloat((currentScale?.y)!)), Float(scale*CGFloat((currentScale?.z)!)))
//            let matrix: SCNMatrix4 = SCNMatrix4MakeScale(Float(scale), Float(scale), Float(scale))
//            trackedObject?.transform = trackedObject?.transform * matrix
            
        default:
            // Clear the current position tracking.
            currentTrackingPosition = nil
            trackedObject = nil
        }
    }
    
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
        sceneVC?.endEditing()
        
        let touchLocation = gesture.location(in: sceneView)
        
        if let tappedObject = sceneView.selectNode(at: touchLocation) {
            // Select a new object.
            sceneVC?.anyAction()
            selectedNode = tappedObject
            if let textNode = selectedNode as? Text3DNode {
                if textNode.isAnimating {
                    return
                }
                
                print("tap text3DNode to fall down")
                var angle = CGFloat(Double.pi/2)
                if (selectedNode?.isStanding)! {
//                    selectedNode?.eulerAngles.x += Float(Double.pi/2)
                } else {
//                    selectedNode?.eulerAngles.x -= Float(Double.pi/2)
                    angle *= -1
                }
                
                textNode.isAnimating = true
                let action: SCNAction = .rotateBy(x: angle, y: 0, z: 0, duration: 1.0)
                action.timingFunction = timingFunc
                selectedNode?.runAction(action, forKey: "rotate")
                selectedNode?.isStanding = !(selectedNode?.isStanding)!
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: {
                    textNode.isAnimating = false
                })
                
            } else {
                print("tap emojiNode do nothing")
            }
            
        } else if let object = selectedNode {//ignore
            // Teleport the object to whereever the user touched the screen.
            //            translate(object, basedOn: touchLocation, infinitePlane: false)
        }
    }
    
    func timingFunc(time: Float) -> Float {
        return time*time*time
    }
    
    @objc
    func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        sceneVC?.hideDeleteButton()
        let touchLocation = gesture.location(in: sceneView)
        
        if let tappedObject = sceneView.selectNode(at: touchLocation) {
            sceneVC?.anyAction()
            selectedNode = tappedObject
            if selectedNode as? Text3DNode != nil {
                print("double tap text3DNode to change text")
                let text: SCNText = selectedNode?.geometry as! SCNText!
                inputBeginHandler(text.string! as! String)
            } else {
                print("double tap emojiNode do nothing")
                sceneVC?.view.endEditing(true)
            }
        } else {
            sceneVC?.view.endEditing(true)
        }
    }
    
    @objc
    func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        sceneVC?.view.endEditing(true)
        if(gesture.state == .began) {
            if let object = objectInteracting(with: gesture, in: sceneView) {
                sceneVC?.anyAction()
                selectedNode = object
                print("LongPress Node to delete")
//                NodeManager.sharedInstance.removeNode(node: selectedNode!)
                let touchLocation = gesture.location(ofTouch: 0, in: sceneView)
                longPressHandler(selectedNode!, touchLocation)
            }
        }
    }
    
    @objc
    func didPan(_ gesture: ThresholdPanGesture) {
        sceneVC?.endEditing()
        
        switch gesture.state {
        case .began:
            // Check for interaction with a new object.
            if let object = objectInteracting(with: gesture, in: sceneView) {
                sceneVC?.anyAction()
                trackedObject = object
            }
            
        case .changed where gesture.isThresholdExceeded:
            guard let object = trackedObject else { return }
            let translation = gesture.translation(in: sceneView)
            
            let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(object.position))
            
            // The `currentTrackingPosition` is used to update the `selectedObject` in `updateObjectToCurrentTrackingPosition()`.
            currentTrackingPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)

            gesture.setTranslation(.zero, in: sceneView)
            
        case .changed:
            // Ignore changes to the pan gesture until the threshold for displacment has been exceeded.
            break
            
        default:
            // Clear the current position tracking.
            currentTrackingPosition = nil
            trackedObject = nil
        }
    }

    /**
     If a drag gesture is in progress, update the tracked object's position by
     converting the 2D touch location on screen (`currentTrackingPosition`) to
     3D world space.
     This method is called per frame (via `SCNSceneRendererDelegate` callbacks),
     allowing drag gestures to move virtual objects regardless of whether one
     drags a finger across the screen or moves the device through space.
     - Tag: updateObjectToCurrentTrackingPosition
     */
    @objc
    func updateObjectToCurrentTrackingPosition() {
        guard let object = trackedObject, let position = currentTrackingPosition else { return }
        translate(object, basedOn: position, infinitePlane: translateAssumingInfinitePlane)
    }

    /// - Tag: didRotate
    @objc
    func didRotate(_ gesture: UIRotationGestureRecognizer) {
        sceneVC?.endEditing()
        guard gesture.state == .changed else { return }
        
        /*
         - Note:
          For looking down on the object (99% of all use cases), we need to subtract the angle.
          To make rotation also work correctly when looking from below the object one would have to
          flip the sign of the angle depending on whether the object is above or below the camera...
         */
        sceneVC?.anyAction()
        trackedObject?.eulerAngles.y -= Float(gesture.rotation)
        
        gesture.rotation = 0
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow objects to be translated and rotated at the same time.
        return true
    }

    /// A helper method to return the first object that is found under the provided `gesture`s touch locations.
    /// - Tag: TouchTesting
    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) -> BaseNode? {
        for index in 0..<gesture.numberOfTouches {
            let touchLocation = gesture.location(ofTouch: index, in: view)
            
            // Look for an object directly under the `touchLocation`.
            if let object = sceneView.selectNode(at: touchLocation) {
                return object
            }
        }
        
        // As a last resort look for an object under the center of the touches.
        return sceneView.selectNode(at: gesture.center(in: view))
    }
    
    // MARK: - Update object position

    /// - Tag: DragVirtualObject
    private func translate(_ object: BaseNode, basedOn screenPos: CGPoint, infinitePlane: Bool) {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform,
            let (position, _, isOnPlane) = sceneView.worldPosition(fromScreenPosition: screenPos,
                                                                   objectPosition: object.simdPosition,
                                                                   infinitePlane: infinitePlane) else { return }
        
        /*
         Plane hit test results are generally smooth. If we did *not* hit a plane,
         smooth the movement to prevent large jumps.
         */
//        object.setPosition(position, relativeTo: cameraTransform, smoothMovement: !isOnPlane)
        
        if isOnPlane {
            object.setPanPosition(position, relativeTo: cameraTransform)
        }
    }
}

/// Extends `UIGestureRecognizer` to provide the center point resulting from multiple touches.
extension UIGestureRecognizer {
    func center(in view: UIView) -> CGPoint {
        let first = CGRect(origin: location(ofTouch: 0, in: view), size: .zero)

        let touchBounds = (1..<numberOfTouches).reduce(first) { touchBounds, index in
            return touchBounds.union(CGRect(origin: location(ofTouch: index, in: view), size: .zero))
        }

        return CGPoint(x: touchBounds.midX, y: touchBounds.midY)
    }
}
