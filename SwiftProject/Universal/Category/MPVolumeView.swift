//
//  MPVolumeView.swift
//  SwiftProject
//
//  Created by cloud on 2024/7/13.
//

import UIKit

extension MPVolumeView{
    
    /**
     *  修改设备系统声音 会显示 系统的音量进度条
     */
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 100, height: 100))
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            slider?.setValue(volume, animated: true)
            slider?.sendActions(for: .touchUpInside)
        }
    }
    
//    let volumeView = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 100, height: 100))
//    self.view.addSubview(volumeView) // 不会显示 系统的音量进度条 此时系统声音按键也不会显示
//    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
//    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//        slider?.setValue(0.9, animated: true)
//        slider?.sendActions(for: .touchUpInside)
//    }

}
