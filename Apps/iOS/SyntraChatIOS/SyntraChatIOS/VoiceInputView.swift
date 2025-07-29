/*
 * VoiceInputView.swift - DEPRECATED
 * 
 * This custom voice-to-text implementation has been removed as part of the migration
 * to Apple's native dictation support. As documented in os changes.md:
 *
 * - Native Apple text fields (UITextView/TextField) include robust, automatic dictation
 * - Custom Swift voice UI is fragile and prone to threading crashes in iOS betas
 * - Native components are always thread-safe and maintained by Apple
 * 
 * Users now get voice input through the native dictation mic that appears automatically
 * on the keyboard when using standard text input fields.
 *
 * Migration completed: Voice functionality replaced with native UITextView dictation
 * Date: Based on os changes.md migration plan
 */

// This file has been deprecated - voice functionality now provided by native iOS dictation 