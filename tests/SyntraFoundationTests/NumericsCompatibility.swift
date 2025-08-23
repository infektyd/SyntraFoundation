import Foundation
#if canImport(Numerics)
import Numerics
#endif

/// A namespace for compatibility functions for `Numerics`.
///
/// This allows us to compile on platforms where `Numerics` is not available.
public enum NumericsCompatibility {
    /// The natural logarithm of `x`.
    public static func log<T: Real>(_ x: T) -> T {
        #if canImport(Numerics)
        return .log(x)
        #else
        // Fallback to `Darwin.log` for `Double` precision and convert back to `T`.
        // This is safer than a forced cast and supports different `Real` types like `Float`.
        return T(Darwin.log(Double(x)))
        #endif
    }
}
