import SwiftUI

/// Celtic Knot App Icon Generator
/// Creates the beautiful interwoven knot design with gradient background
struct CelticKnotIcon: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background gradient (blue to purple)
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.8, blue: 1.0), // Light blue
                    Color(red: 0.2, green: 0.4, blue: 0.8), // Medium blue
                    Color(red: 0.3, green: 0.2, blue: 0.6)  // Deep purple
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Celtic knot pattern
            CelticKnotPattern()
                .stroke(Color.white, lineWidth: size * 0.08)
                .frame(width: size * 0.7, height: size * 0.7)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
    }
}

/// The actual Celtic knot pattern
struct CelticKnotPattern: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2
        let radius = min(width, height) * 0.3
        
        var path = Path()
        
        // Create the interwoven knot pattern
        // This creates a complex 6-sided knot that weaves over and under itself
        
        // Outer hexagon points
        let points = (0..<6).map { i in
            let angle = Double(i) * .pi / 3
            return CGPoint(
                x: centerX + radius * CGFloat(cos(angle)),
                y: centerY + radius * CGFloat(sin(angle))
            )
        }
        
        // Inner hexagon points (smaller)
        let innerRadius = radius * 0.6
        let innerPoints = (0..<6).map { i in
            let angle = Double(i) * .pi / 3 + .pi / 6 // Offset by 30 degrees
            return CGPoint(
                x: centerX + innerRadius * CGFloat(cos(angle)),
                y: centerY + innerRadius * CGFloat(sin(angle))
            )
        }
        
        // Draw the interwoven pattern
        for i in 0..<6 {
            let currentPoint = points[i]
            let nextPoint = points[(i + 1) % 6]
            let innerPoint = innerPoints[i]
            let nextInnerPoint = innerPoints[(i + 1) % 6]
            
            // Outer connection
            path.move(to: currentPoint)
            path.addLine(to: nextPoint)
            
            // Inner connection (weaves under)
            path.move(to: innerPoint)
            path.addLine(to: nextInnerPoint)
            
            // Cross connections
            path.move(to: currentPoint)
            path.addLine(to: innerPoint)
        }
        
        // Add the weaving pattern (over-under effect)
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3
            let midRadius = radius * 0.8
            
            let startPoint = CGPoint(
                x: centerX + midRadius * CGFloat(cos(angle)),
                y: centerY + midRadius * CGFloat(sin(angle))
            )
            
            let endPoint = CGPoint(
                x: centerX + midRadius * CGFloat(cos(angle + .pi / 6)),
                y: centerY + midRadius * CGFloat(sin(angle + .pi / 6))
            )
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        return path
    }
}

/// Preview for development
struct CelticKnotIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CelticKnotIcon(size: 200)
                .border(Color.gray, width: 1)
            
            Text("Celtic Knot App Icon")
                .font(.headline)
        }
        .padding()
    }
} 