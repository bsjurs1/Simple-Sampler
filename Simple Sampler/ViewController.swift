//
//  ViewController.swift
//  Simple Sampler
//
//  Created by Bjarte Sjursen on 16/11/2019.
//  Copyright © 2019 Sjursen Software. All rights reserved.
//

import UIKit
import AudioKitUI
import AudioKit

class ViewController: UIViewController {
    
    var whitePianoKeyViews = [WhitePianoKeyView]()
    @IBOutlet weak var backgroundView: CustomizableView!
    @IBOutlet weak var pianoBlackBar: UIView!
    @IBOutlet weak var recordStopButton: HeightenedButton!
    var countDownCoverView: UIView?
    var blackPianoKeyViews = [BlackPianoKeyView]()
    var isRecording = false
    var countDownTimer = Timer()
    var countDownCounter = 0
    var micAnimation = 1
    let octave = 0
    var isRecordButtonPressed = false
    var rollingPlot = AKNodeOutputPlot()
    @IBOutlet weak var countDownBannerBackground: CustomizableView!
    @IBOutlet var countDownLabels: [CustomizableView]!
    var audioEngine: AudioEngine?
    var buttonActionAllowed = true
    var audioPlayer: AudioPlayer?
    var isInitialViewDidLayout = true
    var maxScreenSize = CGSize(width: 1344, height: 621)
    @IBOutlet weak var middleBackgroundView: UIView!
    
    let blackPitchNotes = [BasePitchFrequencies.CSharp,
                           BasePitchFrequencies.DSharp,
                           BasePitchFrequencies.FSharp,
                           BasePitchFrequencies.GSharp,
                           BasePitchFrequencies.ASharp]
    
    let whitePitchNotes = [BasePitchFrequencies.C,
                           BasePitchFrequencies.D,
                           BasePitchFrequencies.E,
                           BasePitchFrequencies.F,
                           BasePitchFrequencies.G,
                           BasePitchFrequencies.A,
                           BasePitchFrequencies.B]
    
