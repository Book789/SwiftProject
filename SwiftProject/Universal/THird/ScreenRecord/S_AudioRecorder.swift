//
//  S_AudioRecord.swift
//  1111
//
//  Created by cloud on 2023/7/28.
//

import UIKit
import AVFoundation

class S_AudioRecorder: NSObject {

    private var audioRecorder: AVAudioRecorder?
    
        
    lazy var audioFilename:URL = {
        
        let fileManager = FileManager.default
        let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory:NSURL = urlString.first! as NSURL
        
        let videoOutURLString:URL = documentDirectory.appendingPathComponent("recording.wav")! as URL
        if(fileManager.fileExists(atPath: videoOutURLString.path)){
            do{
                try fileManager.removeItem(at: videoOutURLString as URL)
            }catch{
                print("unable to delete file")
            }
        }
        return videoOutURLString
    }()

    
    override init() {
        super.init()
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        if permissionStatus == AVAudioSession.RecordPermission.undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                print(granted)
                if(granted){
                    self.setAudioSetting()
                }
            }
        } else if permissionStatus == AVAudioSession.RecordPermission.granted{
            self.setAudioSetting()
           print("开启权限")
        }else{
            print("未开启权限")
        }
       

       

    }
    
    func setAudioSetting(){
        // MARK: 2-一些配置
        let recordSettings:[String:Any] = [AVFormatIDKey:kAudioFormatLinearPCM,
                                 AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue,
                                 AVEncoderBitRateKey:96000,
                                 AVNumberOfChannelsKey:1,
                                 AVSampleRateKey:44100.0 ] as [String : Any]


        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSettings)
            audioRecorder?.isMeteringEnabled = true // Monitor sound wave
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()

        } catch {
            print(error)
        }
    }
    
    func startRecorder(){
        // MARK: 开始录音
        audioRecorder?.record()
    }
    func pauseRecorder(){
        // MARK: 暂停录音
        audioRecorder?.pause()
    }
    func resumeRecorder(){
        // MARK: 继续录音
        audioRecorder?.record()
    }
    func stopRecorder(){
        // MARK: 结束录音
        audioRecorder?.stop()
    }
    func deleteRecorder(){
        // MARK:  删除录音
        audioRecorder?.deleteRecording()
    }


}
extension S_AudioRecorder: AVAudioRecorderDelegate {
    
}
