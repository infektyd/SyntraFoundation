// NumericsCompatibility.swift (Modi-local copy)
//
// Local compatibility shim for the Modi target. Mirrors the SyntraTools shim but
// lives inside the Modi target so the Modi module can reference it without adding
// an extra package dependency.
//
// This file is compatibility-only and delegates to Darwin/libm functions directly
// to avoid relying on internal `_NumericsShims` symbols which may not be present
// or exposed in some toolchains.
//

import Foundation
import Darwin

enum ModiNumericsCompatibility {
    @inlinable
    static func log(_ x: Double) -> Double {
        return Darwin.log(x)
    }

    @inlinable
    static func exp(_ x: Double) -> Double {
        return Darwin.exp(x)
    }

    @inlinable
    static func pow(_ x: Double, _ y: Double) -> Double {
        return Darwin.pow(x, y)
    }

    @inlinable
    static func sqrt(_ x: Double) -> Double {
        return Darwin.sqrt(x)
    }
}
