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
    
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let contentView = UIView(frame: .zero)
    
    var partViews = [ByoopRunnable]()
    var position = 0
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
                "please make this window full screen\n" +
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

        self.partViews.append(
            IntroView(byoopView: ByoopView(
                frame: .zero,
                topGradient: gradientImage(topColor: colors[5].topColor, bottomColor: colors[5].bottomColor),
                bottomGradient: gradientImage(topColor: colors[4].topColor, bottomColor: colors[4].bottomColor)
            ))
        )
        self.partViews.append(
            IntroView(byoopView: ByoopView(
                frame: .zero,
                topGradient: gradientImage(topColor: colors[0].topColor, bottomColor: colors[0].bottomColor),
                bottomGradient: gradientImage(topColor: colors[1].topColor, bottomColor: colors[1].bottomColor)
            ))
        )
        self.partViews.append(
            IntroView(byoopView: ByoopView(
                frame: .zero,
                topGradient: gradientImage(topColor: colors[2].topColor, bottomColor: colors[2].bottomColor),
                bottomGradient: gradientImage(topColor: colors[4].topColor, bottomColor: colors[4].bottomColor)
            ))
        )
        self.partViews.append(
            IntroView(byoopView: ByoopView(
                frame: .zero,
                topGradient: gradientImage(topColor: colors[3].topColor, bottomColor: colors[3].bottomColor),
                bottomGradient: gradientImage(topColor: colors[5].topColor, bottomColor: colors[5].bottomColor)
            ))
        )
        
        for view in self.partViews {
            view.isHidden = true
            self.contentView.addSubview(view)
        }
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
        let eventCount = 64
        
        for position in 0..<eventCount {
            perform(#selector(event), with: NSNumber(value: position), afterDelay: TimeInterval(position))
        }
    }
    
    @objc private func event(pos: NSNumber) {
        let positionInTrack = pos.intValue
        
        self.currentView?.isHidden = true
        
        let runnable = self.partViews[self.position]
        runnable.isHidden = false
        runnable.frame = self.view.bounds
        runnable.run()
        
        self.currentView = runnable
        
        if positionInTrack % 2 == 1 {
            self.position += 1
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

let colors = [
    Gradient( // purple
        topColor: UIColor(red: 255 / 255.0, green: 52 / 255.0, blue: 255 / 255.0, alpha: 1.0),
        bottomColor: UIColor(red: 255 / 255.0, green: 104 / 255.0, blue: 254 / 255.0, alpha: 1.0)
    ),
    Gradient( // cyan
        topColor: UIColor(red: 102 / 255.0, green: 255 / 255.0, blue: 250 / 255.0, alpha: 1.0),
        bottomColor: UIColor(red: 51 / 255.0, green: 255 / 255.0, blue: 248 / 255.0, alpha: 1.0)
    ),
    Gradient( // green
        topColor: UIColor(red: 54 / 255.0, green: 255 / 255.0, blue: 83 / 255.0, alpha: 1.0),
        bottomColor: UIColor(red: 102 / 255.0, green: 255 / 255.0, blue: 125 / 255.0, alpha: 1.0)
    ),
    Gradient( // blue
        topColor: UIColor(red: 107 / 255.0, green: 102 / 255.0, blue: 255 / 255.0, alpha: 1.0),
        bottomColor: UIColor(red: 60 / 255.0, green: 54 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    ),
    Gradient( // yellow
        topColor: UIColor(red: 255 / 255.0, green: 240 / 255.0, blue: 49 / 255.0, alpha: 1.0),
        bottomColor: UIColor(red: 255 / 255.0, green: 244 / 255.0, blue: 102 / 255.0, alpha: 1.0)
    ),
    Gradient( // red
        topColor: UIColor(red: 255 / 255.0, green: 50 / 255.0, blue: 50 / 255.0, alpha: 1.0),
        bottomColor: UIColor(red: 255 / 255.0, green: 102 / 255.0, blue: 102 / 255.0, alpha: 1.0)
    ),
]

protocol ByoopRunnable where Self: UIView {
    func run()
}
