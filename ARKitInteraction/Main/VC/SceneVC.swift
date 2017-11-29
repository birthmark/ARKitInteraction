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

class SceneVC: BaseVC, UIPopoverPresentationControllerDelegate, EmojiSelectionViewDelegate,UIGestureRecognizerDelegate {

    // MARK: IBOutlets
    
    var sceneView: ARView!
    var btnAddEmoji: UIButton!
    var recorder: RecordAR!
    var btnVideoCapture: CaptureButton!
    var btn3DText: UIButton!
    var isCapturing: Bool!
    var inputBar: InputPanelView!
    var btnDelete: DeleteButton!
    
    var isMovingToWindow: Bool!
    var isFrontCemare: Bool!
    var captureTimer: Timer!
    var counter: Int!
    var step: Int = 20//毫秒
    
    var planeNode: SCNNode!
    
    var btnReset: UIButton!
    var btnCamera: UIButton!
    var btnSetting: UIButton!
    var btnNext: UIButton!
    var msgView: MessageView!
    
    // MARK: - UI Elements
    
    var focusSquare = FocusSquareNode()
    
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
        self.counter = 0
        
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
            self.btnDelete.center = CGPoint.init(x: max(18, point.x), y: max(18,point.y))
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
        
        // setup sun light
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = .directional
        sunLight.eulerAngles.x = LIGTH_ROTATE_X
        sunLight.eulerAngles.y = LIGTH_ROTATE_Y
        sunLight.light?.castsShadow = true
        sunLight.light?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        sunLight.light?.shadowMode = .deferred
        self.sceneView.scene.rootNode.addChildNode(sunLight)
        
//        // setup ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor.init(red: 0.15, green: 0.25, blue: 0.15, alpha: 1.0)
        self.sceneView.scene.rootNode.addChildNode(ambientLight)
        
        //加默认的平面？？
        planeNode = SCNNode()
        planeNode.geometry = SCNBox(width: CGFloat(10), height: CGFloat(0.01), length: CGFloat(10), chamferRadius: 0)
        planeNode.geometry?.materials.first?.lightingModel = .constant//todo
        planeNode.geometry?.materials.first?.diffuse.contents = UIColor.color(hexValue: 0x000000)
        planeNode.position = SCNVector3Make(0, -1.0, 0)
        if (!SHOW_SHADOW_PLANE) {
            planeNode.geometry?.materials.first?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        }
        self.sceneView.scene.rootNode.addChildNode(planeNode)
        
        /*
         The `sceneView.automaticallyUpdatesLighting` option creates an
         ambient light source and modulates its intensity. This sample app
         instead modulates a global lighting environment map for use with
         physically based materials, so disable automatic lighting.
         */
        sceneView.automaticallyUpdatesLighting = true
        if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
            sceneView.scene.lightingEnvironment.contents = environmentMap
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
            self.msgView.setStickingMessage(message: "初始化黑科技")
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
        
        self.btnSetting = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
        self.view.addSubview(self.btnSetting!)
        self.btnSetting.setImage(UIImage.init(named: "setting"), for: [])
        self.btnSetting.left = 20;
        self.btnSetting.centerY = 40;
        
        self.btnNext = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
        self.view.addSubview(self.btnNext!)
        self.btnNext.setImage(UIImage.init(named: "next"), for: [])
        self.btnNext.right = self.view.width-20;
        self.btnNext.centerY = 40;
        
        //
        self.btnReset = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
        self.view.addSubview(self.btnReset!)
        self.btnReset.setImage(UIImage.init(named: "restart"), for: [])
        self.btnReset.centerX = self.view.width/2+16+9;
        self.btnReset.centerY = 40;
        self.btnReset.isUserInteractionEnabled = false
        
        //
        self.btnCamera = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
        self.view.addSubview(self.btnCamera!)
        self.btnCamera.setImage(UIImage.init(named: "camera"), for: [])
        self.btnCamera.centerX = self.view.width/2-16-9;
        self.btnCamera.centerY = 40;
        
        //
        self.btnVideoCapture = CaptureButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        self.view.addSubview(self.btnVideoCapture)
        self.btnVideoCapture.centerX = self.view.width/2;
        self.btnVideoCapture.bottom = self.view.height-20;
        
        //
        self.btnAddEmoji = UIButton(frame: CGRect.init(x: 0, y: 0, width: 36, height: 36));
        self.btnAddEmoji.setImage(UIImage.init(named: "emoji_3d"), for: [])
        self.view.addSubview(self.btnAddEmoji)
        self.btnAddEmoji.centerY = self.btnVideoCapture.centerY
        self.btnAddEmoji.left = self.btnVideoCapture.right+57
        self.btnAddEmoji.alpha = 0.5
        self.btnAddEmoji.isUserInteractionEnabled = false
        
