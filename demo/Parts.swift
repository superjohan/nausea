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
    let byoopViews: [[ByoopView]]

    init(
        columns: Int,
        rows: [Int],
        topGradients: [UIImage],
        bottomGradients: [UIImage]
    ) {
        var viewColumns = [[ByoopView]]()
        var count = 0
        
        for column in 0..<columns {
            let rowCount = rows[column]
            var viewRows = [ByoopView]()

            for _ in 0..<rowCount {
                let topGradient: UIImage
                let bottomGradient: UIImage
                
                if count % 2 == 0 {
                    topGradient = topGradients[Int.random(in: 0..<(topGradients.count))]
                    bottomGradient = bottomGradients[Int.random(in: 0..<(bottomGradients.count))]
                } else {
                    topGradient = bottomGradients[Int.random(in: 0..<(bottomGradients.count))]
                    bottomGradient = topGradients[Int.random(in: 0..<(topGradients.count))]
                }
                
                let view = ByoopView(
                    frame: .zero,
                    topGradient: topGradient,
                    bottomGradient: bottomGradient
                )
                
                viewRows.append(view)
                
                count += 1 // TODO: figure something out for the gradients
            }
            
            viewColumns.append(viewRows)
        }
        
        self.byoopViews = viewColumns
        
        super.init(frame: .zero)
        
        for column in viewColumns {
            for view in column {
                addSubview(view)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func run() {
        let columnWidth = self.bounds.size.width / CGFloat(self.byoopViews.count)
        
        for (columnIndex, column) in self.byoopViews.enumerated() {
            let rowHeight = self.bounds.size.height / CGFloat(column.count)
            
            for (rowIndex, view) in column.enumerated() {
                view.run(frame: CGRect(
                    x: CGFloat(columnIndex) * columnWidth,
                    y: CGFloat(rowIndex) * rowHeight,
                    width: columnWidth,
                    height: rowHeight
                ))
            }
        }
    }
}
