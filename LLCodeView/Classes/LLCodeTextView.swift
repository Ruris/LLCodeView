//
//  LLCodeTextView.swift
//  LLCodeView
//
//  Created by ZHK on 2020/12/15.
//  
//

import UIKit
import Highlightr

open class LLCodeTextView: UITextView {
    
    lazy private var lineNumberRender = LLTextViewLineNumberRender(textView: self)

    public init(font: UIFont) {
        
        let textContainer = NSTextContainer()
        let layoutManager = NSLayoutManager()

        #if false
        let textStorage = LLTextStorage()
        textStorage.keywords = [
            LLKeyword(regx: "int", color: UIColor.red)
        ]
        #else
        
        let highlightr = Highlightr()!
        highlightr.setTheme(to: "xcode")
        highlightr.theme.themeBackgroundColor = .black
        highlightr.theme.codeFont = RPFont(name: font.familyName, size: font.pointSize)
        let textStorage = CodeAttributedString(highlightr: highlightr)
        textStorage.language = "swift"

        #endif
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        super.init(frame: CGRect.zero, textContainer: textContainer)
        delegate = self
        self.font = font
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        var inset = safeAreaInsets
        inset.left += 50.0
        inset.top = 10.0
        inset.bottom = 10.0
        textContainerInset = inset
        
        textContainer.size = CGSize(width: bounds.size.width, height: 10000)
    }
    
    open override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UIColor.gray.cgColor)
        context?.move(to: CGPoint(x: 45.0 + safeAreaInsets.left, y: 0.0))
        context?.addLine(to: CGPoint(x: 45.0 + safeAreaInsets.left, y: rect.origin.y + rect.height))
        context?.strokePath()

        lineNumberRender.render()
    }
}


extension LLCodeTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        setNeedsDisplay(bounds)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsDisplay(bounds)
    }
}
