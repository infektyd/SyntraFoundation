//
// OutputFormatters.swift
//
// Presentation-only formatter for human-facing assessment outputs.
// Public API:
//   public func formatAssessmentOutput(_ input: Any) -> String
//
// Implementation notes:
// - Uses Foundation only (Mirror, JSONSerialization).
// - Deterministic ordering: dictionary keys sorted alphabetically (case-insensitive).
// - Numeric formatting: up to 3 decimal places, trailing zeros trimmed.
// - Robust parsing for factor arrays with tolerant key variants.
// - No changes to any computation or logic; presentation-only.
//

import Foundation

public func formatAssessmentOutput(_ input: Any) -> String {
    // Convert input to dictionary-like structure if possible.
    if let dict = toDict(input) {
        return formatDictionary(dict, indent: 0)
    } else if let arr = input as? [Any] {
        return formatArray(arr, indent: 0)
    } else {
        return "\(String(describing: input))"
    }
}

// MARK: - Helpers

fileprivate func toDict(_ input: Any) -> [String: Any]? {
    // If already a dictionary
    if let dict = input as? [String: Any] {
        return dict
    }
    // If JSON Data
    if let data = input as? Data {
        if let obj = try? JSONSerialization.jsonObject(with: data, options: []),
           let dict = obj as? [String: Any] {
            return dict
        }
    }
    // If String containing JSON
    if let s = input as? String {
        if let data = s.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data, options: []),
           let dict = obj as? [String: Any] {
            return dict
        }
    }
    // If a struct/class: try Mirror -> dictionary
    if let mirrored = mirrorToDictionary(input) {
        return mirrored
    }
    return nil
}

fileprivate func mirrorToDictionary(_ any: Any) -> [String: Any]? {
    let mirror = Mirror(reflecting: any)
    // If it's an Optional none
    if mirror.displayStyle == .optional {
        if mirror.children.count == 0 { return nil }
        let child = mirror.children.first!.value
        return mirrorToDictionary(child) ?? (child as? [String:Any])
    }
    // Only convert structs / classes
    if mirror.children.count == 0 {
        return nil
    }
    var dict: [String: Any] = [:]
    for child in mirror.children {
        guard let label = child.label else { continue }
        let value = child.value
        // If child is another struct, try converting recursively
        if let subDict = mirrorToDictionary(value) {
            dict[label] = subDict
        } else if let arr = value as? [Any] {
            // Map inner elements
            var mapped: [Any] = []
            for e in arr {
                if let sd = mirrorToDictionary(e) {
                    mapped.append(sd)
                } else {
                    mapped.append(e)
                }
            }
            dict[label] = mapped
        } else {
            dict[label] = value
        }
    }
    return dict
}

fileprivate func formatDictionary(_ dict: [String: Any], indent: Int) -> String {
    // Recognize common keys (case-insensitive)
    // If this looks like an assessment (probabilities, posterior/prior, risk_level, factors),
    // format those parts specially; otherwise, pretty-print sorted keys.
    let loweredKeys = Dictionary(uniqueKeysWithValues: dict.keys.map { ($0.lowercased(), $0) })
    var outLines: [String] = []
    let prefix = String(repeating: "  ", count: indent)
    // 1) Probabilities / posterior/prior/likelihood
    if let probKey = findFirstKey(in: loweredKeys, variants: ["posterior", "prior", "likelihood", "probability", "probabilities", "posterior_probability", "posteriorProbability"]) {
        if let val = dict[probKey] {
            outLines.append("\(prefix)Probability / Posterior:")
            outLines.append(contentsOf: formatValue(val, indent: indent + 1).map { "\(prefix)\($0)" })
        }
    }
    // 2) Risk level
    if let riskKey = findFirstKey(in: loweredKeys, variants: ["risk_level", "risklevel", "risk", "risk-level"]) {
        if let val = dict[riskKey] {
            outLines.append("\(prefix)Risk level: \(stringify(val))")
        }
    }
    // 3) Adjusted impact / weight / impact
    if let adjKey = findFirstKey(in: loweredKeys, variants: ["adjusted_impact", "adjustedImpact", "impact", "weight"]) {
        if let val = dict[adjKey] {
            outLines.append("\(prefix)Impact: \(fmtNumber(val))")
        }
    }
    // 4) Factors / factor_influences
    if let factorsKey = findFirstKey(in: loweredKeys, variants: ["factor_influences", "factorinfluences", "factors", "influences", "factorInfluences"]) {
        if let val = dict[factorsKey] {
            outLines.append("\(prefix)Factors:")
            let factorLines = parseFactorInfluences(val, indent: indent + 1)
            if factorLines.isEmpty {
                outLines.append("\(prefix)  (no factors / no evidence provided)")
            } else {
                outLines.append(contentsOf: factorLines.map { "\(prefix)\($0)" })
            }
        }
    }
    // 5) Explanation
    if let explKey = findFirstKey(in: loweredKeys, variants: ["explanation", "explain", "explanations"]) {
        if let val = dict[explKey] {
            outLines.append("\(prefix)Explanation:")
            outLines.append(contentsOf: formatValue(val, indent: indent + 1).map { "\(prefix)\($0)" })
        }
    }
    // After extracting known pieces, present remaining keys deterministically
    // Remove keys already consumed
    var consumed = Set<String>()
    for k in ["posterior","prior","likelihood","probability","probabilities","posterior_probability","posteriorProbability","risk_level","risklevel","risk","risk-level","adjusted_impact","adjustedImpact","impact","weight","factor_influences","factorinfluences","factors","influences","factorInfluences","explanation","explain","explanations"] {
        if let original = loweredKeys[k] {
            consumed.insert(original)
        }
    }
    // Remaining keys
    let remaining = dict.keys.filter { !consumed.contains($0) }.sorted { $0.lowercased() < $1.lowercased() }
    if !remaining.isEmpty {
        outLines.append("\(prefix)Details:")
        for key in remaining {
            let val = dict[key]!
            // For simple values show inline, for complex values use indentation
            if isSimpleValue(val) {
                outLines.append("\(prefix)  \(key): \(fmtInline(val))")
            } else {
                outLines.append("\(prefix)  \(key):")
                let nested = formatValue(val, indent: indent + 2)
                outLines.append(contentsOf: nested.map { "\(prefix)\($0)" })
            }
        }
    }
    if outLines.isEmpty {
        // Fallback: pretty-print sorted keys
        outLines = prettyPrintUnknown(dict: dict, indent: indent)
    }
    return outLines.joined(separator: "\n")
}

