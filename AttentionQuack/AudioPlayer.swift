//
//  AudioPlayer.swift
//  AttentionQuack
//
//  Created by Luca Maria Incarnato on 11/06/25.
//

import Foundation
import AVFoundation

// Allows playing music inside the app, used to preview notification sound and in minigame
class AudioPlayer: ObservableObject {
    private var player: AVAudioPlayer?
    
    // Play the audio
    func playSound(_ fileName: String) {
        // If audio is already reproducing, do nothing
        if let player = player, player.isPlaying {
            return
        }
        // Set URL from filename
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("File not found")
            return
        }
        // Play audio
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.stopSound()
            self.player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error while playing audio file: \(error.localizedDescription)")
        }
    }
    
    func playSound(from fileURL: URL) {
        if let player = player, player.isPlaying {
            return
        }
        // Verify file exists at path
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Audio file not found at \(fileURL.path)")
            return
        }
        
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Initialize and play audio
            self.player = try AVAudioPlayer(contentsOf: fileURL)
            self.stopSound()
            self.player?.prepareToPlay()
            self.player?.play()
        } catch {
            print("Audio playback error: \(error.localizedDescription)")
        }
    }
    
    // Stop the audio
    func stopSound() {
        if let player = player {
            player.stop()
            player.currentTime = 0 // Comes back to the start of the file
        } else {
            print("No audio to stop")
        }
    }
}
