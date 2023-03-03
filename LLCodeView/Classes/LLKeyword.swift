//
//  LLKeyword.swift
//  LLCodeView
//
//  Created by ZHK on 2020/12/18.
//  
//

import UIKit


class LLKeyword {
    
    lazy var regular = try? NSRegularExpression(pattern: regx, options: [])
    
    /// 正则表达式
    let regx: String
    
    let color: UIColor
    
    init(regx: String, color: UIColor) {
        self.regx = regx.lowercased()
        self.color = color
    }
}