    override func viewWillAppear(_ animated: Bool) {
        if maxScreenSize.width > view.frame.width && maxScreenSize.width > view.frame.height {
            maxScreenSize = CGSize(width: 1112.0/2.0, height: 834.0/2.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCountDownBanner()
    }
    
    func setupPianoBar() {
        view.bringSubviewToFront(backgroundView)
    }
    
    func highlightRecordButton() {
        if recordStopButton.layer.animation(forKey: "shadowOpacity") != nil {
            return
        }
        let animationOut = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
        animationOut.fromValue = 1.0
        animationOut.toValue = 0.0
        animationOut.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animationOut.duration = 1.0
        recordStopButton.layer.add(animationOut, forKey: "shadowOpacity")
    }
    
    func setupCountDownBanner() {
        
        for countDownLabel in countDownLabels {
            countDownLabel.alpha = 0.5
        }
        
        recordStopButton.touchesEndedAction = {
            [weak self] in
            guard let self = self else { return }
            if self.isRecording {
                if self.countDownTimer.isValid {
                    self.countDownTimer.invalidate()
                    self.isRecording = false
                    self.stopCountDown()
                    self.recordStopButton.titleLayer.string = "Record"
                    self.resetPianoKeyActions()
                    self.setupHighligthRecordButtonPianoKeyButtonActions()
                    self.audioEngine = nil
                } else {
                    self.isRecording = false
                    self.stopCountDown()
                    self.resetPianoKeyActions()
                    self.recordStopButton.titleLayer.string = "Record"
                    self.audioEngine?.stopAudioRecording()
                    for (i, whitePianoKey) in self.whitePianoKeyViews.enumerated() {
                        whitePianoKey.touchesBeganAction = {
                            self.audioEngine?.playRecordedSound(inNote: Note(basePitch: self.whitePitchNotes[i%7], octave: Int(self.octave + floor(i/7.0))))
                        }
                        whitePianoKey.touchesEndedAction = {
                            self.audioEngine?.stopPlayingRecordedSound(inNote: Note(basePitch: self.whitePitchNotes[i%7], octave: Int(self.octave + floor(i/7.0))))
                        }
                    }
                    
                    for (i, blackPianoKey) in self.blackPianoKeyViews.enumerated() {
                        blackPianoKey.touchesBeganAction = {
                            self.audioEngine?.playRecordedSound(inNote: Note(basePitch: self.blackPitchNotes[i%5], octave: Int(self.octave + floor(i/5.0))))
                        }
                        blackPianoKey.touchesEndedAction = {
                            self.audioEngine?.stopPlayingRecordedSound(inNote: Note(basePitch: self.blackPitchNotes[i%5], octave: Int(self.octave + floor(i/5.0))))
                        }
                    }
                    
                    self.rollingPlot.pause()
                    self.rollingPlot.clear()
                    self.rollingPlot.removeFromSuperview()
                    self.rollingPlot = AKNodeOutputPlot()
                }
            } else {
                self.isRecording = true
                self.isRecordButtonPressed = true
                self.audioEngine = nil
                self.audioEngine = AudioEngine()
                self.startCountDown()
                self.recordStopButton.titleLayer.string = "Stop"
            }
        }
    }
    
    func stopCountDown() {
        buttonActionAllowed = true
        for whitePianoKey in whitePianoKeyViews {
            whitePianoKey.isUserInteractionEnabled = true
        }
        recordStopButton.isUserInteractionEnabled = true
        for blackPianoKey in blackPianoKeyViews {
            blackPianoKey.isUserInteractionEnabled = true
        }
        for countDownLabel in countDownLabels {
            countDownLabel.alpha = 0.5
        }
        countDownCoverView?.isHidden = true
        countDownBannerBackground.isHidden = true
        countDownCounter = 0
        audioPlayer = nil
    }
    
    func resetPianoKeyActions() {
        for whitePianoKey in whitePianoKeyViews {
            whitePianoKey.touchesBeganAction = nil
            whitePianoKey.touchesEndedAction = nil
        }
        
        for blackPianoKey in blackPianoKeyViews {
            blackPianoKey.touchesBeganAction = nil
            blackPianoKey.touchesEndedAction = nil
        }
    }
    
    func startCountDown() {
        audioPlayer = nil
        buttonActionAllowed = false
        for whitePianoKey in whitePianoKeyViews {
            whitePianoKey.isUserInteractionEnabled = false
        }
        recordStopButton.isUserInteractionEnabled = false
        for blackPianoKey in blackPianoKeyViews {
            blackPianoKey.isUserInteractionEnabled = false
        }
        audioPlayer = AudioPlayer(withAudioFileNamed: "Bottle Cork.mp3")
        
        resetPianoKeyActions()
        
        if countDownCoverView == nil {
            guard
                let window = UIApplication.shared.windows.first
            else { return }
            countDownCoverView = UIView(frame: window.bounds)
            countDownCoverView?.frame.origin.x = 0.0
            countDownCoverView?.frame.origin.y = 0.0
            countDownCoverView?.backgroundColor = .black
            countDownCoverView?.alpha = 0.7
            countDownCoverView?.isUserInteractionEnabled = false
            countDownCoverView?.isHidden = false
            view.addSubview(countDownCoverView!)
            view.bringSubviewToFront(countDownCoverView!)
        }
        countDownCoverView?.isHidden = false
        countDownBannerBackground.isHidden = false
        view.bringSubviewToFront(countDownBannerBackground!)
        let date = Date().addingTimeInterval(1)
        countDownTimer = Timer(fireAt: date,
                               interval: 1.0,
                               target: self,
                               selector: #selector(countDown),
                               userInfo: nil,
                               repeats: true)
        RunLoop.main.add(countDownTimer, forMode: .common)
    }
    
    @objc func countDown() {
        audioPlayer?.stop()
        if countDownCounter == 4 {
            stopCountDown()
            countDownTimer.invalidate()
            audioEngine?.startAudioRecording(microphoneSetupCallback: {
                [weak self] (booster) in
                guard let self = self else { return }
                self.rollingPlot = AKNodeOutputPlot(booster, frame: CGRect(x: 0,
                                                                           y: 0,
                                                                           width: self.view.bounds.width,
                                                                           height: self.pianoBlackBar.frame.origin.y))
                self.rollingPlot.plotType = .buffer
                self.rollingPlot.center.y = self.pianoBlackBar.frame.origin.y/2.0
                self.rollingPlot.shouldFill = true
                self.rollingPlot.shouldMirror = true
                self.rollingPlot.color = UIColor(red: 0.4549, green: 0.1294, blue: 0.9569, alpha: 1.0)
                self.rollingPlot.backgroundColor = .clear
                self.rollingPlot.gain = 1.0
                self.view.addSubview(self.rollingPlot)
            })
        } else {
            audioPlayer?.play()
            countDownLabels?[countDownCounter].alpha = 1.0
            countDownCounter += 1
        }
    }
    
    func setupPianoKeys() {
        
        let maxScreenWidth = view.bounds.width
        let maxScreenHeight = min(view.bounds.height, maxScreenSize.height)
        let whitePianoKeyFrameYOrigin = middleBackgroundView.frame.origin.y - 20.0
        
        let whitePianoKeyFrame = CGRect(x: 0,
                                        y: whitePianoKeyFrameYOrigin,
                                        width: floor((maxScreenWidth)/14.0) - 2.0,
                                        height: (maxScreenHeight * 2.0/3.0))
        
        
        for _ in 0..<14 {
            let whitePianoKeyView = WhitePianoKeyView(frame: whitePianoKeyFrame)
            whitePianoKeyViews.append(whitePianoKeyView)
        }
        
        let blackPianoKeyFrame = CGRect(x: 0,
                                        y: whitePianoKeyViews[0].frame.origin.y,
                                        width: 2.0/3.0 * whitePianoKeyViews[0].bounds.width,
                                        height: 2.0/3.0 * whitePianoKeyViews[0].bounds.height)
        
        for _ in 0..<10 {
            let blackPianoKeyView = BlackPianoKeyView(frame: blackPianoKeyFrame)
            blackPianoKeyViews.append(blackPianoKeyView)
        }
        
        for (i, whitePianoKeyView) in whitePianoKeyViews.enumerated() {
            if i == 0 {
                whitePianoKeyView.frame.origin.x = 0.0
            } else {
                whitePianoKeyView.frame.origin.x = CGFloat(i) * (whitePianoKeyFrame.width + 2)
            }
            view.addSubview(whitePianoKeyView)
        }
        
        var whiteKeySkipCounter = 1
        for (i, blackPianoKeyView) in blackPianoKeyViews.enumerated() {
            if i == 2 || i == 5 || i == 7 {
                whiteKeySkipCounter += 1
            }
            blackPianoKeyView.center.x = whitePianoKeyViews[i + whiteKeySkipCounter].frame.origin.x
            view.insertSubview(blackPianoKeyView, aboveSubview: whitePianoKeyViews[i + whiteKeySkipCounter])
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPianoBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isInitialViewDidLayout {
            setupPianoKeys()
            view.bringSubviewToFront(backgroundView)
            setupHighligthRecordButtonPianoKeyButtonActions()
            isInitialViewDidLayout = false
        } else {
            let maxScreenWidth = view.bounds.width
            let maxScreenHeight = min(view.bounds.height, maxScreenSize.height)
            let whitePianoKeyFrameYOrigin = middleBackgroundView.frame.origin.y - 20.0
            let whitePianoKeyFrame = CGRect(x: 0,
                                            y: whitePianoKeyFrameYOrigin,
                                            width: floor((maxScreenWidth)/14.0) - 2.0,
                                            height: (maxScreenHeight * 2.0/3.0))
            
            for (i, whitePianoKeyView) in whitePianoKeyViews.enumerated() {
                whitePianoKeyView.frame = whitePianoKeyFrame
                if i == 0 {
                    whitePianoKeyView.frame.origin.x = 0.0
                } else {
                    whitePianoKeyView.frame.origin.x = CGFloat(i) * (whitePianoKeyFrame.width + 2)
                }
            }
            
            let blackPianoKeyFrame = CGRect(x: 0,
                                            y: whitePianoKeyViews[0].frame.origin.y,
                                            width: 2.0/3.0 * whitePianoKeyViews[0].bounds.width,
                                            height: 2.0/3.0 * whitePianoKeyViews[0].bounds.height)
            
            var whiteKeySkipCounter = 1
            for (i, blackPianoKeyView) in blackPianoKeyViews.enumerated() {
                if i == 2 || i == 5 || i == 7 {
                    whiteKeySkipCounter += 1
                }
                blackPianoKeyView.frame = blackPianoKeyFrame
                blackPianoKeyView.center.x = whitePianoKeyViews[i + whiteKeySkipCounter].frame.origin.x
            }
        }
    }
    
    func setupHighligthRecordButtonPianoKeyButtonActions() {
        for whitePianoKey in whitePianoKeyViews {
            whitePianoKey.touchesEndedAction = {
                [weak self] in
                guard let self = self else { return }
                self.highlightRecordButton()
            }
        }
        
        for blackPianoKey in blackPianoKeyViews {
            blackPianoKey.touchesEndedAction = {
                [weak self] in
                guard let self = self else { return }
                self.highlightRecordButton()
            }
        }
    }
    
    
}

