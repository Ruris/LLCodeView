//
//  LLTextStorage.swift
//  LLCodeView
//
//  Created by ZHK on 2020/12/15.
//  
//

import UIKit

class LLTextStorage: NSTextStorage {
    
    var stroage = NSMutableAttributedString(string: "")

    public var fontSize: CGFloat = 17.0
    
    var keywords: [LLKeyword] = []

    override var string: String {
        return stroage.string
    }
    
    func applyStypesToRange(searchRange: NSRange) {
        let lowercasedString = string.lowercased()
        for keyword in keywords {
            
            keyword.regular?.enumerateMatches(in: lowercasedString, options: [], range: searchRange, using: { (match, flags, stop) in
                guard let numberOfRanges = match?.numberOfRanges else { return }
                for idx in 0..<numberOfRanges {
                    guard let matchRange = match?.range(at: idx) else { return }

                    print(matchRange)
                    self.setAttributes([
                        NSAttributedString.Key.foregroundColor : keyword.color
                    ], range: matchRange)
                }
            })
        }
    }
    
    override func processEditing() {
        super.processEditing()
        if editedMask.contains(.editedCharacters) {
            let string = (self.string as NSString)
            let range = string.paragraphRange(for: editedRange)
            applyStypesToRange(searchRange: range)
        }
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        stroage.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        stroage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }
    
    override func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        beginEditing()
        stroage.replaceCharacters(in: range, with: attrString)
        edited(.editedCharacters, range: range, changeInLength: attrString.length - range.length)
        endEditing()
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        stroage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}
