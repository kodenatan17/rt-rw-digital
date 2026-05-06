----
name: flutter-web-rtc
description: Implement WebRTC-based real-time communication features in Flutter, including peer connection management, signaling, and media handling.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Sat, 2 May 2026 19:45:59 GMT
---
## Inject Rules

* Use flutter_webrtc

* Wrap:
  RTCPeerConnection inside service

* Handle:

  * offer/answer
  * ICE candidates
  * reconnect

* No WebRTC logic in Bloc
