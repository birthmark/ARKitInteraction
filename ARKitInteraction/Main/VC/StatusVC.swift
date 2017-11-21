/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility class for showing messages above the AR view.
*/

import Foundation
import ARKit

/**
 Displayed at the top of the main interface of the app that allows users to see
 the status of the AR experience, as well as the ability to control restarting
 the experience altogether.
 - Tag: StatusViewController
*/
class StatusVC: BaseVC {
    // MARK: - Types

    enum MessageType {
        case trackingStateEscalation
        case planeEstimation
        case contentPlacement
        case focusSquare

        static var all: [MessageType] = [
            .trackingStateEscalation,
            .planeEstimation,
            .contentPlacement,
            .focusSquare
        ]
    }

    // MARK: - IBOutlets

    var messagePanel: UIVisualEffectView!
    var messageLabel: UILabel!
    var btnRestartExperience: UIButton!
    var btnFlash: UIButton!
    var isFlashOpen: Bool!

    // MARK: - Properties
    
    /// Trigerred when the "Restart Experience" button is tapped.
    var restartExperienceHandler: () -> Void = {}
    
    /// Seconds before the timer message should fade out. Adjust if the app needs longer transient messages.
    private let displayDuration: TimeInterval = 6
    
    // Timer for hiding messages.
    private var messageHideTimer: Timer?
    
    private var timers: [MessageType: Timer] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isFlashOpen = false;
        
        self.setupViews()
        self.setupListeners()
    }
    
    func setupViews() {
        self.btnRestartExperience = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        self.view.addSubview(self.btnRestartExperience!)
        self.btnRestartExperience.setImage(UIImage.init(named: "restart"), for: [])
        self.btnRestartExperience.right = self.view.width-8;
        self.btnRestartExperience.centerY = 40;
        
        //
        btnFlash = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
        self.view.addSubview(self.btnFlash!)
        self.btnFlash.setImage(UIImage.init(named: "flashlight_off"), for: [])
        self.btnFlash.centerX = self.view.width/2;
        self.btnFlash.centerY = 40;
        
        //
        self.messagePanel = UIVisualEffectView.init(frame: CGRect.init(x: 12, y: 0, width: self.view.width-36-45, height: 60))
        self.view.addSubview(self.messagePanel)
        self.messagePanel.isUserInteractionEnabled = false
        
        self.messageLabel = UILabel.init(frame: CGRect.init(x: 0, y: 20, width: self.messagePanel.width, height: self.messagePanel.height-20))
        self.messagePanel.contentView.addSubview(self.messageLabel)
        self.messageLabel.font = UIFont.appNormalFont(fontSize: 12)
        self.messageLabel.textColor = UIColor.color(hexValue: 0x000000)
    }
    
    func setupListeners() {
        //按钮添加事件，方法要加@objc声明
        self.btnRestartExperience.addTarget(self, action:#selector(StatusVC.restartExperience(_:)), for: UIControlEvents.touchUpInside)
        self.btnFlash.addTarget(self, action:#selector(StatusVC.flashAction(_:)), for: UIControlEvents.touchUpInside)
    }
    // MARK: - Message Handling
	
	func showMessage(_ text: String, autoHide: Bool = true) {
        // Cancel any previous hide timer.
        messageHideTimer?.invalidate()

        messageLabel.text = text

        // Make sure status is showing.
        setMessageHidden(false, animated: true)

        if autoHide {
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
	}
    
	func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)

        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
		})

        timers[messageType] = timer
	}
    
    func cancelScheduledMessage(`for` messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }

    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }
    
    // MARK: - ARKit
    
	func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
		showMessage(trackingState.presentationString, autoHide: autoHide)
	}
	
	func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)

		let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)

            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }

            self.showMessage(message, autoHide: false)
		})

        timers[.trackingStateEscalation] = timer
    }
    
    @objc func flashAction(_ sender: UIButton) {
        self.isFlashOpen = !self.isFlashOpen
        print("flashAction")
        
        let device: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        if (device.hasTorch) {
            
            do {
                try device.lockForConfiguration()
                
                if (self.isFlashOpen) {
                    device.torchMode = .on
                    self.btnFlash.setImage(UIImage.init(named: "flashlight_on"), for: [])
                } else {
                    device.torchMode = .off
                    self.btnFlash.setImage(UIImage.init(named: "flashlight_off"), for: [])
                }
                device.unlockForConfiguration()
            } catch let err as Error!{
                print("打开闪光灯失败！", err)
            }
        }
    }
    
    @objc func restartExperience(_ sender: UIButton) {
        restartExperienceHandler()
        resetFlash()
    }
	
    func resetFlash() {
        self.isFlashOpen = true
        flashAction(btnFlash)
    }
	// MARK: - Panel Visibility
    
	private func setMessageHidden(_ hide: Bool, animated: Bool) {
        // The panel starts out hidden, so show it before animating opacity.
        messagePanel.isHidden = false
        
        guard animated else {
            messagePanel.alpha = hide ? 0 : 1
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.messagePanel.alpha = hide ? 0 : 1
        }, completion: nil)
	}
}

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(.excessiveMotion):
            return "TRACKING LIMITED\nExcessive motion"
        case .limited(.insufficientFeatures):
            return "TRACKING LIMITED\nLow detail"
        case .limited(.initializing):
            return "Initializing"
        }
    }

    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface, or reset the session."
        default:
            return nil
        }
    }
}
