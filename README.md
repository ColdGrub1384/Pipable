# Pipable

Pipable is an iOS library to implement Picture in Picture for any `UIView`. This is done just by conforming to a protocol.

The "Audio, AirPlay and Picture in Picture" background mode must be enabled and an audio session must be active for PIP to work.

**Updating the PIP snapshot in background, which is the whole point of PIP, doesn't work for the moment because I can't take a snapshot of a view in background if it's inside a window. But I am able to take a snapshot of a view that's not inside a window, so it shouldn't be that hard to make it work. But it's almost 5 am here so I'll try later :)**

Requires iOS / iPadOS 15+.

![screenshot](screenshot.jpeg)

## Usage

Create a `UIView` that conforms to `Pipable`. Start an audio session and then use the `pictureInPictureController` object automatically provided by the `Pipable` protocol to start PIP.

```swift
import Pipable
import UIKit
import AVKit

class MyTextView: UITextView, Pipable {

    var pictureInPictureDelegate: PictureInPictureDelegate?
    
    var previewSize: CGSize {
        CGSize(width: 512, height: 512)
    }
}

let textView = MyTextView()
textView.text = "Hello World!"

// Update the snapshot (do this everytime the text is changed)

textView.updatePictureInPictureSnapshot()

// Start an audio session

do {
    try AVAudioSession.sharedInstance().setCategory(.playback)
    try AVAudioSession.sharedInstance().setActive(true, options: [])
} catch {
    print(error.localizedDescription)
}

// Start PIP

textView.pictureInPictureController?.startPictureInPicture()
```
