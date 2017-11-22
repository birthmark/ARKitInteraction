//
//  MainVC.swift
//  ARKitInteraction
//
//  Created by alankong on 2017/11/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import ARVideoKit
import MediaPlayer

class SceneVC: BaseVC, UIPopoverPresentationControllerDelegate, EmojiSelectionDelegate,UIGestureRecognizerDelegate {

    // MARK: IBOutlets
    
    var sceneView: ARView!
    var btnAddEmoji: UIButton!
    var recorder: RecordAR!
    var btnVideoCapture: UIButton!
    var btn3DText: UIButton!
    var isCapturing: Bool!
    var inputBar: InputPanelView!
    var btnDelete: DeleteButton!
    
    var isMovingToWindow: Bool!
    var isFrontCemare: Bool!
    
    // MARK: - UI Elements
    
    var focusSquare = FocusSquareNode()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusVC: StatusVC = {
        var VC: StatusVC = StatusVC()
        VC.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 60)
        self.view.addSubview(VC.view)
//        VC.view.backgroundColor = UIColor.red
        self.addChildViewController(VC)
        return VC
    }()
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    var nodeGestureHandler: NodeGestureHandler?
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.tuotian.arkitinteraction")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNavigationBar()
        self.view.backgroundColor = UIColor.white
        self.isCapturing = false
        self.isMovingToWindow = true
        self.isFrontCemare = true
        
        self.setupViews()
        self.setupListener()
        
        nodeGestureHandler = NodeGestureHandler(sceneView: sceneView)
        nodeGestureHandler?.sceneVC = self
        //手势回调
        nodeGestureHandler?.inputBeginHandler = {[unowned self](text: String) in
            self.inputBar?.textView?.text = text
            self.inputBar?.textView?.becomeFirstResponder()
        }
        
        nodeGestureHandler?.longPressHandler = {[unowned self](node: BaseNode, point: CGPoint) in
            self.btnDelete.center = CGPoint.init(x: max(18, point.x-50), y: max(18,point.y-50))
            self.btnDelete.node = node
            
            UIView.animate(withDuration: 0.3, animations: {
                self.btnDelete.alpha = 1.0
            })
        }
        
        self.recorder = RecordAR.init(ARSceneKit: self.sceneView)
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        // setup light
        let spotLight = SCNNode()
        spotLight.position = SCNVector3Make(LIGNT_X, LIGNT_Y, LIGNT_Z)
        spotLight.light = SCNLight()
        spotLight.light?.type = .directional
        spotLight.light?.castsShadow = true
        spotLight.light?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        spotLight.light?.shadowMode = .deferred
        self.sceneView.scene.rootNode.addChildNode(spotLight)
        
        
        /*
         The `sceneView.automaticallyUpdatesLighting` option creates an
         ambient light source and modulates its intensity. This sample app
         instead modulates a global lighting environment map for use with
         physically based materials, so disable automatic lighting.
         */
        sceneView.automaticallyUpdatesLighting = false
        if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
            sceneView.scene.lightingEnvironment.contents = environmentMap
        }
        
        // Hook up status view controller callback(s).
        statusVC.restartExperienceHandler = { [unowned self] in
            self.endEditing()
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        if (self.isMovingToWindow) {
//            self.isMovingToWindow = false
            // Start the `ARSession`.
            resetTracking()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //todo
        stopTracking()
    }
    
    func setupViews() {
        self.sceneView = ARView()
        self.sceneView.frame = self.view.bounds
        self.view.addSubview(self.sceneView)
        self.sceneView.autoenablesDefaultLighting = true
        
        //
        self.btnVideoCapture = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        self.view.addSubview(self.btnVideoCapture)
        self.btnVideoCapture.setTitle("拍摄", for: .normal)
        self.btnVideoCapture.backgroundColor = UIColor.color(hexValue: 0x000000, alpha: 0.2)
        self.btnVideoCapture.centerX = self.view.width/2;
        self.btnVideoCapture.bottom = self.view.height-20;
        
        //
        self.btnAddEmoji = UIButton(frame: CGRect.init(x: 0, y: 0, width: 36, height: 36));
        self.btnAddEmoji.setImage(UIImage.init(named: "emoji_3d"), for: [])
        self.view.addSubview(self.btnAddEmoji)
        self.btnAddEmoji.centerY = self.btnVideoCapture.centerY
        self.btnAddEmoji.left = self.btnVideoCapture.right+57
        
        //
        self.btn3DText = UIButton(frame: CGRect.init(x: 0, y: 0, width: 36, height: 36));
        self.view.addSubview(self.btn3DText)
        self.btn3DText.setImage(UIImage.init(named: "letter_3d"), for: [])
        self.btn3DText.centerY = self.btnVideoCapture.centerY
        self.btn3DText.right = self.btnVideoCapture.left-57
        
        //
        self.btnDelete = DeleteButton(frame: CGRect.init(x: 0, y: 0, width: 36, height: 36));
        self.view.addSubview(self.btnDelete)
        self.btnDelete.setImage(UIImage.init(named: "delete"), for: [])
        self.btnDelete.alpha = 0.0
        
        //
        self.inputBar = InputPanelView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 76))
        self.view.addSubview(self.inputBar)
        self.inputBar.inputFinishHandler = { [unowned self](text: String?) in
                print("input string \(text!)")
                self.nodeGestureHandler?.setText(text: text!);
                self.view.endEditing(true)
            }
        
        self.inputBar.bottom = self.view.height
        self.inputBar.alpha = 0.0
    }
    
    func setupListener() {
        self.btnAddEmoji.addTarget(self, action: #selector(showEmojiSelectionVC), for: UIControlEvents.touchUpInside)
        self.btnVideoCapture.addTarget(self, action: #selector(captureVideo), for: UIControlEvents.touchUpInside)
        self.btn3DText.addTarget(self, action: #selector(text3D), for: UIControlEvents.touchUpInside)
        self.btnDelete.addTarget(self, action: #selector(deleteNode), for: UIControlEvents.touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let deltaY = keyBoardBounds.size.height
        let animations:(() -> Void) = {
            self.inputBar.bottom = self.view.height-deltaY
            self.inputBar.alpha = 1.0
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
            
        } else{
            animations()
        }
    }
    
    @objc func keyboardWillHidden(note: NSNotification) {
        let userInfo  = note.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            self.inputBar.bottom = self.view.height
            self.inputBar.alpha = 0.0
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func endEditing() {
        self.view.endEditing(true)
        
        if (self.btnDelete.alpha > 0.0) {
            self.btnDelete.center = CGPoint.init(x: -36, y: -36)
            UIView.animate(withDuration: 0.3) {
                self.btnDelete.alpha = 0.0
            }
        }
    }
    
    func hideDeleteButton() {
        if (self.btnDelete.alpha > 0.0) {
            self.btnDelete.center = CGPoint.init(x: -36, y: -36)
            UIView.animate(withDuration: 0.3) {
                self.btnDelete.alpha = 0.0
            }
        }
    }
    
    @objc func deleteNode() {
        NodeManager.sharedInstance.removeNode(node: self.btnDelete.node!)
        UIView.animate(withDuration: 0.3, animations: {
            self.btnDelete.alpha = 0.0
        })
    }
    
    @objc func text3D() {
        endEditing()
        
        let node: Text3DNode = Text3DNode()
        node.scale = SCNVector3Make(0.2, 0.2, 0.2)
        node.setText(text: "双击修改")
        self.placeNode(node)
        NodeManager.sharedInstance.addNode(node: node)
        
        let cameraAngle = self.sceneView.session.currentFrame?.camera.eulerAngles.y
        node.eulerAngles.y += cameraAngle!
    }
    
    @objc func captureVideo() {
        endEditing()
        
        if (self.isCapturing) {
            self.btnVideoCapture.setTitle("拍摄中", for: .normal)
            self.recorder.stop({ (url) in
                print("url: "+url.path)
                
                do {
                let fileAttributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary
                    let length: CUnsignedLongLong = fileAttributes.fileSize();
                    let ff: Float = Float(length)/1024.0/1024.0;
                    print("lenth: "+String(ff)+"M")
                    
                    DispatchQueue.main.async {
                        let playerVC: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: url)
                        self.present(playerVC, animated: true, completion: nil)
                    }
                
                } catch {}
                
            })
        } else {
            self.btnVideoCapture.setTitle("停止", for: .normal)
            self.recorder.record()
        }
        
        self.isCapturing = !self.isCapturing
    }
    
    @objc func showEmojiSelectionVC() {
        endEditing()
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !btnAddEmoji.isHidden && !NodeManager.sharedInstance.isLoading! else { return }
        
        statusVC.cancelScheduledMessage(for: .contentPlacement)

        let selectionVC: EmojiSelectionVC = EmojiSelectionVC();
        selectionVC.preferredContentSize = CGSize(width: 100, height: 100);
        selectionVC.modalPresentationStyle = .popover;
        
        if let popoverController = selectionVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = self.btnAddEmoji
            popoverController.sourceRect = self.btnAddEmoji.bounds
        }
        
        selectionVC.arrEmojiConfigVOs = NodeManager.sharedInstance.arrEmojiConfigVOs!
        selectionVC.delegate = self
        
        self.present(selectionVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Scene content setup
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
//        if (self.isFrontCemare) {
//            let configuration = ARFaceTrackingConfiguration()
//            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        } else {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            statusVC.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 3.5, messageType: .planeEstimation)
//        }
    }
    
    func stopTracking() {
        session.pause()
        statusVC.resetFlash()
    }
    
    // MARK: - Focus Square
    
    func updateFocusSquare() {
        let isObjectVisible = NodeManager.sharedInstance.arrLoadedNodes?.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        if isObjectVisible! {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusVC.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        
        // We should always have a valid world position unless the sceen is just being initialized.
        guard let (worldPosition, planeAnchor, _) = sceneView.worldPosition(fromScreenPosition: screenCenter, objectPosition: focusSquare.lastPosition) else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            btnAddEmoji.isHidden = true
            btnVideoCapture.isHidden = true
            btn3DText.isHidden = true
            return
        }
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
            let camera = self.session.currentFrame?.camera
            
            if let planeAnchor = planeAnchor {
                self.focusSquare.state = .planeDetected(anchorPosition: worldPosition, planeAnchor: planeAnchor, camera: camera)
            } else {
                self.focusSquare.state = .featuresDetected(anchorPosition: worldPosition, camera: camera)
            }
        }
        btnAddEmoji.isHidden = false
        btnVideoCapture.isHidden = false
        btn3DText.isHidden = false
        statusVC.cancelScheduledMessage(for: .focusSquare)
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }

    //重置
    func restartExperience() {
        print("restartExperience")
        guard isRestartAvailable, !NodeManager.sharedInstance.isLoading! else { return }
        isRestartAvailable = false
        statusVC.cancelAllScheduledMessages()
        NodeManager.sharedInstance.removeAllNodes()
        resetTracking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
    
    //放入3D空间
    func placeNode(_ node: BaseNode) {
        guard let cameraTransform = session.currentFrame?.camera.transform,
            let focusSquarePosition = focusSquare.lastPosition else {
                statusVC.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
                return
        }
        
        nodeGestureHandler!.selectedNode = node
        node.setNodePosition(focusSquarePosition, relativeTo: cameraTransform)
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }

    // MARK: - VirtualObjectSelectionViewControllerDelegate
    func emojiSelectionVC(_: EmojiSelectionVC, didSelectObject object: EmojiConfigVO) {
        //加载模型
        NodeManager.sharedInstance.loadNode(object, loadedHandler: { [unowned self] loadedNode in
            DispatchQueue.main.async {
                self.placeNode(loadedNode)
                
                let cameraAngle = self.sceneView.session.currentFrame?.camera.eulerAngles.y
                loadedNode.eulerAngles.y += cameraAngle!
            }
        })
    }
    
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return NodeManager.sharedInstance.arrLoadedNodes!.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}
