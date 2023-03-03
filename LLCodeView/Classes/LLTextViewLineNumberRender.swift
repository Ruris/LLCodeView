//
//  LLTextViewLineNumberRender.swift
//  LLCodeView
//
//  Created by ZHK on 2020/12/21.
//  
//

import UIKit

class LLTextViewLineNumberRender: NSObject {
    
    private let textView: UITextView
    
    private var layoutManager: NSLayoutManager { textView.layoutManager }
    
    private var textContainer: NSTextContainer { textView.textContainer }
    
    private var safeAreaInsets: UIEdgeInsets { textView.safeAreaInsets }
    
    private var contentInset: UIEdgeInsets { textView.contentInset }
    
    private var textContainerInset: UIEdgeInsets { textView.textContainerInset }
    
    private var contentOffset: CGPoint { textView.contentOffset }
    
    private var visibleSize: CGSize { textView.visibleSize }
    
    private var text: String { textView.text }
    
    private var lineNumberAttributes: [NSAttributedString.Key : Any] {
        [
            NSAttributedString.Key.font: textView.font ?? UIFont.systemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
    }
    
    init(textView: UITextView) {
        self.textView = textView
        super.init()
    }
    
    public func render() {
        drawHashMarksAndLabels()
    }
    
    /// 绘制行号
    private func drawHashMarksAndLabels() {
        /// 左上角相对 textView 坐标系的 相对坐标
        let relativePoint = CGPoint(x: contentInset.left, y: textContainerInset.top + contentInset.top)
        
        let visibleRect = CGRect(x: 0, y: contentOffset.y, width: visibleSize.width, height: visibleSize.height)
        /// 窗口可视区域内的文本范围
        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)

        /// 窗口可视区域首个字符在文本中的索引
        let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
        
        /// 换行符正则
        let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
        
        // The line number for the first visible line
        /// 可视区域首行的行号
        /// 获取可视区域内首个字符以前有多少个换行符, 就有多少行
        /// 行号从 1 开始, 因此结果 + 1
        var lineNumber = newLineRegex.numberOfMatches(in: text, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1
        
        /// 窗口可视区域内第一个 字符 在 文本 中的下标
        var glyphIndexForStringLine = visibleGlyphRange.location
        
        // Go through each line in the string.
        /// 遍历可视区域内的每行 (段落)
        /// 看似是逐字遍历, 实际上内部对 glyphIndexForStringLine 进行了操作, 部分循环被直接跳过了
        while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
            // Range of current line in the string.
            /// 计算每行第一个字符在全部文本中的索引
            let index = layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine)
            /// 通过索引计算当前 字符 所在的 行(段落) 的全部字符在全文中的 范围
            let characterRangeForStringLine = (text as NSString).lineRange(
                for: NSMakeRange(index, 0 )
            )

            /// 通过字符范围计算生成的字形的范围 (因为多个字符可能会合并成一个字形)
            let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)
            
            var glyphIndexForGlyphLine = glyphIndexForStringLine
            
            /// 段落(字符的行) 内 渲染之后的 行 (因为换行生成的视觉上的行)
            /// 段落内的行号
            var glyphLineCount = 0
            
            /// 遍历段落内的每一行
            /// 看似是逐字形遍历, 实际上内部同样对 glyphIndexForGlyphLine 做了处理, 大部分循环都被跳过了
            while glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) {
                
                // See if the current line in the string spread across
                // several lines of glyphs
                var effectiveRange = NSMakeRange(0, 0)
                
                // Range of current "line of glyphs". If a line is wrapped,
                // then it will have more than one "line of glyphs"
                /// 当前段落内的行的文本在段落内的范围 (因为换行的原因, 一段文字会有多行)
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                
                /// 段落内首行绘制段落索引数字
                /// 段落内其他行绘制空字符 (或者不进行处理)
                if glyphLineCount > 0 {
//                    drawLineNumber(lNum: "", y: lineRect.minY + relativePoint.y)
                } else {
                    drawLineNumber(lNum: "\(lineNumber)", y: lineRect.minY + relativePoint.y)
                }
                
                // Move to next glyph line
                /// 移动到下一行 (段落内的行)
                glyphLineCount += 1
                /// 索引跳转到下一行的行首文本索引
                glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
            }
            
            /// 跳转到下一行 (段落) 的首字符
            glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
            /// 行号递增
            lineNumber += 1
        }
        
        // Draw line number for the extra line at the end of the text
        /// 最末行行号
        if layoutManager.extraLineFragmentTextContainer != nil {
            drawLineNumber(lNum: "\(lineNumber)", y: layoutManager.extraLineFragmentRect.minY + relativePoint.y)
        }
    }
    
    /// 绘制行标
    /// - Parameters:
    ///   - lNum:  行号
    ///   - attrs: 行标文本属性
    ///   - y:     绘制坐标
    private func drawLineNumber(lNum: String, y: CGFloat) {
        let attString = NSAttributedString(string: lNum, attributes: lineNumberAttributes)
        /// self.width = 40.0
        /// 35.0 - 文本宽度就是绘制的 x 轴坐标
        let x = 35.0 - attString.size().width + safeAreaInsets.left
        /// 绘制
        attString.draw(at: CGPoint(x: x, y: y))
    }
}

