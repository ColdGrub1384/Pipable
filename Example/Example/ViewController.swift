//
//  ViewController.swift
//  Example
//
//  Created by Emma on 16-11-21.
//

import UIKit
import Pipable
import AVKit

// Conform to `Pipable`

class PipableTextView: UITextView, Pipable {
    
    var pictureInPictureDelegate: PictureInPictureDelegate?
    
    var previewSize: CGSize {
        CGSize(width: 512, height: 512) // More readable
    }
}

class ViewController: UIViewController, PictureInPictureDelegate {

    @IBOutlet weak var textView: PipableTextView!
    
    @IBOutlet weak var pipBarButtonItem: UIBarButtonItem!
    
    @IBAction func togglePIP(_ sender: Any) {
        
        guard #available(iOS 15.0, *) else {
            return
        }
        
        if textView.pictureInPictureController?.isPictureInPictureActive == false {
            
            // Start an audio session and PIP
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true, options: [])
            } catch {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.textView.pictureInPictureController?.startPictureInPicture()
            }
        } else {
            
            // Stop PIP
            
            textView.pictureInPictureController?.stopPictureInPicture()
        }
    }
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pipBarButtonItem.isEnabled = AVPictureInPictureController.isPictureInPictureSupported()
        
        textView.pictureInPictureDelegate = self // Set the PIP delegate
        
        var i = 0
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            self.textView.text += "\(i)\n"
            if #available(iOS 15.0, *) {
                self.textView.updatePictureInPictureSnapshot()
            }
            i += 1
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 15.0, *) {
            textView.updatePictureInPictureSnapshot() // Update the snapshot
        }
    }

    // MARK: - Picture in Picture delegate
    
    func didExitPictureInPicture() {
        pipBarButtonItem.image = UIImage(systemName: "pip.enter")
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func didEnterPictureInPicture() {
        pipBarButtonItem.image = UIImage(systemName: "pip.exit")
    }
    
    func didFailToEnterPictureInPicture(error: Error) {
        print(error.localizedDescription)
    }
}

