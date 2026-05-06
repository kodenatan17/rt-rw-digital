---
name: flutter-security
description: Enforce security best practices in Flutter features, including token validation, secure communication, and safe data handling.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 19:45:59 GMT
---
## Inject Rules

* Validate auth or safety tokens before protected actions
* Do not log tokens, secrets, or sensitive payloads
* Keep secrets out of source code and client-visible constants
* Reject unvalidated signaling or transport messages
* Prefer short-lived tokens, bounded sessions, and explicit expiry checks
* Isolate session-scoped data and communication channels
* Fail closed on auth, validation, or permission errors
