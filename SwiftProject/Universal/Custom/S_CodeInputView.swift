//
//  S_CodeInputView.swift
//  Start
//
//  Created by Book on 2023/4/22.
//

import UIKit
import SnapKit

typealias CodeResultBlock = (_ code: String) -> Void

class S_CodeInputView: UIView, UITextViewDelegate {

    
    var textView:UITextView!
    
    
    var labelsArray:NSMutableArray = []
    
    var codeResultBlock:CodeResultBlock!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        let  ml:CGFloat = (kScreenWidth-Ratio(40)*6-Ratio(12)*5)/2;
        
        textView = UITextView.init(frame: CGRect(x: ml, y: 0, width: kScreenWidth-ml*2, height: frame.height))
        textView.tintColor = UIColor.clear
        textView.backgroundColor = UIColor.clear
        textView.delegate = self
        textView.keyboardType = .numberPad
        self.addSubview(textView)
        textView.becomeFirstResponder()
        

        var  tempNumberLabel:UILabel!

        for i in 0...5{
            
            let numberLabel = UILabel.init(frame: CGRectZero)
            numberLabel.backgroundColor = UIColor.white
            numberLabel.textColor = MainTextColor
            numberLabel.font = UIFont.semiboldFontOfSize(size: 16)
            self.addSubview(numberLabel)
            

            if(i==0){
                numberLabel.snp.makeConstraints { make in
                    make.top.equalTo(self)
                    make.left.equalTo(self.snp.left).offset(ml)
                    make.size.equalTo(CGSize(width:Ratio(40) , height: Ratio(40)))
                }
                
            }else{
                numberLabel.snp.makeConstraints { make in
                    make.top.equalTo(self)
                    make.left.equalTo(tempNumberLabel.snp.right).offset(Ratio(12))
                    make.size.equalTo(CGSize(width:Ratio(40) , height: Ratio(40)))
                }
                
            }
            tempNumberLabel = numberLabel
            
            numberLabel.layer.cornerRadius = 4
            numberLabel.layer.borderWidth = 1
            numberLabel.layer.borderColor = BlueTextColor.cgColor
            numberLabel.clipsToBounds = true
            numberLabel.isUserInteractionEnabled = false
            numberLabel.textAlignment = .center

            labelsArray.add(numberLabel)
        }

    }
    
    /*
     // MARK: - UITextViewDelegate
     */
    func textViewDidChange(_ textView: UITextView){
        
        let string = textView.text
        
        if(string!.count >= 6){
            textView.text = textView.text.substring(to: 5)
            textView.resignFirstResponder()
        }
        
        
        for i in 0...5{
        
            let label:UILabel = labelsArray[i] as! UILabel
            if(i<string!.count){
                label.text = string?.substring(from: i, length: 1)
            }else{
                label.text = ""
            }
        }
        
        self.codeResultBlock(string!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
