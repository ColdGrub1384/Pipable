//
//  PlayerView.swift
//  
//
//  Created by Emma on 17-11-21.
//

import UIKit
import AVKit

class PlayerView: UIView, AVPictureInPictureSampleBufferPlaybackDelegate, AVPictureInPictureControllerDelegate {
    
    override class var layerClass: AnyClass {
        AVSampleBufferDisplayLayer.self
    }
    
    weak var delegate: PictureInPictureDelegate?
    
    var pipController: AVPictureInPictureController?
    
    var wasAudioSessionActive = false
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
    }
    
    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .indefinite, duration: CMTime(seconds: .infinity, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        false
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        delegate?.didFailToEnterPictureInPicture(error: error)
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
        delegate?.didExitPictureInPicture()
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.didEnterPictureInPicture()
    }
}
