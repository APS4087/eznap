---
name: build
description: Build the EzNap Xcode project and report any errors or warnings.
disable-model-invocation: true
allowed-tools: Bash
---

Build EzNap using xcodebuild and report the result.

## Steps

1. Check that the `.xcodeproj` exists. If not, run `xcodegen generate` first.

2. Run the build:
```bash
xcodebuild -project eznap.xcodeproj \
  -scheme EzNap \
  -configuration Debug \
  -destination 'platform=macOS' \
  build \
  2>&1 | xcpretty || xcodebuild -project eznap.xcodeproj -scheme EzNap -configuration Debug -destination 'platform=macOS' build
```

3. Report:
   - **BUILD SUCCEEDED**: List any warnings grouped by file
   - **BUILD FAILED**: Show errors with file:line references, then suggest fixes

4. If there are Swift 6 concurrency errors (common with ScreenCaptureKit), note the specific actor isolation issue and propose the fix.
