//
//  ByoopView.swift
//  demo
//
//  Created by Johan Halin on 8.5.2022.
//  Copyright © 2022 Dekadence. All rights reserved.
//

import UIKit
import CoreGraphics

class ByoopView: UIView {
    let topView = UIView(frame: .zero)
    let bottomView = UIView(frame: .zero)
    
    init(frame: CGRect, topGradient: UIImage, bottomGradient: UIImage) {
        super.init(frame: frame)
        
        let topGradientView = UIImageView(image: topGradient)
        topGradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.topView.addSubview(topGradientView)
        addSubview(self.topView)
        
        let bottomGradientView = UIImageView(image: bottomGradient)
        bottomGradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.bottomView.addSubview(bottomGradientView)
        addSubview(self.bottomView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("peepee")
    }
    
    func adjustFrames(frame: CGRect) {
        self.frame = frame
        
        self.topView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0)
        self.bottomView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
    
    func run() {
        let duration = 0.875
        
        UIView.animate(withDuration: duration / 2.0, delay: 0, options: [.curveEaseOut], animations: {
            self.topView.frame.size.height = self.bounds.size.height
            self.bottomView.frame.origin.y = self.bounds.size.height
            self.bottomView.frame.size.height = 0
        }, completion: { _ in
            UIView.animate(withDuration: duration / 2.0, delay: 0, options: [.curveEaseIn], animations: {
                self.topView.frame.size.height = 0
                self.bottomView.frame.origin.y = 0
                self.bottomView.frame.size.height = self.bounds.size.height
            }, completion: nil)
        })
    }
}
