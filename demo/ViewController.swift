//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import Foundation

class ViewController: UIViewController {
    let autostart = true
    let eventCount = 64
    
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let contentView = UIView(frame: .zero)
    let nauseaView = UIImageView(image: UIImage(named: "nausea2"))
    let topGradients: [Gradient]
    let bottomGradients: [Gradient]

    var partViews = [ByoopRunnable]()
    var currentView: ByoopRunnable?

    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "audio", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else { abort() }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        let startButtonText =
            "\"byoop\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming and music by ricky martin\n" +
                "\n" +
                "please make this window full screen.\n" +
                "warning: this demo may be a little disorienting\n" +
                "\n" +
                "presented at jumalauta färjan mega winter party 2022\n" +
                "\n" +
        "click anywhere to start"
        self.startButton = UIButton.init(type: UIButton.ButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControl.State.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.titleLabel?.font = .systemFont(ofSize: 24)
        self.startButton.backgroundColor = UIColor.black
        
        var topGradients = [Gradient]()
        var bottomGradients = [Gradient]()
        
        for i in 0..<(self.eventCount + 1) {
            let bottom = Double(i) / Double(self.eventCount)
            let top = 1.0 - bottom
            
            topGradients.append(
                Gradient(
                    topColor: UIColor(white: top, alpha: 1.0),
                    bottomColor: UIColor(white: top, alpha: 1.0)
                )
            )

            bottomGradients.append(
                Gradient(
                    topColor: UIColor(white: bottom, alpha: 1.0),
                    bottomColor: UIColor(white: bottom, alpha: 1.0)
                )
            )
        }
        
        self.topGradients = topGradients
        self.bottomGradients = bottomGradients
        
        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)

        self.contentView.isHidden = true
        
        self.view.addSubview(self.contentView)
        
        if !self.autostart {
            self.view.addSubview(self.startButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer.prepareToPlay()
//        self.audioPlayer.volume = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

        self.contentView.frame = self.view.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.backgroundColor = .black

        self.startButton.frame = self.contentView.frame
        self.startButton.autoresizingMask = self.contentView.autoresizingMask

        for i in 0..<self.eventCount {
            self.partViews.append(
                IntroView(byoopView: ByoopView(
                    frame: .zero,
                    topGradient: gradientImage(
                        topColor: self.topGradients[i].topColor,
                        bottomColor: self.topGradients[i + 1].topColor
                    ),
                    bottomGradient: gradientImage(
                        topColor: self.bottomGradients[i].topColor,
                        bottomColor: self.bottomGradients[i + 1].bottomColor
                    )
                ))
            )
        }
        
        for view in self.partViews {
            view.isHidden = true
            self.contentView.addSubview(view)
        }
     
        self.nauseaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.nauseaView.frame = self.contentView.bounds
        self.nauseaView.layer.compositingFilter = "differenceBlendMode"
        self.nauseaView.isHidden = true
        self.contentView.addSubview(self.nauseaView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.autostart {
            start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - Private
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
        self.audioPlayer.play()
        
        self.startButton.isHidden = true
        self.contentView.isHidden = false
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        for position in 0...(self.eventCount + 2) {
            perform(#selector(event), with: NSNumber(value: position), afterDelay: TimeInterval(position))
        }
    }
    
    @objc private func event(pos: NSNumber) {
        let position = pos.intValue
        
        self.currentView?.isHidden = true
        
        if position < self.eventCount {
            let runnable = self.partViews[position]
            runnable.isHidden = false
            runnable.frame = self.view.bounds
            runnable.run()
        
            self.currentView = runnable
        }

        if position == 2 {
            self.nauseaView.isHidden = false
        } else if position == 64 {
            self.currentView?.isHidden = true
        } else if position == 66 {
            self.nauseaView.isHidden = true
        }
    }
}

func gradientImage(topColor: UIColor, bottomColor: UIColor) -> UIImage {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 2))
    
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(topColor.cgColor)
    context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    context?.setFillColor(bottomColor.cgColor)
    context?.fill(CGRect(x: 0, y: 1, width: 1, height: 1))

    guard let image = UIGraphicsGetImageFromCurrentImageContext() else { abort() }
    
    UIGraphicsEndImageContext()
    
    return image
}

struct Gradient {
    let topColor: UIColor
    let bottomColor: UIColor
}

protocol ByoopRunnable where Self: UIView {
    func run()
}
