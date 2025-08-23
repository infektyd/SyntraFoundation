import XCTest
@testable import SyntraFoundation

final class NumericsCompatibilityTests: XCTestCase {
    
    func test_numerics_log_equivalence_double() {
        let inputs: [Double] = [0.1, 1.0, M_E, 10.0]
        let tol: Double = 1e-12
        
        for x in inputs {
            let a = NumericsCompatibility.log(x)
            let b = Darwin.log(x)
            XCTAssertEqual(a, b, accuracy: tol, "NumericsCompatibility.log(\(x)) != Darwin.log(\(x)) for Double")
        }
    }

    func test_numerics_log_equivalence_float() {
        let inputs: [Float] = [0.1, 1.0, expf(1.0), 10.0]
        let tol: Float = 1e-7
        
        for x in inputs {
            let a = NumericsCompatibility.log(x)
            let b = Darwin.logf(x)
            XCTAssertEqual(a, b, accuracy: tol, "NumericsCompatibility.log(\(x)) != Darwin.logf(\(x)) for Float")
        }
    }
    
    func test_entropy_consistency_between_log_implementations() {
        // Sample distribution
        let probs: [Double] = [0.1, 0.3, 0.6]
        let tol: Double = 1e-12
        
        func entropy(using logFunc: (Double) -> Double) -> Double {
            return -probs.reduce(0) { $0 + ($1 > 0 ? $1 * logFunc($1) : 0) }
        }
        
        let entropyWithShim = entropy { NumericsCompatibility.log($0) }
        let entropyWithDarwin = entropy { Darwin.log($0) }
        
        XCTAssertEqual(entropyWithShim, entropyWithDarwin, accuracy: tol, "Entropy mismatch between shim and Darwin logs")
    }
}
