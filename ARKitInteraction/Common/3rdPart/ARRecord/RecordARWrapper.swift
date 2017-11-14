//
//  RecordARProxy.swift
//  MyARKit
//
//  Created by alankong on 2017/11/13.
//  Copyright © 2017年 tuotiansudai. All rights reserved.
//

import Foundation
import ARVideoKit
import ARKit

@objc public enum RecordStatus : Int {
    
    case unknown
    case readyToRecord
    case recording
    case paused
}

@objc public protocol RecordDelegate : NSObjectProtocol {
    
    func recorder(didEndRecording path: URL, with noError: Bool)
    func recorder(didFailRecording error: Error?, and status: String)
    func recorder(willEnterBackground status: RecordStatus)
}

@objc public protocol RenderDelegate : NSObjectProtocol {
    
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer)
}

public class RecordARWrapper : NSObject, RenderARDelegate, RecordARDelegate {
    
    public var delegate: RecordDelegate?
    
    public var renderAR: RenderDelegate?
    
    var recorder : RecordAR?
    
    public init(ARSceneKit view : ARSCNView) {
        super.init()
        recorder = RecordAR(ARSceneKit: view)
        recorder?.delegate = self;
        recorder?.renderAR = self;
        
        recorder?.inputViewOrientations = [.portrait]
        recorder?.deleteCacheWhenExported = false
    }
    
    public func prepare(_ configuration: ARConfiguration) {
        recorder?.prepare(configuration)
    }
    
    public func rest() {
        recorder?.rest()
    }
    
    public func getStatus() -> RecordStatus {
        if (recorder?.status == .readyToRecord) {
            return RecordStatus.readyToRecord;
        } else if (recorder?.status == .recording) {
            return RecordStatus.recording;
        } else if (recorder?.status == .paused) {
            return RecordStatus.paused;
        }
        
        return RecordStatus.unknown;
    }
    
    public func record() {
        recorder?.record()
    }
    
    public func pause() {
        recorder?.pause()
    }
    
    public func stop() {
        recorder?.stop()
    }
    
    public func record(forDuration duration: TimeInterval, _ finished: ((URL) -> Swift.Void)?) {
        recorder?.record(forDuration: duration, finished)
    }
    
    public func stop(_ finished: ((URL) -> Swift.Void)?) {
        recorder?.stop(finished)
    }
    
}

//MARK: - ARVideoKit Delegate Methods
extension RecordARWrapper {
    public func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        // Do some image/video processing.
    }
    
    public func recorder(didEndRecording path: URL, with noError: Bool) {
        if noError {
            // Do something with the video path.
        }
    }
    
    public func recorder(didFailRecording error: Error?, and status: String) {
        // Inform user an error occurred while recording.
    }
    
    public func recorder(willEnterBackground status: RecordARStatus) {
        if status == .recording {
            recorder?.stopAndExport()
        }
    }
}
