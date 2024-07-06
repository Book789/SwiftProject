//
//  CustomTextField.swift
//  Start
//
//  Created by Book on 2023/4/21.
//

import Foundation

class CustomTextField: UITextField {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        
        var originalRect = super.caretRect(for: position)
        originalRect.origin.y = 10
        originalRect.size.height = self.font!.lineHeight
        originalRect.size.width = 1
        
        return originalRect
    }
    
}