fileprivate func formatArray(_ arr: [Any], indent: Int) -> String {
    let prefix = String(repeating: "  ", count: indent)
    if arr.isEmpty {
        return "\(prefix)(empty array)"
    }
    var lines: [String] = []
    for (i, el) in arr.enumerated() {
        if isSimpleValue(el) {
            lines.append("\(prefix)- \(fmtInline(el))")
        } else if let d = toDict(el) {
            lines.append("\(prefix)-")
            let nested = formatDictionary(d, indent: indent + 1)
            lines.append(nested)
        } else if let subarr = el as? [Any] {
            lines.append("\(prefix)- [array size: \(subarr.count)]")
            lines.append(formatArray(subarr, indent: indent + 1))
        } else {
            lines.append("\(prefix)- \(String(describing: el))")
        }
    }
    return lines.joined(separator: "\n")
}

fileprivate func formatValue(_ value: Any, indent: Int) -> [String] {
    let prefix = String(repeating: "  ", count: indent)
    // If simple
    if isSimpleValue(value) {
        return ["\(prefix)\(fmtInline(value))"]
    }
    // If dictionary-like
    if let d = toDict(value) {
        // reuse formatDictionary which returns a String; we need to split lines and add prefix trimmed
        let formatted = formatDictionary(d, indent: indent)
        return formatted.components(separatedBy: "\n")
    }
    if let arr = value as? [Any] {
        // Format array items each on a new line
        var lines: [String] = []
        for el in arr {
            if isSimpleValue(el) {
                lines.append("\(prefix)- \(fmtInline(el))")
            } else if let elDict = toDict(el) {
                lines.append("\(prefix)-")
                let nested = formatDictionary(elDict, indent: indent + 1)
                lines.append(nested)
            } else if let subarr = el as? [Any] {
                lines.append("\(prefix)- [array size: \(subarr.count)]")
                lines.append(contentsOf: formatValue(subarr, indent: indent + 1))
            } else {
                lines.append("\(prefix)- \(String(describing: el))")
            }
        }
        return lines
    }
    // Last resort
    return ["\(prefix)\(String(describing: value))"]
}

fileprivate func prettyPrintUnknown(dict: [String: Any], indent: Int) -> [String] {
    let prefix = String(repeating: "  ", count: indent)
    var lines: [String] = []
    let sortedKeys = dict.keys.sorted { $0.lowercased() < $1.lowercased() }
    for key in sortedKeys {
        let val = dict[key]!
        if isSimpleValue(val) {
            lines.append("\(prefix)\(key): \(fmtInline(val))")
        } else if let subDict = toDict(val) {
            lines.append("\(prefix)\(key):")
            lines.append(contentsOf: formatDictionary(subDict, indent: indent + 1).components(separatedBy: "\n"))
        } else if let arr = val as? [Any] {
            lines.append("\(prefix)\(key):")
            lines.append(contentsOf: formatArray(arr, indent: indent + 1).components(separatedBy: "\n"))
        } else {
            lines.append("\(prefix)\(key): \(String(describing: val))")
        }
    }
    return lines
}

