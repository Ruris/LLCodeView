//
//  ViewController.swift
//  LLCodeView
//
//  Created by Ruris on 03/03/2023.
//  Copyright (c) 2023 Ruris. All rights reserved.
//

import UIKit
import LLCodeView

class ViewController: UIViewController {

    private let textView = LLCodeTextView(font: .systemFont(ofSize: 20), lang: "swift", theme: "Hopscotch")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        
        textView.text = "int a = 15;"
        textView.isEditable = true
//        textView.font = .systemFont(ofSize: 38.0)
//        textView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            print(self.textView.visibleSize, self.textView.bounds.size)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textView.frame = view.bounds
    }
}

