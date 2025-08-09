# 🍎 SYNTRA Chat iOS — Native & API Integration

## Overview

My motivation for this project began with simple curiosity—a pet project meant as a diagnostic tool. It has since transformed into what you see in this repository. With a “why not?” mentality, I’ve invested significant time and multidisciplinary learning. This isn’t the end for Syntra; it’s opened new doors for creativity that I’m excited to explore.

---

### 🧠 SYNTRA

**Symbolic Neural Transduction and Reasoning Architecture**  
The central AI system, fusing symbolic reasoning with real-world signals. Contains VALON, MODI, and SYNTRA Core.

### 🔧 MODI

**Mechanistic Observation and Diagnostic Intelligence**  
Grounded logic—tracks drift, evaluates sensor patterns, handles deductive cognition.

### 🔮 VALON

**Variable Abstraction and Lateral Ontologic Network**  
The creative/emotional brain—handles abstraction, emotional anchoring, and nonlinear reasoning.

---

## Server/API Layer (NEW 🆕)

**Syntra API Layer** is now included—enabling OpenAI-compatible HTTP endpoints on localhost, powered by a Swift-native backend and FoundationModels LLMs.

### ✨ Highlights

- **OpenAI-style REST Endpoints** (`/v1/chat/completions`, `/v1/models`, etc.)
- **Streaming & Non-streaming** chat completions
- **SyntraCLIWrapper** bridge: secure, task-isolated CLI for LLM model execution
- **Health Checks**: `/api/health`
- **macOS 26+, Xcode 26+, Apple Silicon only**

See [output-from-debug.md] for sample logs and behavior.

---

## 🏗️ Architecture

### iOS-Native Client

- **NavigationStack**: Modern iOS navigation
- **Bottom Input Bar**: Feels truly native
- **Haptic Feedback**: For all key state changes
- **Settings Form**: iOS standards, live rebindings
- **Pull-to-Refresh & Accessibility**: For all users

### API Layer

- **Fully async Swift concurrency**
- **Robust HTTP/1.1 parser** with body size guarantee & streaming responses
- **OpenAI-compatible JSON schemas**
- **Modular endpoint logic—easy to extend and document**
- **CLI Isolation**: All LLM work delegated to a separate process (hardening)

---

## 🚀 Quick Start

### Prerequisites

- **macOS 26+ (Tahoe)**, Apple Silicon required
- **Xcode 26+** + latest Swift toolchain
- **iOS 26+ Device or Simulator**
- [Optional] Docker/Podman for container builds

### Building & Running

#### iOS App

