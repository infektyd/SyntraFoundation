//
//  Rules.md
//  SyntraSwift
//
//  Created by Hans Axelsson on 7/20/25.
//

---
description: Implementing code and resolving issues
alwaysApply: false
---
Project Rule 1:

“All agents and contributors must prefer real implementation to stubbing. Any code marked with a stub must be re-addressed and removed as soon as a solution is viable.”

Project Rule 2:

“When designing UI, config toggles, or session logic, default to ‘live binding’—controls change values/behavior instantly and update agents in-memory, not via rebuilds.”

Project Rule 3:

“All architectural/design decisions (including those by AI tools) must be documented in a codex report or markdown in the repo. Major changes with no clear justification should be reverted.”

Project Rule 4:

“New toggles or config options added to SyntraConfig must be fully plumbed from UI → config file → runtime agent logic. All dangling/no-op config UI is forbidden.”

Bonus (Hardening and Compliance)
“All code must pass tests and respect type safety. Silent failing or force-unwrapping is forbidden unless absolutely required and explained.”

“Always update codex_reports/ after substantial work so all progress and decision context is permanent and auditable.”

Project Rule 5: Use Real Data/Behavior in Demos

“Sample chat interfaces or agent demos must run actual Valon/Modi/Core logic—not hardcoded or faked responses—unless dependencies make this absolutely impossible, and that impossibility is logged.”

Project rule 3: Explain Integration Choices

“Anytime you must connect two major modules (UI, agent, pipeline, config), the code and commit message must clearly document why and how the solution fits SyntraFoundation’s system—not just that it compiles.”

project Rule 2: Architecture First, Boilerplate Last

“Always follow and respect the agent/brain architecture and config conventions found in AGENTS.md and config.json. Never introduce boilerplate patterns that don’t mesh with the Syntra paradigm.”

Rule 1: No Placeholder/Stubs

“Never use placeholder, stub, or TODO code unless strictly required. Always attempt a concrete, production-quality Swift implementation—even if partial or annotated with edge cases to resolve. !!!IF ALL ELSE FAILS, ask for help and i will set up an indepth search to find an answer, flag it and we will move on!!!"

Project Rule 6: Beta-Resilient Development

"When developing on beta OS versions, always implement graceful fallbacks and workarounds that preserve core functionality while maintaining architectural integrity. Beta-specific fixes must be clearly documented and designed to be easily removable when the OS issue is resolved."
