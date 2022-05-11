//
//  Parts.swift
//  demo
//
//  Created by Johan Halin on 9.5.2022.
//  Copyright © 2022 Dekadence. All rights reserved.
//

import Foundation
import UIKit

class IntroView : UIView, ByoopRunnable {
    let byoopViews: [ByoopView]

    init(
        maxRandom: Int,
        topGradients: [UIImage],
        bottomGradients: [UIImage]
    ) {
        var byoopViews = [ByoopView]()
        let maxViews = maxRandom * maxRandom

        for i in 0..<maxViews {
            let topGradient: UIImage
            let bottomGradient: UIImage
            
            if i % 2 == 0 {
                topGradient = topGradients[0]
                bottomGradient = bottomGradients[0]
            } else {
                topGradient = bottomGradients[0]
                bottomGradient = topGradients[0]
            }
            
            let view = ByoopView(
                frame: .zero,
                topGradient: topGradient,
                bottomGradient: bottomGradient
            )
            
            byoopViews.append(view)
        }
        
        self.byoopViews = byoopViews

        super.init(frame: .zero)
        
        for view in byoopViews {
            addSubview(view)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func run(frame: CGRect, columns: Int, rows: [Int]) {
        self.frame = frame
        
        let columnWidth = self.bounds.size.width / CGFloat(columns)
        var viewCounter = 0
        
        for columnIndex in 0..<columns {
            let rowCount = rows[columnIndex]
            let rowHeight = self.bounds.size.height / CGFloat(rowCount)
            
            for rowIndex in 0..<rowCount {
                let view = self.byoopViews[viewCounter]
                view.isHidden = false
                view.adjustFrames(frame: CGRect(
                    x: CGFloat(columnIndex) * columnWidth,
                    y: CGFloat(rowIndex) * rowHeight,
                    width: columnWidth,
                    height: rowHeight
                ))
                view.run()
                
                viewCounter += 1
            }
        }
        
        while viewCounter < self.byoopViews.count {
            self.byoopViews[viewCounter].isHidden = true
            viewCounter += 1
        }
    }
}
