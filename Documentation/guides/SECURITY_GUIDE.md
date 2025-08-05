# Security Guide for SYNTRA Foundation

## 🔒 **Critical Security Requirements**

This guide ensures that sensitive information never gets committed to the public repository while preserving all functionality.

## 🚨 **What Should NEVER Be Committed**

### **High Risk - Immediate Removal Required:**
- **IP Addresses**: Any hardcoded IP addresses, server endpoints, or internal network addresses
- **API Keys**: OpenAI, Apple LLM, ElevenLabs, or any other service API keys
- **Database Credentials**: Connection strings, usernames, passwords
- **Personal Information**: Email addresses, phone numbers, real names
- **Internal Configuration**: Company-specific settings, internal URLs

### **Medium Risk - Should Be Sanitized:**
- **Configuration Files**: `config.json` with sensitive paths or settings
- **Log Files**: Build logs with system information
- **Memory Vault Data**: Personal or sensitive consciousness data

## 🛡️ **Protection Strategies**

### **1. Environment Variables (RECOMMENDED)**
```swift
// ✅ CORRECT - Use environment variables
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
let port = UInt16(ProcessInfo.processInfo.environment["SYNTRA_PORT"] ?? "8080")

// ❌ WRONG - Never hardcode sensitive values
let apiKey = "sk-1234567890abcdef"
let port: NWEndpoint.Port = 8080
```

### **2. Template Files for Public Distribution**
- `APIs/Main.example.swift` - Template version of API server
- `config.example.json` - Template configuration
- `Wrappers/SyntraCLIWrapper.example.swift` - Template wrapper

### **3. Local Development Files**
Create these files locally (never commit):
- `.env` - Environment variables
- `config.local.json` - Local configuration
- `secrets.json` - API keys and credentials

## 📋 **Setup Instructions for Contributors**

### **For New Contributors:**
1. **Clone the repository**
2. **Copy template files:**
   ```bash
   cp APIs/Main.example.swift APIs/Main.swift
   cp config.example.json config.local.json
   ```
3. **Set up environment variables:**
   ```bash
   export OPENAI_API_KEY=your_key_here
   export APPLE_LLM_API_KEY=your_key_here
   export SYNTRA_PORT=8080
   ```
4. **Create local configuration:**
   ```json
   {
     "api_keys": {
       "openai": "your_key_here",
       "apple_llm": "your_key_here"
     },
     "server": {
       "port": 8080,
       "host": "localhost"
     }
   }
   ```

### **For Development:**
1. **Use `.env` files** (already in `.gitignore`)
2. **Never commit real credentials**
3. **Test with placeholder values**
4. **Use environment variables for production**

## 🔍 **Pre-Commit Security Checklist**

Before committing any changes:

- [ ] **No hardcoded API keys** in any files
- [ ] **No IP addresses** or server endpoints
- [ ] **No personal information** or credentials
- [ ] **No sensitive configuration** in committed files
- [ ] **Template files** are properly documented
- [ ] **Environment variables** are used for sensitive data
- [ ] **Local files** are in `.gitignore`

## 🚨 **Emergency Response**

### **If You Accidentally Commit Sensitive Data:**

1. **Immediate Action:**
   ```bash
   # Remove from git history
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch path/to/sensitive/file' \
   --prune-empty --tag-name-filter cat -- --all
   ```

2. **Rotate Credentials:**
   - Change all API keys immediately
   - Update any exposed credentials
   - Notify team members

3. **Document the Incident:**
   - Record what was exposed
   - Update security procedures
   - Review access controls

## 📁 **File Organization**

### **Safe for Public Repository:**
- ✅ `APIs/Main.example.swift` - Template version
- ✅ `config.example.json` - Template configuration
- ✅ `Documentation/` - All documentation
- ✅ `Shared/` - Core consciousness modules
- ✅ `Apps/` - iOS application code
- ✅ `tools/` - Build scripts and utilities

### **Never Commit (Protected by .gitignore):**
- ❌ `APIs/Main.swift` - Real API server with credentials
- ❌ `config.local.json` - Local configuration
- ❌ `.env` files - Environment variables
- ❌ `secrets.json` - API keys and credentials
- ❌ `memory_vault/personal/` - Personal data
- ❌ `*.log` files - Build and debug logs

## 🔧 **Development Workflow**

### **Local Development:**
```bash
# 1. Set up environment
export OPENAI_API_KEY=your_key
export APPLE_LLM_API_KEY=your_key

# 2. Use local configuration
cp config.example.json config.local.json
# Edit config.local.json with your settings

# 3. Run with local settings
swift run SyntraAPILayer
```

### **Production Deployment:**
```bash
# 1. Set production environment variables
export SYNTRA_PORT=8080
export OPENAI_API_KEY=prod_key
export APPLE_LLM_API_KEY=prod_key

# 2. Deploy with environment variables
docker run -e OPENAI_API_KEY=$OPENAI_API_KEY syntra-foundation
```

## 📚 **Additional Resources**

- [GitHub Security Best Practices](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository)
- [Open Source Security Guidelines](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository)
- [Environment Variable Best Practices](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository)

## 🎯 **Security Principles**

1. **Defense in Depth**: Multiple layers of protection
2. **Principle of Least Privilege**: Minimal access required
3. **Secure by Default**: Safe configurations out of the box
4. **Continuous Monitoring**: Regular security reviews
5. **Incident Response**: Clear procedures for security issues

---

**Maintained by**: SYNTRA Foundation Project Team  
**Last Updated**: 2025-08-04  
**Security Level**: High - Follow all guidelines strictly 