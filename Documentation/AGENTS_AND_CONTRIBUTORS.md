## Recent Changes and Rationale
- Implemented auto reentry and state persistence: Saves brain/UI state on changes and restores on launch for seamless recovery from crashes/interruptions (real impl, no stubs).
- Enhanced logging with disk syncing and rotation: Prevents memory overload, ensures logs persist.
- Added speech error handling: Graceful retry for 'no speech detected' errors.
- Fixed concurrency warnings: Ensured async safety in key areas.

These changes improve app reliability per Work Requested.md playbook. 