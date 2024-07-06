//
//  SWRefreshGifHeader.swift
//  swiftBase
//
//  Created by Book on 2023/3/24.
//

import UIKit

class S_RefreshGifFooter: MJRefreshAutoGifFooter {

    
    override
    func prepare() {
        super.prepare()
        let imageArray:NSMutableArray = []
        
        for i in 0...24{
            let image = UIImage.init(named: "loading_000"+String(format:"%02ld", i))
            imageArray.add(image!)
        }
        self.setImages(imageArray as! [Any], for: MJRefreshState(rawValue: 3)!)

        self.setTitle("", for: MJRefreshState(rawValue: 1)!)

        self.isRefreshingTitleHidden = true
        
    }
}
