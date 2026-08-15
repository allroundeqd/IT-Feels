# Contributing to IT-Feels Music 
Thank you for your interest in contributing to IT-Feels Music! We welcome contributions from developers, testers, and designers. 

## How Can You Contribute? 
1. **Reporting Bugs:** Open detailed bug reports when you encounter unexpected behavior. 
2. **Suggesting Features:** Propose ideas to enhance user experience or performance. 
3. **Submitting Pull Requests:** Fix known bugs, refine the UI, or build roadmap features. 
4. **Device Testing:** Test audio focus, background playback, and widgets across different Android manufacturer skins. 

--- 

## Development Workflow 

### 1. Branching Strategy 
- The primary active branch is `it-feels-branch`. 
- Always branch off `it-feels-branch` for feature work or bug fixes: 
```bash 
git checkout it-feels-branch 
git pull origin it-feels-branch 
git checkout -b feat/my-new-feature
```

### 2. Environment Setup
Flutter SDK 3.12.2 or higher.
Java JDK 17.
Verify your environment with:
```bash
flutter doctor
```

### 3. Code Standards & Build Generation
Check for analysis issues:
```bash
flutter analyze
```
If you modify Isar database models, regenerate schemas:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Commit Message Format
Please follow Conventional Commits:
- feat: add 5-band audio equalizer controls
- fix: resolve notification dismiss issue on Android 13
- docs: update build instructions in README
- refactor: optimize Isar query in playlist repository

### Submitting a Pull Request
Ensure your code passes flutter analyze.
Push your branch to your fork:
```bash
git push origin feat/my-new-feature
```
Open a Pull Request targeting it-feels-branch.
Include a clear description of changes and attach screenshots/GIFs for UI modifications.
