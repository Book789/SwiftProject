//
//  ViewController.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/9.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("100".hash)
        print("100".hash)


        HttpManager.POST(path: "/user/login/pwd") { data, error in
            print(error?.localizedDescription)
        }
        
        HttpManager.download("https://cdn.ydj.fit/app-asset/iOS/1/1/49/49_1.0.zip", "49"+"_"+"1", "zip") { progress in
        } completedCallBack: { data, error in
            if error != nil {
                // 网络问题
                // 手机硬盘不足
                print("下载失败")

            }else {
                print("下载成功")
            }
        }

    }


}

