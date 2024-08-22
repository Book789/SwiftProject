//
//  S_EmptyView.swift
//  Start
//
//  Created by Book on 2023/4/21.
//

import UIKit


enum SEmptyViewState{
    case SEmptyViewStateHidden            //隐藏
    case SHEmptyViewStateLoading                //加载中
    case SEmptyViewStateRetry      //点击重试
    case SEmptyViewStateNoResult        //无数据
    case SEmptyViewStateNoCourse        //无课程

}

public typealias RetryComplete = ()->Void

class S_EmptyView: UIView {
    
    var retryBlock:RetryComplete?
    
    lazy var noResultView = {
        let resultView = UIView.init(frame: CGRectMake(0, 0, self.width, 100))
        return
    }()
    
    var placeholderImageView:UIImageView!
    
    var placeholderLabel:UILabel!

    var retryButton:UIButton!

    var loadingImageView:UIImageView!

//    var _state:SEmptyViewState!
    
    var state:SEmptyViewState?{

        didSet{
            self.placeholderLabel.textColor = SubTextColor
            self.placeholderLabel.font = UIFont.regularFontOfSize(size: 14)

            switch state{
            case .SEmptyViewStateHidden:
                self.superview?.insertSubview(self, at: 0)
                self.placeholderImageView.isHidden = true
                self.placeholderLabel.isHidden = true
                self.retryButton.isHidden = true
                self.loadingImageView.isHidden = true
                break
            case .SHEmptyViewStateLoading:
                self.superview?.bringSubviewToFront(self)
                self.placeholderImageView.isHidden = true
                self.placeholderLabel.isHidden = true
                self.retryButton.isHidden = true
                self.loadingImageView.isHidden = false
                
            case .SEmptyViewStateRetry:
                self.placeholderImageView.isHidden = false
                self.placeholderImageView.image = UIImage.init(named: "no_network")
                self.placeholderLabel.isHidden = false
                self.placeholderLabel.text = "没有网络了～"
                self.placeholderLabel.textColor = SubTextColor
                self.placeholderLabel.font = UIFont.mediumFontOfSize(size: 16)
                self.retryButton.isHidden = true
                self.loadingImageView.isHidden = true
                break
                
                
            case .SEmptyViewStateNoResult:
                self.placeholderImageView.isHidden = false
                self.placeholderLabel.isHidden = false
                self.placeholderImageView.image = UIImage.init(named: "no_data")
                self.placeholderLabel.text = "暂时没有数据哦~"
                self.placeholderImageView.bottom = self.superview!.height/2
                self.placeholderLabel.top = self.placeholderImageView.bottom
                break
            case .SEmptyViewStateNoCourse:
                self.placeholderImageView.isHidden = false
                self.placeholderLabel.isHidden = false
                self.placeholderImageView.image = UIImage.init(named: "no_course")
                self.placeholderLabel.text = "暂无课程~"
                self.placeholderImageView.bottom = self.superview!.height/2
                self.placeholderLabel.top = self.placeholderImageView.bottom
                break
            case .none:
                break
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        self.placeholderImageView = UIImageView.init(frame: CGRect(x: kScreenWidth/2-100, y: kScreenHeight/2-200, width: 200, height: 200))
        self.addSubview(self.placeholderImageView)
        self.placeholderImageView.isHidden = true
        
        self.placeholderLabel = UILabel.init(frame: CGRect(x: 0, y: self.placeholderImageView.bottom, width: kScreenWidth, height: 16))
        self.placeholderLabel.textColor = SubTextColor
        self.placeholderLabel.textAlignment = .center
        self.placeholderLabel.font = UIFont.regularFontOfSize(size: 14)
        self.addSubview(placeholderLabel)
        
        self.retryButton = UIButton(type: .custom)
        self.retryButton.frame = CGRect(x: self.width/2-50, y: self.placeholderLabel.bottom+24, width: 100, height: 44)
        self.retryButton.backgroundColor = UIColor.init(patternImage: UIImage.createImageWithSize(imageSize: self.retryButton.size, colorsArray: [kColorWithHex(0x2F63F8),kColorWithHex(0xE30B9A)]))
        self.retryButton.layer.cornerRadius = 22
        self.retryButton.clipsToBounds = true
        self.retryButton.setTitle("重试", for: .normal)
        self.retryButton.titleLabel?.font = UIFont.regularFontOfSize(size: 14)
        self.addSubview(retryButton)
        self.retryButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
        
        loadingImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 121, height: 90))
        loadingImageView.isUserInteractionEnabled = true
        self.addSubview(loadingImageView)
        let loadingImageArray:NSMutableArray = []
        for i in 0...24{
            let image = UIImage.init(named: "loading_000"+String(format:"%02ld", i))
            loadingImageArray.add(image!)
        }
        loadingImageView.animationImages = loadingImageArray as? [UIImage];
        loadingImageView.animationDuration = 24 * 0.05;
        loadingImageView.startAnimating()
        loadingImageView.center = self.center;

        
        
    }
    @objc func retry(){
        if((self.retryBlock) != nil){
            self.retryBlock!()
        }
    }
    
    class func addToView(view:UIView,show:Bool)->S_EmptyView{
        
        let emptyView = S_EmptyView.init(frame: view.bounds)
        view.addSubview(emptyView)
        
        if(show){
            emptyView.show()
        }else{
            emptyView.hidden()
        }
        
        return emptyView
    }
    
    func show(){
        self.state = .SHEmptyViewStateLoading
    }
    func hidden(){
        self.state = .SEmptyViewStateHidden

    }
    
 
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview!.endEditing(true)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

}