        //
        self.btn3DText = UIButton(frame: CGRect.init(x: 0, y: 0, width: 36, height: 36));
        self.view.addSubview(self.btn3DText)
        self.btn3DText.setImage(UIImage.init(named: "letter_3d"), for: [])
        self.btn3DText.centerY = self.btnVideoCapture.centerY
        self.btn3DText.right = self.btnVideoCapture.left-57
        self.btn3DText.alpha = 0.5
        self.btn3DText.isUserInteractionEnabled = false
        
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
        
        self.msgView = MessageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 22))
        self.view.addSubview(self.msgView)
        self.msgView.isUserInteractionEnabled = false
        self.msgView.bottom = self.btnVideoCapture.top-30
        self.msgView.alpha = 1.0
    }
    
    func setupListener() {
        self.btnSetting.addTarget(self, action: #selector(settingsAction), for: .touchUpInside)
        self.btnCamera.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
        self.btnReset.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        self.btnNext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        self.btnAddEmoji.addTarget(self, action: #selector(showEmojiSelectionView), for: .touchUpInside)
        self.btnVideoCapture.addTarget(self, action: #selector(startCaptureVideo), for: .touchDown)
        self.btnVideoCapture.addTarget(self, action: #selector(stopCaptureVideo), for: .touchCancel)
        self.btnVideoCapture.addTarget(self, action: #selector(stopCaptureVideo), for: .touchUpInside)
        self.btnVideoCapture.addTarget(self, action: #selector(stopCaptureVideo), for: .touchUpOutside)
        self.btn3DText.addTarget(self, action: #selector(text3D), for: .touchUpInside)
        self.btnDelete.addTarget(self, action: #selector(deleteNode), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func settingsAction() {
        print("todo settingsAction")
        self.msgView.setMessag(message: "settingsAction")
    }
    @objc func cameraAction() {
        print("todo cameraAction")
        self.msgView.setMessag(message: "cameraAction")
    }
    @objc func resetAction() {
        self.restartExperience()
    }
    @objc func nextAction() {
        print("todo nextAction")
        self.msgView.setMessag(message: "nextAction")
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            let node: Text3DNode = Text3DNode()
            node.scale = SCNVector3Make(1.0, 1.0, 1.0)
            node.setText(text: "双击修改")
            node.handler = self.nodeHeight(_:)
            
            DispatchQueue.main.sync {[unowned self] in
                self.placeNode(node)
                NodeManager.sharedInstance.addNode(node: node)
                
                let cameraAngle = self.sceneView.session.currentFrame?.camera.eulerAngles.y
                node.eulerAngles.y += cameraAngle!
            }
        }
    }
    
    func nodeHeight(_ height: Float) {
        print("node height: \(height)")
        planeNode.position = SCNVector3Make(planeNode.position.x, Float.minimum(planeNode.position.y, height), planeNode.position.z)
    }
    
    @objc func startCaptureVideo() {
        endEditing()
        
        if (!self.isCapturing) {
            self.isCapturing = true
            focusSquare.hideImmediately()
            
            UIView.animate(withDuration: 0.3, animations: {
                let center = self.btnVideoCapture.center
                self.btnVideoCapture.size = CGSize.init(width: 110, height: 110)
                self.btnVideoCapture.center = center
            }, completion: { (finish) in
                if (self.isCapturing) {//
                    self.recorder.record()
                    self.captureTimer = Timer.scheduledTimer(withTimeInterval: Double(self.step)/1000.0, repeats: true, block: { [weak self] _ in
                        self?.counter! += (self?.step)!
                        self?.btnVideoCapture.setProgress(progress: Double((self?.counter)!) / 10000)
                        
                        if ((self?.counter)! >= 10000) {
                            self?.stopCaptureVideo()
                        }
                        
                    })
                }
            })
        }
    }
    
    @objc func stopCaptureVideo() {
        if (self.isCapturing) {
            //防止多次连续点击
            self.btnVideoCapture.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: { [unowned self] in
                self.btnVideoCapture.isUserInteractionEnabled = true
            })
            
            if (self.captureTimer) != nil {
                self.captureTimer.invalidate()
            }
            
            self.isCapturing = false
            self.btnVideoCapture.setProgress(progress: 0.0)
            
            UIView.animate(withDuration: 0.3, animations: {
                let center = self.btnVideoCapture.center
                self.btnVideoCapture.size = CGSize.init(width: 80, height: 80)
                self.btnVideoCapture.center = center
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: { [unowned self] in
                self.doStopCapterVideo()
            })
        }
    }
    
    private func doStopCapterVideo() {
        self.recorder.stop({ (url) in
            print("url: "+url.path)
            if (self.counter > 1000) {//1秒之内忽略
                do {
                    let fileAttributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary
                    let length: CUnsignedLongLong = fileAttributes.fileSize();
                    let ff: Float = Float(length)/1024.0/1024.0;
                    print("video file lenth: "+String(ff)+"M")
                    
                    DispatchQueue.main.async {
                        self.didFinishCapture(url: url)
                    }
                    
                } catch {}
            }
            
            self.counter = 0
        })
    }
    
    //录制成功
    func didFinishCapture(url: URL) {
        let playerVC: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: url)
        self.present(playerVC, animated: true, completion: nil)
    }
    
    @objc func showEmojiSelectionView() {
        endEditing()
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !btnAddEmoji.isHidden && !NodeManager.sharedInstance.isLoading! else { return }
        
        let view: EmojiSelectionView = EmojiSelectionView.init(frame: self.view.bounds)
        view.top = self.view.height
        self.view.addSubview(view)
        view.delegate = self
        view.setConfigs(configs: NodeManager.sharedInstance.arrEmojiConfigVOs!)
        
        UIView.animate(withDuration: 0.3, animations: {
            view.top = 0
        })
    }
    
//    @objc func showEmojiSelectionVC() {
//        endEditing()
//        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
//        guard !btnAddEmoji.isHidden && !NodeManager.sharedInstance.isLoading! else { return }
//
//        statusVC.cancelScheduledMessage(for: .contentPlacement)
//
//        let selectionVC: EmojiSelectionVC = EmojiSelectionVC();
//        selectionVC.preferredContentSize = CGSize(width: 100, height: 100);
//        selectionVC.modalPresentationStyle = .popover;
//
//        if let popoverController = selectionVC.popoverPresentationController {
//            popoverController.delegate = self
//            popoverController.sourceView = self.btnAddEmoji
//            popoverController.sourceRect = self.btnAddEmoji.bounds
//        }
//
//        selectionVC.arrEmojiConfigVOs = NodeManager.sharedInstance.arrEmojiConfigVOs!
//        selectionVC.delegate = self
//
//        self.present(selectionVC, animated: true, completion: nil)
//    }
    
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
        camera.automaticallyAdjustsZRange = true
        
        autoFocus()
    }
    
    func autoFocus() {
        let device: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        let focusMode = device.focusMode
        
        if (focusMode == .locked) {
            print("foocusMode locked!")
            if (device.isFocusModeSupported(.continuousAutoFocus)) {
                
                do {
                    try device.lockForConfiguration()
                    print("设置自动对焦")
                    device.focusMode = .continuousAutoFocus
                    device.unlockForConfiguration()
                } catch let err as Error!{
                    print("自动对焦失败！", err)
                }
            } else {
                print("不支持自动对焦！")
            }
        }
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
//            self.msgView.setMessag(message: "FIND A SURFACE TO PLACE AN OBJECT")
            self.autoFocus()
//        }
    }
    
    func stopTracking() {
        session.pause()
    }
    
    //
    func updateDeleteButton() {
        if (self.btnDelete.alpha > 0) {
            
            let boundingBox = true
            if (boundingBox) {
                let (min, max) = (self.btnDelete.node?.boundingBox)!
                //中心点坐标=位置加上boundingBox的高度一半，乘以缩放系数(位置在模型的底部中心点)
                var pos = self.btnDelete.node?.position
                let scale = self.btnDelete.node?.scale
                pos?.y += (max.y-min.y)*(scale?.y)!/2
                
                let position = self.sceneView.projectPoint(pos!)
                
//                if abs(Float(self.btnDelete.center.x) - position.x) > 5 || abs(Float(self.btnDelete.center.y) - position.y) > 5 {
                    self.btnDelete.center = CGPoint.init(x: Int(position.x), y: Int(position.y))
//                }
            } else {
                let position = self.sceneView.projectPoint((self.btnDelete.node?.position)!)
                self.btnDelete.center = CGPoint.init(x: Int(position.x), y: Int(position.y))
            }
        }
    }
    // MARK: - Focus Square
    
    func updateFocusSquare() {
        let isObjectVisible = NodeManager.sharedInstance.arrLoadedNodes?.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        if isObjectVisible! || isCapturing {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        // We should always have a valid world position unless the sceen is just being initialized.
        guard let (worldPosition, planeAnchor, _) = sceneView.worldPosition(fromScreenPosition: screenCenter, objectPosition: focusSquare.lastPosition) else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
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
        
        DispatchQueue.main.async {
            self.btnAddEmoji.alpha = 1.0
            self.btnAddEmoji.isUserInteractionEnabled = true
            self.btn3DText.alpha = 1.0
            self.btn3DText.isUserInteractionEnabled = true
            self.btnReset.isUserInteractionEnabled = true
            self.msgView.hideStickingMessage()
        }
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
        hideDeleteButton()
        NodeManager.sharedInstance.removeAllNodes()
        resetTracking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRestartAvailable = true
        }
    }
    
    //放入3D空间
    func placeNode(_ node: BaseNode) {
        guard let cameraTransform = session.currentFrame?.camera.transform,
            let focusSquarePosition = focusSquare.lastPosition else {
                return
        }
        
        nodeGestureHandler!.selectedNode = node
        node.handler = self.nodeHeight(_:)
        node.setNodePosition(focusSquarePosition, relativeTo: cameraTransform)
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }

    // MARK: -
    func emojiSelectionView(_ view: EmojiSelectionView, didSelectAt index: Int) {
        //加载模型
        let object = NodeManager.sharedInstance.arrEmojiConfigVOs![index]
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
