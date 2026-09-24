// lib/services/location_service.dart
// Handles all GPS interaction: permission check/request, service status, one-time position, position stream.
// Returns typed LocationIssue values — never throws raw platform exceptions to providers.
// Implemented in Phase 2 (permission + one-time) and Phase 4 (stream).
