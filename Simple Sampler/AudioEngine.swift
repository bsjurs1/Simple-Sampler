//
//  AudioEngine2.swift
//  Loyd Piano
//
//  Created by Bjarte Sjursen on 17/11/2019.
//  Copyright © 2019 Sjursen Software. All rights reserved.
//

import Foundation
import AudioKit

class AudioEngine {
    
    var mic: AKMicrophone?
    var tracker: AKFrequencyTracker?
    var fundamentalFrequency: Double
    var recorder: AKNodeRecorder?
    var audioFile: AKAudioFile!
    var noteOfRecordedSound: Note?
    lazy var players: [AKPlayer?]? = {
        return Array.init(repeating: AKPlayer(), count: 24)
    }()
    lazy var playerPitchShifters: [AKPitchShifter?]? = {
        return Array.init(repeating: AKPitchShifter(), count: 24)
    }()
    var pianoMixer: AKMixer?
    var microphoneDrawingSource: AKBooster?
    var recordingMixer: AKMixer?
    
    init?() {
        tracker = AKFrequencyTracker()
        fundamentalFrequency = Double.infinity
        pianoMixer = AKMixer()
        microphoneDrawingSource = AKBooster()
        recordingMixer = AKMixer()
        AKSettings.audioInputEnabled = true
    }
    
    func startAudioRecording(microphoneSetupCallback callback: @escaping (AKBooster) -> Void) {
        DispatchQueue.init(label: "recordingQueue").async {
            [weak self] in
            guard let self = self else { return }
            self.mic = AKMicrophone()
            do {
                self.resetFundamentalFrequency()
                let frequencyDetectionLoop = AKPeriodicFunction(frequency: 10.0) {
                    [weak self] in
                    guard
                        let self = self,
                        let tracker = self.tracker
                    else { return }
                    self.retainFundamentalFrequency(newFrequency: tracker.frequency)
                }
                self.microphoneDrawingSource = AKBooster(self.mic)
                self.tracker = AKFrequencyTracker(self.mic)
                self.recordingMixer = AKMixer(self.microphoneDrawingSource, self.tracker)
                self.audioFile = try AKAudioFile()
                self.recorder = try AKNodeRecorder(node: self.tracker,
                                                   file: self.audioFile)
                self.recordingMixer?.volume = 0.0
                AudioKit.output = self.recordingMixer
                DispatchQueue.main.async {
                    [weak self] in
                    guard
                        let self = self,
                        let microphoneDrawingSource = self.microphoneDrawingSource
                    else { return }
                    callback(microphoneDrawingSource)
                }
                try self.recorder?.reset()
                try self.recorder?.record()
                frequencyDetectionLoop.start()
                try AudioKit.start(withPeriodicFunctions: frequencyDetectionLoop)
            } catch {
                AKLog("Could not start AudioPlayer. Error: \(error)")
            }
        }
    }
    
    func setupPlayers(withOctaveShift octaveShift: Int) {
        for basePitch in BasePitchFrequencies.allCases {
            setupRecorderSoundFor(note: Note(basePitch: basePitch, octave: octaveShift))
        }
    }
    
    func setupRecorderSoundFor(note: Note) {
        let indexOfNoteOfRecordedSound = BasePitchFrequencies.allCases.firstIndex(of: noteOfRecordedSound!.basePitch)!
        var indexOfDesiredNoteToPlay = BasePitchFrequencies.allCases.firstIndex(of: note.basePitch)!
        let shiftFactor = Double(indexOfDesiredNoteToPlay - indexOfNoteOfRecordedSound)
        indexOfDesiredNoteToPlay += (note.octave*12)
        players?[indexOfDesiredNoteToPlay] = AKPlayer(audioFile: audioFile)
        playerPitchShifters?[indexOfDesiredNoteToPlay] = AKPitchShifter(players?[indexOfDesiredNoteToPlay])
        playerPitchShifters?[indexOfDesiredNoteToPlay]?.shift = shiftFactor + note.octave * 12
        players?[indexOfDesiredNoteToPlay]?.isLooping = false
        players?[indexOfDesiredNoteToPlay]?.volume = 100.0
    }
    
