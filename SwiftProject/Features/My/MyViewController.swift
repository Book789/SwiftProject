//
//  MyViewController.swift
//  SwiftProject
//
//  Created by cloud on 2024/12/23.
//
import UIKit
import CoreMedia
import MetalKit
import Vision

extension MyViewController:PoseDetectionManagerDelegate{
    func poseDetectionManager(_ manager: MediaPipePoseDetector, didDetectPoses poses: [Pose]) {
//        self.drawingView.poses = poses
//        self.drawingView.setNeedsDisplay()
    }

    func poseDetectionManager(_ manager: MediaPipePoseDetector, didFailWithError error: any Error) {

    }


}

class MyViewController: BaseViewController {

    var videoCapture:S_VideoCapture?
    var metalView:S_MetalView!
    var screenRecorder:S_ScreenRecorder?

    var poseDetector:MediaPipePoseDetector = MediaPipePoseDetector()

    var drawingView:PoseDrawingView!

    var detector:ObjectDetector =  ObjectDetector()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.poseDetector.delegate = self

        self.screenRecorder = S_ScreenRecorder.init()
        self.screenRecorder?.isLandscape = false

        // Do any additional setup after loading the view.
        self.metalView = S_MetalView(frame: self.view.bounds)
        self.metalView.fillMode = .fill
        self.view.addSubview(self.metalView)

        self.drawingView = PoseDrawingView(frame: self.view.bounds)
        self.view.addSubview(self.drawingView)

        self.videoCapture = S_VideoCapture()
        self.videoCapture?.sampleBufferOutputCallBack = { [weak self] sampleBuffer in
            guard let imageBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
                return
            }
            //            let image = self?.sampleBufferToImage(sampleBuffer: sampleBuffer)
            //            DispatchQueue.main.async {
            //                self?.metalView.image = image
            //            }
            //
            self?.metalView.renderPixelBuffer(imageBuffer)

//            let visionRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer)
//            self?.detector.predictUsingVision(handler: visionRequestHandler)
//
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let currentTimestamp = Int(timestamp.seconds * 1000)
            self?.poseDetector.detectAsync(pixelBuffer: imageBuffer, timestampInMilliseconds: currentTimestamp)
//
            let durationTime = CMSampleBufferGetDuration(sampleBuffer)
            self?.screenRecorder?.recording(pixelBuffer: imageBuffer, time: timestamp,durationTime: durationTime)

        }
        self.videoCapture?.startCaptureSession()

        self.screenRecorder?.startRecording()

//        let fileManager = FileManager.default
//        let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory:NSURL = urlString.first! as NSURL
//
//        let outputURL:URL = documentDirectory.appendingPathComponent("ScreenRecord.mp4")! as URL
//

//        self.perform(#selector(stop), with: nil, afterDelay: 30)

    }
    @objc func stop() {
        self.videoCapture?.stopCaptureSession()

        self.screenRecorder?.stopRecording { url in

            DispatchQueue.main.async {
                // 在这里放置需要在主线程上执行的代码
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // 对于iPad很重要，确保popover出现在正确的位置
                self.present(activityViewController, animated: true, completion: nil)

            }


        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MyViewController {
    // CMSampleBuffer -> UIImage
    func sampleBufferToImage(sampleBuffer: CMSampleBuffer) -> UIImage {
        // 获取CMSampleBuffer的核心视频图像缓冲的媒体数据
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer

        // 锁定像素缓冲区的基址
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        // 获取像素缓冲区的每行字节数
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)

        // 获取像素缓冲区的每行字节数
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        // 获取像素缓冲的宽度和高度
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        // 创建一个设备相关的RGB颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // 使用示例缓冲区数据创建位图图形上下文
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        context?.scaleBy(x: 1.0, y: -1.0)
        // 根据位图图形上下文中的像素数据创建一个Quartz图像
        let quartzImage:CGImage = context!.makeImage()!
        // 解锁像素缓冲区
        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0))

        let image = UIImage(cgImage: quartzImage)
        return image
    }

}
