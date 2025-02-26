import HealthKit

class HealthKitManager: NSObject, HKWorkoutSessionDelegate {
    let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutDataSource: HKLiveWorkoutDataSource?
    
    // MARK: - Request Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Seeing if healthkit is available on this device.
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data not available"]))
            return
        }
        
        // HKObjectType.quantityType are the different kinds od data you can pull from
        // healthkit. We are using heart rate, but others would include step count
        // body mass, blood pressure, etc.
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, NSError(domain: "HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Heart rate type not available"]))
            return
        }
        
        // Asking for permission to read heart rate. If successful, enable
        // background delivery and start a workout session.
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                self.enableBackgroundDelivery()
                self.startWorkoutSession()
            }
            completion(success, error)
        }
    }
    
    // MARK: - Enable Background Delivery
    private func enableBackgroundDelivery() {
        // Enabling heart rate to be pushed to app even when app is not in foreground.
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if success {
                print("✅ Background delivery enabled for heart rate")
            } else {
                print("❌ Failed to enable background delivery: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Start Workout Session
    func startWorkoutSession() {
        // Check to make sure it is available on current divice.
        guard HKHealthStore.isHealthDataAvailable(),
              HKQuantityType.quantityType(forIdentifier: .heartRate) != nil else { return }
        
        // Configure workout
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown
        
        // Initialize seeion with the previous config. Assign class variables.
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutSession?.delegate = self
            
            // Use HKLiveWorkoutDataSource for live tracking (if needed for additional data)
            workoutDataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            workoutSession?.startActivity(with: Date())
            print("✅ Workout session started successfully")
        } catch {
            print("❌ Failed to create workout session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop Workout Session
    // Ends Workout session.
    func stopWorkoutSession() {
        workoutSession?.end()
        print("⏹ Workout session stopped.")
    }
    
    // MARK: - HKWorkoutSessionDelegate Methods
    // You do not call these directly, HealthKit automatically calls them when
    // workout session changes or when an error occurs
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            print("🏃‍♂️ Workout session is now running.")
        case .ended:
            print("⏹ Workout session ended.")
        default:
            print("ℹ️ Workout session changed to state: \(toState.rawValue)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("❌ Workout session error: \(error.localizedDescription)")
    }
}
