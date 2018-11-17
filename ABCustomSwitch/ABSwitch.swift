//
//  ABSwitch.swift
//  ABCustomSwitch
//
//  Created by Akash Bhardwaj on 17/11/18.
//  Copyright © 2018 Akash Bhardwaj. All rights reserved.
//

import UIKit
typealias ABSwitchCallback = (Bool) -> Void
class ABSwitch: UIView {
    var isOn: Bool = false
    
    var onColor: UIColor = .green
    
    var offColor: UIColor = .white
    
    var callback: ABSwitchCallback?
    
    private var imageView: UIImageView!
    
    private var onImage: UIImage?
    
    private var offImage: UIImage?
    
    private var animationFractionWhileInterrupted: CGFloat = 0.0
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    
}
// Setup
extension ABSwitch {
   private func setupImageView () {
        self.imageView = UIImageView()
        self.imageView.isUserInteractionEnabled = true
    self.imageView.frame = CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: self.frame.height)
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        addSubview(self.imageView)
    }
    
    func config(onImage: UIImage, offImage: UIImage, callback: ABSwitchCallback?) {
        self.onImage = onImage
        self.offImage = offImage
        self.callback = callback
        self.imageView.image = self.isOn ? onImage : offImage
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.imageView.image!.size.width, height: self.imageView.image!.size.width)
        addGestureToImageView()
    }
    
    private func addGestureToImageView () {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ABSwitch.handleImageTap(recogonizer:)))
        self.imageView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ABSwitch.handleImagePan(recogonizer:)))
        self.imageView.addGestureRecognizer(panGesture)
    }
    
    @objc
    private func handleImageTap (recogonizer: UITapGestureRecognizer) {
        switch recogonizer.state {
        case .ended:
            animationIfNeeded(isOn: self.isOn, timeinterval: 0.3)
        default:
            break
        }
    }
    
    @objc
    private func handleImagePan (recogonizer: UIPanGestureRecognizer) {
        switch recogonizer.state {
        case .began:
            self.startInteractiveAnimation(isOn: self.isOn, timeInterval: 0.5)
        case .changed:
            let translation = recogonizer.translation(in: self.imageView)
            var fractionComplete = translation.x / self.frame.width
            fractionComplete = !self.isOn ? fractionComplete : -fractionComplete
            self.updateInteractiveAnimation(fractionCompleted: fractionComplete)
        case .ended:
            let translation = recogonizer.translation(in: self.imageView)
            var fractionComplete = translation.x / self.frame.width
            fractionComplete = !self.isOn ? fractionComplete : -fractionComplete
            if fractionComplete > 0.5 {
            continueInteractiveAnimation()
            } else {
            self.updateInteractiveAnimation(fractionCompleted: 0.0)
            }
        default:
            break
        }
    }
    
}
// Animation
extension ABSwitch {
    private func startInteractiveAnimation(isOn: Bool, timeInterval: TimeInterval) {
        if runningAnimations.isEmpty {
            animationIfNeeded(isOn: isOn, timeinterval: timeInterval)
        }
        for animation in runningAnimations {
            animation.pauseAnimation()
            animationFractionWhileInterrupted = animation.fractionComplete
        }
    }
    
    private func animationIfNeeded (isOn: Bool, timeinterval: TimeInterval) {
        if runningAnimations.isEmpty {
            
            let frameAnimator = UIViewPropertyAnimator(duration: timeinterval, curve: .linear) {
                if isOn {
                    self.imageView.frame.origin.x = 0
                } else {
                    self.imageView.frame.origin.x = self.frame.width - self.imageView.frame.width
                }
            }
            
            frameAnimator.addCompletion { (_) in
                if isOn {
                    self.imageView.image = self.offImage
                    self.backgroundColor = self.offColor
                } else {
                    self.imageView.image = self.onImage
                    self.backgroundColor = self.onColor
                }
                self.isOn = !self.isOn
                self.callback?(self.isOn)
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    private func updateInteractiveAnimation (fractionCompleted: CGFloat) {
        for animation in runningAnimations {
            animation.fractionComplete = fractionCompleted + animationFractionWhileInterrupted
        }
    }
    
    private func continueInteractiveAnimation () {
        for animation in runningAnimations {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
        }
    }
}
