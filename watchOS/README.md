# Traintime PDA for Apple Watch

This directory contains the native SwiftUI companion app for watchOS.

The iPhone app remains the source of truth. It expands the current class table
into a full-semester snapshot and stores it on the native iOS side. Each time
the watch app becomes active, it progressively requests:

1. today;
2. the next 14 days;
3. the full semester in small chunks.

The watch persists the completed semester snapshot for offline viewing. Its
three-dot view switcher provides the next-course, course-list, day, and week
views. Course colors use the same Material color sequence as the Flutter phone
interface.

The first version intentionally relies on iOS notification forwarding for class
reminders. A watch-local notification scheduler can be added after a single
notification owner setting is available, avoiding duplicate alerts.
