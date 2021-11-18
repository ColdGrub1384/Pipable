import UIKit
import AVKit

/// A protocol for implementing Picture in Picture in a`UIView`.
///
/// If a view conforms to this protocol, it is automatically compatible with Picture in Picture.
/// An instance of `AVPictureInPictureController` is automatically created for the view, which allows entering and exiting PIP. Each time the content of the view is changed, you must call `updatePictureInPictureSnapshot`.
@available(iOS 15.0, *)
public protocol Pipable where Self: UIView {
    
    /// The delegate for the PIP events.
    var pictureInPictureDelegate: PictureInPictureDelegate? { get set }
    
    /// The size of the preview displayed in Picture in Picture.
    /// You can return the size of the target view to keep the same aspect ratio, but text content may not be easily readable.
    /// You can also return a different size. If you do so, the view will be resized while taking the snapshots.
    var previewSize: CGSize { get }
    
    /// Called before a snapshot is taken. Setup the view if necessary.
    func willTakeSnapshot()
    
    /// Called after taking a snapshot. Undo the changes done on `willTakeSnapshot` if necessary.
    func didTakeSnapshot()
}

@available(iOS 15.0, *)
extension Pipable {
    
    /// The Picture in Picture controller created automatically by conforming to `Pipable`. Use this object to start or exit PIP. Before entering PIP, the application must start a playback `AVAudioSession`, which requires a background mode.
    public var pictureInPictureController: AVPictureInPictureController? {
        setupPlayerIfNeeded()
        return player?.pipController
    }
    
    /// Updates the snapshot displayed in PIP. You may want to call this method everytime the content of a `UITextView` changes for example.
    /// While taking it, the view will be resized to `previewSize`.
    public func updatePictureInPictureSnapshot() {
        setupPlayerIfNeeded()
        
        player?.frame.size = frame.size
        (player?.layer as? AVSampleBufferDisplayLayer)?.flush()
        
        willTakeSnapshot()
        (player?.layer as? AVSampleBufferDisplayLayer)?.enqueue(getSnapshot())
        didTakeSnapshot()
    }
}

/// A set of method to respond to PIP events.
@available(iOS 9, *)
public protocol PictureInPictureDelegate where Self: AnyObject {
    
    /// User entered PIP.
    func didEnterPictureInPicture()
    
    /// User exited PIP.
    func didExitPictureInPicture()
    
    /// PIP failed to start.
    func didFailToEnterPictureInPicture(error: Error)
}

@available(iOS 15.0, *)
extension Pipable {
    
    var player: PlayerView? {
        subviews.first(where: { $0 is PlayerView }) as? PlayerView
    }
    
    func setupPlayerIfNeeded() {
        if player == nil {
            let playerView = PlayerView()
            playerView.isHidden = true
            playerView.pipController = AVPictureInPictureController(contentSource: .init(sampleBufferDisplayLayer: playerView.layer as! AVSampleBufferDisplayLayer, playbackDelegate: playerView))
            
            playerView.pipController?.delegate = playerView
            addSubview(playerView)
        }
        
        player?.delegate = pictureInPictureDelegate
    }
    
    func getSnapshot() -> CMSampleBuffer {
        
        let size = frame.size
        
        let constraints = superview?.constraints ?? []
        for constraint in constraints {
            superview?.removeConstraint(constraint)
        }
        
        frame.size = previewSize
        
        let snapshot = createSampleBufferFrom(pixelBuffer: buffer(from: asImage())!)!
        
        frame.size = size
        for constraint in constraints {
            superview?.addConstraint(constraint)
        }
        
        return snapshot
    }
}

@available(iOS 15.0, *)
extension Pipable {
    
    func asImage() -> UIImage {
        
        var offset: CGPoint?
        if let scrollView = self as? UIScrollView {
            offset = scrollView.contentOffset
            
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            
            if bottomOffset.y >= 0 {
                scrollView.contentOffset = bottomOffset
            }
        }
        
        let superview = self.superview
        let index = self.subviews.firstIndex(of: self)
        if window?.windowScene?.activationState == .background {
            removeFromSuperview()
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        let image = renderer.image {
            rendererContext in

            layer.render(in: rendererContext.cgContext)
        }
        
        if offset != nil {
            (self as? UIScrollView)?.contentOffset = offset!
        }
        
        if self.superview == nil {
            superview?.insertSubview(self, at: index ?? 0)
        }
        
        return image
    }
}
