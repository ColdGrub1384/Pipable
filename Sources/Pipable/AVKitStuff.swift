//
//  AVKitStuff.swift
//  
//
//  Created by Emma on 16-11-21.
//

import AVKit
import UIKit

// From https://gist.github.com/jknthn/d8e197c036bb4b1c7c11b040a35580a7
func buffer(from image: UIImage) -> CVPixelBuffer? {
    let dict: CFDictionary = [
        kCVPixelBufferIOSurfaceOpenGLESFBOCompatibilityKey : kCFBooleanTrue,
        kCVPixelBufferIOSurfaceOpenGLESTextureCompatibilityKey: kCFBooleanTrue
    ] as CFDictionary
    let attrs = [
         kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
         kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any,
         kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue as Any,
         kCVPixelBufferOpenGLCompatibilityKey: kCFBooleanTrue as Any,
         kCVPixelBufferIOSurfaceOpenGLESTextureCompatibilityKey: kCFBooleanTrue as Any,
         kCVPixelBufferIOSurfacePropertiesKey: dict
    ] as CFDictionary
  var pixelBuffer : CVPixelBuffer?
  let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
  guard (status == kCVReturnSuccess) else {
    return nil
  }

  CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

  context?.translateBy(x: 0, y: image.size.height)
  context?.scaleBy(x: 1.0, y: -1.0)

  UIGraphicsPushContext(context!)
  image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
  UIGraphicsPopContext()
  CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

  return pixelBuffer
}

// https://gist.github.com/rampadc/79c01eb3fa4eba0b941befa7c55f4e13
func createSampleBufferFrom(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
    var sampleBuffer: CMSampleBuffer?
    
    let scale = CMTimeScale(NSEC_PER_SEC)
    
    var timingInfo = CMSampleTimingInfo()
    timingInfo.presentationTimeStamp = .init(value: 0, timescale: scale)
    timingInfo.duration = CMTime(seconds: 10, preferredTimescale: scale)
    timingInfo.decodeTimeStamp = .init(value: 0, timescale: scale)
    var formatDescription: CMFormatDescription? = nil
    CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
    
    _ = CMSampleBufferCreateReadyWithImageBuffer(
      allocator: kCFAllocatorDefault,
      imageBuffer: pixelBuffer,
      formatDescription: formatDescription!,
      sampleTiming: &timingInfo,
      sampleBufferOut: &sampleBuffer
    )
    
    guard let buffer = sampleBuffer else {
      print("Cannot create sample buffer")
      return nil
    }
        
    return buffer
  }
