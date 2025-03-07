//
//  PersistenceController.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import WatchConnectivity

class WatchDataBuffer {
    static let shared = WatchDataBuffer()
    
    // In-memory buffer for HeartRateSample objects.
    private var buffer = [HeartRateSample]()
    
    // Adds a new HeartRateSample to the buffer.
    func addSample(_ sample: HeartRateSample) {
        buffer.append(sample)
        print("Buffered sample: \(sample.heartRate) BPM at \(sample.timestamp)")
    }
    
    // Attempts to send all buffered samples to the phone in the order they were received.
    func flushBuffer() {
        guard WCSession.default.isReachable else {
            print("Phone is not reachable; cannot flush buffer.")
            return
        }
        
        // Send buffered samples in FIFO order.
        for sample in buffer {
            DataSender.shared.sendHeartRateData(sample: sample)
        }
        
        print("Flushed \(buffer.count) buffered samples.")
        buffer.removeAll()
    }
}



