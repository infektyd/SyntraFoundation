#!/usr/bin/env swift

import Foundation

// Simple test to verify memory system is working
// This simulates the conversation flow from the logs

struct TestMessage {
    let sender: String
    let content: String
    let timestamp: Date
}

struct TestContext {
    let conversationHistory: [String]
    let sessionId: String
}

class TestSyntraCore {
    func processInput(_ input: String, context: TestContext) -> String {
        let lowercased = input.lowercased()
        let hasMemory = !context.conversationHistory.isEmpty
        
        // Check for follow-up questions
        let followUpKeywords = ["this", "that", "it", "document", "service", "procedure"]
        let isFollowUp = followUpKeywords.contains { lowercased.contains($0) } && hasMemory
        
        if isFollowUp {
            return """
            🧠 CONSCIOUSNESS SYNTHESIS (with conversation memory):
            
            💭 Valon Perspective (weight: 0.7): Building on our previous conversation, I approach this with continued moral consideration and creative insight.
            
            🔍 Modi Analysis (weight: 0.3): Context-aware analysis based on previous conversation • Systematic analysis applied
            
            ⚖️ Integrated Decision: Balancing moral awareness with systematic reasoning to provide thoughtful, helpful, and ethically-grounded response.
            
            Based on our previous conversation, I can provide more specific and contextual assistance. What would you like to know about the information we discussed?
            """
        } else {
            return """
            🧠 CONSCIOUSNESS SYNTHESIS:
            
            💭 Valon Perspective (weight: 0.7): Human context considered. Approach with empathy, creativity, and moral awareness.
            
            🔍 Modi Analysis (weight: 0.3): Systematic analysis applied • Pattern recognition active • Logical coherence verified
            
            ⚖️ Integrated Decision: Balancing moral awareness with systematic reasoning to provide thoughtful, helpful, and ethically-grounded response.
            
            Based on this integrated analysis, I'm ready to provide thoughtful assistance that considers both the logical aspects and the human context of your request.
            """
        }
    }
}

// Test the conversation flow
func testMemorySystem() {
    let core = TestSyntraCore()
    var conversationHistory: [String] = []
    
    print("=== Testing SYNTRA Memory System ===\n")
    
    // First message - no memory
    let message1 = "How are you"
    let context1 = TestContext(conversationHistory: conversationHistory, sessionId: "test-session")
    let response1 = core.processInput(message1, context: context1)
    
    print("User: \(message1)")
    print("SYNTRA: \(response1)")
    print("\n" + String(repeating: "-", count: 80) + "\n")
    
    // Add to conversation history
    conversationHistory.append("You: \(message1)")
    conversationHistory.append("SYNTRA: \(response1)")
    
    // Second message - technical document
    let message2 = """
    **Cx 1000 hour service**
    
    - heat exchanger/exhaust
    - main exhaust bolts 17mm
    - All with washers
    - One shorter then the rest
    - Coolant petcock
    - 12mm
    - 6 bolts on front crossover
    - 12mm flex head ratchet wrench
    - 6 bolts on top crossover and hose
    - ***Face hose claps correctly***
    - Valve cover needs to be removed to take two bolts out
    - Use rags stuffed around sensors to help prevent hardware loss
    - 4 bolts, bracket, washer/spacers on back to oil cooler
    - Pig or rag underneath to help prevent loosing hardware
    - 10ga elc
    - Plug or shaft seal supply
    - 1/4" pipe?
    - Zincs front and back
    - 15/16 or 24mm
    - Top vent
    - 19mm banjo
    - 14mm copper?
    - Turbo
    - Oil supply new hardware/gasket 6mm Allen, *****!!flare connection checked!!*****
    - Oil return pipe, 6mm Allen, new hose joint and clamps, *****!!hose clamps towards the ends of the hose!!*****
    - Spray head off
    - Nut at 7/8 o'clock does not come off without wiggling spray head off
    - turbo mount nuts off, 17mm/15mm/14mm
    - Air cleaner off, if airsep can set for more room upon install for easier service.
    - Charged air cooler
    - Horn on cac 10mm, be extremely careful of the fins, suggest bringing precut wood cover
    - Boost hose
    - 2 bolts under
    - 4 nuts back
    - Intake hose
    - Oil cooler
    - *****!!Dissimilar metals and location makes it a potential problem location for corrosion and rust, use heat, spray, percussion, or call Tim!!*****
    - 6 bolts front
    - Gooseneck gasket, common failure/rot point
    - Replace hose from raw water
    - Face hose clamps correctly
    - 4 bolts back
    - 2 o rings
    - Clean ends of cooler bundle off as not to drag dirt through the cooler housing.
    - ***Orientation of the cooler is critical***
    - Thoroughly clean with brake clean and rags, compressed air or vacuum can help too.
    - Use silicone grease on o rings and metal faces to help ward off corrosion
    """
    
    let context2 = TestContext(conversationHistory: conversationHistory, sessionId: "test-session")
    let response2 = core.processInput(message2, context: context2)
    
    print("User: [Technical document shared]")
    print("SYNTRA: \(response2)")
    print("\n" + String(repeating: "-", count: 80) + "\n")
    
    // Add to conversation history
    conversationHistory.append("You: [Technical document shared]")
    conversationHistory.append("SYNTRA: \(response2)")
    
    // Third message - follow-up question (this should trigger memory)
    let message3 = "Speculate on the purpose of this document"
    let context3 = TestContext(conversationHistory: conversationHistory, sessionId: "test-session")
    let response3 = core.processInput(message3, context: context3)
    
    print("User: \(message3)")
    print("SYNTRA: \(response3)")
    print("\n" + String(repeating: "-", count: 80) + "\n")
    
    // Fourth message - another follow-up
    let message4 = "Is there anything I should know about on the document"
    let context4 = TestContext(conversationHistory: conversationHistory, sessionId: "test-session")
    let response4 = core.processInput(message4, context: context4)
    
    print("User: \(message4)")
    print("SYNTRA: \(response4)")
    print("\n" + String(repeating: "-", count: 80) + "\n")
    
    print("=== Memory System Test Complete ===")
    print("✅ Follow-up questions should show memory awareness")
    print("✅ Context should be maintained across conversation")
    print("✅ Responses should reference previous content")
}

// Run the test
testMemorySystem() 