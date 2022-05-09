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
    let byoopView: ByoopView
    
    init(byoopView: ByoopView) {
        self.byoopView = byoopView
        
        super.init(frame: .zero)

        addSubview(byoopView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func run() {
        self.byoopView.run(frame: self.bounds)
    }
}
