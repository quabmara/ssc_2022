//
//  File.swift
//  sudoku app
//
//  Created by mara on 18.04.22.
//

import Foundation

//Classes
class TimerManager: ObservableObject {
    @Published var secondsPassed = 0
    var timer = Timer()
    @Published var isPaused = false
    
    func start() {
        isPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.secondsPassed += 1
        }
    }
    func stop() {
        isPaused = true
        timer.invalidate()
    }
    func reset() {
        isPaused = true
        timer.invalidate()
        secondsPassed = 0
    }
    func convertedTime() -> String {
        let seconds = secondsPassed % 60
        let minutes = secondsPassed / 60
        
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