    func playRecordedSound(inNote note: Note) {
        var indexOfDesiredNoteToPlay = BasePitchFrequencies.allCases.firstIndex(of: note.basePitch)!
        indexOfDesiredNoteToPlay += (note.octave*12)
        players?[indexOfDesiredNoteToPlay]?.play()
    }
    
    func stopPlayingRecordedSound(inNote note: Note) {
        var indexOfDesiredNoteToPlay = BasePitchFrequencies.allCases.firstIndex(of: note.basePitch)!
        indexOfDesiredNoteToPlay += (note.octave*12)
        if players?[indexOfDesiredNoteToPlay]?.isPlaying ?? false {
            players?[indexOfDesiredNoteToPlay]?.stop()
        }
    }
    
    func stopAudioRecording() {
        do {
            recorder?.stop()
            mic?.stop()
            recordingMixer?.stop()
            try AudioKit.stop()
            AudioKit.output = nil
            noteOfRecordedSound = detectMostSimilarPitch(ofFrequency: fundamentalFrequency)
            setupPlayers(withOctaveShift: 0)
            setupPlayers(withOctaveShift: 1)
            if let playerPitchShifters = playerPitchShifters?.compactMap({ $0 }) {
                pianoMixer = AKMixer(playerPitchShifters)
            }
            AudioKit.output = pianoMixer
            do {
                try AudioKit.start()
            } catch {
                AKLog("Could not start AudioPlayer. Error: \(error)")

            }
        } catch {
            AKLog("AudioKit did not stop!")
        }
    }
    
    private func resetFundamentalFrequency() {
        fundamentalFrequency = Double.infinity
    }
    
    private func retainFundamentalFrequency(newFrequency: Double) {
        if newFrequency < self.fundamentalFrequency && newFrequency > 0.0 {
            self.fundamentalFrequency = newFrequency
        }
    }
    
    private func detectMostSimilarPitch(ofFrequency frequency: Double) -> Note {
        var b0ShiftCount = 1
        while frequency > b0ShiftCount * BasePitchFrequencies.B.rawValue {
            b0ShiftCount += 1
        }
        let pitchDifferences = BasePitchFrequencies.allCases.map { abs(frequency - $0.rawValue * b0ShiftCount) }
        let minimumPitchDifferenceIndex = pitchDifferences.firstIndex(of: pitchDifferences.min() ?? 0.0) ?? 0
        return Note(basePitch: BasePitchFrequencies.allCases[minimumPitchDifferenceIndex], octave: Int(b0ShiftCount))
    }
    
    deinit {
        audioFile = nil
        noteOfRecordedSound = nil
        recorder?.stop()
        try? recorder?.reset()
        recorder = nil
        try? AudioKit.stop()
        AudioKit.output = nil
        mic?.stop()
        mic = nil
        for i in 0..<12 {
            players?[i] = nil
        }
        for i in 0..<12 {
            playerPitchShifters?[i] = nil
        }
        players?.removeAll()
        playerPitchShifters?.removeAll()
        recordingMixer = nil
        microphoneDrawingSource = nil
        pianoMixer = nil
        tracker = nil
        playerPitchShifters = nil
        players = nil
    }
    
}

enum BasePitchFrequencies: Double, CaseIterable {
    typealias RawValue = Double
    case C = 16.35
    case CSharp = 17.32
    case D = 18.35
    case DSharp = 19.45
    case E = 20.60
    case F = 21.83
    case FSharp = 23.12
    case G = 24.50
    case GSharp = 25.96
    case A = 27.50
    case ASharp = 29.14
    case B = 30.87
}

struct Note {
    let basePitch: BasePitchFrequencies
    let octave: Int
}
