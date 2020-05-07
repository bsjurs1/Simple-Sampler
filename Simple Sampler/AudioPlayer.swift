//
//  AudioPlayer.swift
//  Simple Sampler
//
//  Created by Bjarte Sjursen on 23/11/2019.
//  Copyright © 2019 Sjursen Software. All rights reserved.
//

import AudioKit
import Foundation

class AudioPlayer {
    
    var audioFile: AKAudioFile?
    var audioPlayer: AKAudioPlayer?
    
    init?(withAudioFileNamed audioFileName: String) {
        do {
            audioFile = try AKAudioFile(readFileName: audioFileName)
            guard let audioFile = self.audioFile else { return nil }
            audioPlayer = try AKAudioPlayer(file: audioFile)
            AudioKit.output = audioPlayer
            try AudioKit.start()
        } catch {
            AKLog("Could not init AudioPlayer. Error: \(error)")
        }
    }
    
    func play() {
        guard
            let audioFile = self.audioFile,
            let audioPlayer = self.audioPlayer,
            audioPlayer.audioFile.fileName == audioFile.fileName,
            !audioPlayer.isPlaying
        else { return }
        audioPlayer.play()
    }
    
    func stop() {
        guard
            let audioPlayer = self.audioPlayer,
            audioPlayer.isPlaying
        else {
            return
        }
        audioPlayer.stop()
    }
    
    deinit {
        try? AudioKit.stop()
        audioPlayer?.detach()
        audioPlayer = nil
        audioFile = nil
        AudioKit.output = nil
    }
    
    
}
