//
//  S_LoginBaseViewController.swift
//  Start
//
//  Created by cloud on 2023/4/27.
//

import Foundation

class S_LoginBaseViewController: BaseViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let touristButton = UIButton.init(frame: CGRect(x: kScreenWidth-16-56, y: kStatusBarHeight()+12, width: 56, height: 20))
        touristButton.titleLabel?.font = UIFont.regularFontOfSize(size: 14)
        touristButton.setTitle("游客模式", for: .normal)
        touristButton.setTitleColor(SubTextColor, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: touristButton)
        touristButton.addTarget(self, action: #selector(tourist), for: .touchUpInside)
        touristButton.isHidden = true


    }
    @objc func tourist(){
        self.navigationController?.popToRootViewController(animated: true)
    }

    
}
