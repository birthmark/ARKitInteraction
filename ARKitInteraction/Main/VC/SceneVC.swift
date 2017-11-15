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

class SceneVC: BaseVC, UIPopoverPresentationControllerDelegate {

    // MARK: IBOutlets
    
    var sceneView: ARView!
    var btnAddEmoji: UIButton!
    var recorder: RecordAR!
    var btnVideoCapture: UIButton!
    var btn3DText: UIButton!
    var isCapturing: Bool!
    
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
    lazy var nodeGestureHandler = NodeGestureHandler(sceneView: sceneView)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let emojiLoader = EmojiNodeLoader()
    
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
        self.isCapturing = false;
        
        self.setupViews()
        self.setupListener()
        
        self.recorder = RecordAR.init(ARSceneKit: self.sceneView)
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        // setup light
//        let cone = SCNCone.init(topRadius: 1, bottomRadius: 25, height: 50)
//        cone.radialSegmentCount = 10
//        cone.heightSegmentCount = 5
        
        let spotLight = SCNNode()
//        spotLight.geometry = cone
//        spotLight.geometry?.firstMaterial?.emission.contents = UIColor.yellow
        spotLight.position = SCNVector3Make(-0.5, 10.2, -0.8)
        spotLight.light = SCNLight()
        spotLight.light?.type = .directional
        spotLight.light?.castsShadow = true
        
//        let handleSpot = SCNNode()
//        handleSpot.position = SCNVector3Make(-10, 10, 10)
        self.sceneView.scene.rootNode.addChildNode(spotLight)
//        self.sceneView.scene.rootNode.addChildNode(handleSpot)
        
        
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
            self.restartExperience()
        }
    }
    
    func setupViews() {
        self.sceneView = ARView()
        self.sceneView.frame = self.view.bounds
        self.view.addSubview(self.sceneView)
        
        //
        self.btnVideoCapture = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        self.view.addSubview(self.btnVideoCapture)
        self.btnVideoCapture.setTitle("拍摄", for: .normal)
        self.btnVideoCapture.backgroundColor = UIColor.color(hexValue: 0x000000, alpha: 0.2)
        self.btnVideoCapture.centerX = self.view.width/2;
        self.btnVideoCapture.bottom = self.view.height-50;
        
        //
        self.btnAddEmoji = UIButton(frame: CGRect.init(x: 0, y: 0, width: 45, height: 45));
        self.btnAddEmoji.setImage(#imageLiteral(resourceName: "add"), for: [])
        self.view.addSubview(self.btnAddEmoji)
        self.btnAddEmoji.centerY = self.btnVideoCapture.centerY
        self.btnAddEmoji.left = self.btnVideoCapture.right+30
        
        //
        self.btn3DText = UIButton(frame: CGRect.init(x: 0, y: 0, width: 45, height: 45));
        self.view.addSubview(self.btn3DText)
        self.btn3DText.setTitle("T", for: [])
        self.btn3DText.backgroundColor = UIColor.color(hexValue: 0x000000, alpha: 0.2)
        self.btn3DText.centerY = self.btnVideoCapture.centerY
        self.btn3DText.right = self.btnVideoCapture.left-30
    }
    
    func setupListener() {
        self.btnAddEmoji.addTarget(self, action: #selector(showEmojiSelectionVC), for: UIControlEvents.touchUpInside)
        self.btnVideoCapture.addTarget(self, action: #selector(captureVideo), for: UIControlEvents.touchUpInside)
        self.btn3DText.addTarget(self, action: #selector(text3D), for: UIControlEvents.touchUpInside)
    }
    
    @objc func text3D() {
        let node: Text3DNode = Text3DNode()
        node.scale = SCNVector3Make(0.2, 0.2, 0.2)
        node.setText(text: "选择修改")
        self .placeVirtualObject(node)
    }
    
    @objc func captureVideo() {
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
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !btnAddEmoji.isHidden && !emojiLoader.isLoading else { return }
        
        statusVC.cancelScheduledMessage(for: .contentPlacement)

        let selectionVC: EmojiSelectionVC = EmojiSelectionVC();
        selectionVC.preferredContentSize = CGSize(width: 100, height: 100);
        selectionVC.modalPresentationStyle = .popover;
        
        if let popoverController = selectionVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = self.btnAddEmoji
            popoverController.sourceRect = self.btnAddEmoji.bounds
        }
        
        selectionVC.virtualObjects = BaseNode.availableEmojiObjects
        selectionVC.delegate = self
        
        // Set all rows of currently placed objects to selected.
        for object in emojiLoader.loadedObjects {
            guard let index = BaseNode.availableEmojiObjects.index(of: object) else { continue }
            selectionVC.selectedEmojiObjectRows.insert(index)
        }
        
        self.present(selectionVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the `ARSession`.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
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
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusVC.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 3.5, messageType: .planeEstimation)
    }
    
    // MARK: - Focus Square
    
    func updateFocusSquare() {
        let isObjectVisible = emojiLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        if isObjectVisible {
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
}
