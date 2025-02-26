import Foundation
import Combine

class DataModeManager: ObservableObject {
    static let shared = DataModeManager()
    
    // Set the default mode here (false = live, true = mock)
    @Published var isMockMode: Bool = false
}
