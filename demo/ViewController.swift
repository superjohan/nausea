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
    let autostart = false
    let eventCount = 64
    let maxRandom = 32

    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let contentView = UIView(frame: .zero)
    let nauseaView = UIImageView(image: UIImage(named: "nausea2"))
    let topGradients: [UIImage]
    let bottomGradients: [UIImage]

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
            "\"nausea\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming and music by ricky martin\n" +
                "\n" +
                "please make this window full screen.\n" +
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
        
        var topGradients = [UIImage]()
        var bottomGradients = [UIImage]()

        topGradients.append(
            gradientImage(
                topColor: UIColor(white: 1.0, alpha: 1.0),
                bottomColor: UIColor(white: 1.0, alpha: 1.0)
            )
        )
        
        bottomGradients.append(
            gradientImage(
                topColor: UIColor(white: 0, alpha: 1.0),
                bottomColor: UIColor(white: 0, alpha: 1.0)
            )
        )

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

        let view = IntroView(
            maxRandom: self.maxRandom,
            topGradients: self.topGradients,
            bottomGradients: self.bottomGradients,
            flip: true
        )
        view.isHidden = true
        self.contentView.addSubview(view)
        self.partViews.append(view)

        let view2 = IntroView(
            maxRandom: self.maxRandom,
            topGradients: self.topGradients,
            bottomGradients: self.bottomGradients,
            flip: false
        )
        view2.isHidden = true
        self.contentView.addSubview(view2)
        self.partViews.append(view2)

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
        self.nauseaView.transform = .identity
        self.nauseaView.layer.transform = CATransform3DIdentity

        if position < self.eventCount {
            let runnable: ByoopRunnable
            if position >= 32 {
                runnable = self.partViews[position % 2]
            } else {
                runnable = self.partViews[0]
            }
            runnable.isHidden = false
            runnable.frame = self.view.bounds

            let maxRandom: Int
            if position >= 0 && position < 8 {
                maxRandom = 1
            } else if position >= 8 && position < 16 {
                maxRandom = 2
            } else if position >= 16 && position < 32 {
                maxRandom = self.maxRandom / 2
            } else if position >= 32 && position < 48 {
                maxRandom = 4
                
                adjustLogoView(harsh: false)
            } else if position >= 48 && position < 64 {
                maxRandom = self.maxRandom
                
                adjustLogoView(harsh: true)
            } else {
                maxRandom = 1
            }
            
            let columns = Int.random(in: 1...maxRandom)
            var rows = [Int]()
            
            for _ in 0..<columns {
                rows.append(Int.random(in: 1...maxRandom))
            }

            runnable.run(
                frame: self.view.bounds,
                columns: columns,
                rows: rows
            )
        
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
    
    func adjustLogoView(harsh: Bool) {
        self.nauseaView.layer.zPosition = 500
        self.nauseaView.layer.transform.m34 = -0.002
        
        let adjustType = Int.random(in: 0...3)
        
        var rotate = harsh

        if adjustType == 0 {
            // do nothing
        } else if adjustType == 1 {
            rotate = true
        } else if adjustType == 2 {
            self.nauseaView.layer.transform = CATransform3DRotate(self.nauseaView.layer.transform, CGFloat.pi, 1.0, 0, 0)
        } else if adjustType == 3 {
            self.nauseaView.layer.transform = CATransform3DRotate(self.nauseaView.layer.transform, CGFloat.pi, 0, 1.0, 0)
        }
        
        if rotate {
            let angle: Double
            if harsh {
                angle = Double.random(in: 1...Double.pi)
            } else {
                angle = Double.random(in: 0...0.1)
            }
            
            let x = Double.random(in: -Double.pi...Double.pi)
            let y = Double.random(in: -Double.pi...Double.pi)
            let z = Double.random(in: -Double.pi...Double.pi)

            UIView.animate(withDuration: 0.875, delay: 0, options: [.curveEaseOut], animations: {
                self.nauseaView.layer.transform = CATransform3DRotate(self.nauseaView.layer.transform, angle, x, y, z)
            }, completion: nil)
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
    func run(frame: CGRect, columns: Int, rows: [Int])
}