fileprivate func parseFactorInfluences(_ input: Any, indent: Int) -> [String] {
    // Expect array of factors (dictionaries), but accept many shapes
    let prefix = String(repeating: "  ", count: indent)
    var lines: [String] = []
    var arr: [Any] = []
    if let a = input as? [Any] {
        arr = a
    } else if let d = toDict(input) {
        // Maybe a keyed dictionary where values are factor dicts
        let sortedKeys = d.keys.sorted { $0.lowercased() < $1.lowercased() }
        for k in sortedKeys {
            if let v = d[k] {
                arr.append(v)
            }
        }
    } else {
        return []
    }
    if arr.isEmpty { return [] }
    for item in arr {
        // Get a dictionary for the factor
        var factor: [String: Any] = [:]
        if let fd = item as? [String: Any] {
            factor = fd
        } else if let md = mirrorToDictionary(item) {
            factor = md
        } else {
            // Fallback: print raw
            lines.append("\(prefix)- \(String(describing: item))")
            continue
        }
        // Extract common fields with tolerant keys
        let lowered = Dictionary(uniqueKeysWithValues: factor.keys.map { ($0.lowercased(), $0) })
        func g(_ variants: [String]) -> Any? {
            if let found = findFirstKey(in: lowered, variants: variants) {
                return factor[found]
            }
            return nil
        }
        let name = (g(["name", "factor", "label", "id"]) as? String) ?? (g(["name", "factor", "label", "id"]).map { String(describing: $0) } ?? "unnamed")
        let weight = g(["weight", "impact", "adjusted_impact", "adjustedimpact"])
        let explanation = g(["explanation", "explain", "reason", "note"])
        // Compose lines per factor
        var firstLine = "\(prefix)- \(name)"
        if let w = weight {
            firstLine += " (impact: \(fmtNumber(w)))"
        }
        lines.append(firstLine)
        if let expl = explanation {
            let explLines = formatValue(expl, indent: indent + 1)
            lines.append(contentsOf: explLines)
        }
        // Include any remaining non-empty detail keys
        let consumedKeys = Set(["name","factor","label","id","weight","impact","adjusted_impact","adjustedimpact","explanation","explain","reason","note"])
        let remaining = factor.keys.filter { !consumedKeys.contains($0.lowercased()) }.sorted { $0.lowercased() < $1.lowercased() }
        for rk in remaining {
            let v = factor[rk]!
            if isSimpleValue(v) {
                lines.append("\(prefix)  \(rk): \(fmtInline(v))")
            } else {
                lines.append("\(prefix)  \(rk):")
                lines.append(contentsOf: formatValue(v, indent: indent + 2))
            }
        }
    }
    return lines
}

// MARK: Utility functions

fileprivate func findFirstKey(in lowerToOriginal: [String: String], variants: [String]) -> String? {
    for v in variants {
        if let orig = lowerToOriginal[v.lowercased()] {
            return orig
        }
    }
    return nil
}

fileprivate func isSimpleValue(_ v: Any) -> Bool {
    switch v {
    case is String, is Int, is Int8, is Int16, is Int32, is Int64, is UInt, is UInt8, is UInt16, is UInt32, is UInt64, is Double, is Float, is Bool, is NSNull:
        return true
    default:
        return false
    }
}

fileprivate func fmtInline(_ v: Any) -> String {
    if let num = fmtNumberNullable(v) {
        return num
    }
    if let s = v as? String {
        return s
    }
    if let b = v as? Bool {
        return b ? "true" : "false"
    }
    if v is NSNull {
        return "null"
    }
    return String(describing: v)
}

fileprivate func stringify(_ v: Any) -> String {
    if let s = v as? String { return s }
    if let n = fmtNumberNullable(v) { return n }
    return String(describing: v)
}

fileprivate func fmtNumber(_ v: Any) -> String {
    return fmtNumberNullable(v) ?? String(describing: v)
}

fileprivate func fmtNumberNullable(_ v: Any) -> String? {
    // Try to convert to Double / Decimal
    if let d = v as? Double { return formatDouble(d) }
    if let f = v as? Float { return formatDouble(Double(f)) }
    if let i = v as? Int { return formatDouble(Double(i)) }
    if let i64 = v as? Int64 { return formatDouble(Double(i64)) }
    if let ui = v as? UInt { return formatDouble(Double(ui)) }
    if let s = v as? String {
        // Try to parse
        if let d = Double(s) { return formatDouble(d) }
        return nil
    }
    return nil
}

fileprivate func formatDouble(_ d: Double) -> String {
    // Format with up to 3 decimal places, trim trailing zeros deterministically
    // Use Decimal to avoid some floating representation issues
    let decimal = Decimal(d)
    var rounded = decimal
    var roundedString: String = ""
    NSDecimalRound(&rounded, &rounded, 3, .plain)
    // Use NumberFormatter for locale-independent formatting (use en_US_POSIX)
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 3
    formatter.minimumFractionDigits = 0
    formatter.usesGroupingSeparator = false
    if let s = formatter.string(from: rounded as NSDecimalNumber) {
        roundedString = s
    } else {
        // Fallback
        roundedString = String(format: "%.3f", (d))
    }
    // Trim trailing zeros and trailing dot
    if roundedString.contains(".") {
        while roundedString.last == "0" {
            roundedString.removeLast()
        }
        if roundedString.last == "." {
            roundedString.removeLast()
        }
    }
    return roundedString
}
