//
//  String+AttributedString.swift
//  Start
//
//  Created by cloud on 2025/8/12.
//
import Foundation


extension String {
    
    static func attributeString(string:String,attrs:[NSAttributedString.Key : Any],rangeStringArray:Array<String>) -> NSMutableAttributedString{
        let tipStr =  string
        let attr = NSMutableAttributedString.init(string: tipStr)
        for rangeString in rangeStringArray {
            let ranges = String.findAllRanges(of: rangeString, in: tipStr)
            for rangeLocale in ranges{
                let range = NSRange(rangeLocale, in: tipStr)
                attr.addAttributes(attrs, range: range)
            }
        }
        return attr
    }
    static func findAllRanges(of substring: String, in string: String) -> [Range<String.Index>] {
        var ranges:[Range<String.Index>] = Array()
        var currentIndex = string.startIndex
        while let range = string.range(of: substring,
                                     range: currentIndex..<string.endIndex) {
            ranges.append(range)
            currentIndex = range.upperBound
        }
        return ranges
    }


}
