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
    }


}

