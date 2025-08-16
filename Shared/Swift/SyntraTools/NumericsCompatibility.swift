// NumericsCompatibility.swift
//
// Compatibility shim that centralizes access to numeric math functions.
// Purpose:
// - Provide stable wrappers around math functions used by Modi and other modules.
// - Use Darwin/libm functions directly to avoid relying on internal `_NumericsShims`
//   symbols which may not be present or exposed in some toolchains.
// - Keep wrappers small, deterministic, and implementation-only where appropriate.
//
// This file is presentation/compatibility-only and does not change numeric algorithms.
// Add additional wrappers here if other modules need specific shim symbols.
//

import Foundation
import Darwin

public enum NumericsCompatibility {
    @inlinable
    public static func log(_ x: Double) -> Double {
        return Darwin.log(x)
    }

    @inlinable
    public static func exp(_ x: Double) -> Double {
        return Darwin.exp(x)
    }

    @inlinable
    public static func pow(_ x: Double, _ y: Double) -> Double {
        return Darwin.pow(x, y)
    }

    @inlinable
    public static func log10(_ x: Double) -> Double {
        return Darwin.log10(x)
    }

    @inlinable
    public static func sqrt(_ x: Double) -> Double {
        return Darwin.sqrt(x)
    }
}
