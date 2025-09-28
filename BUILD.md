 
---

# 📦 web\_view\_sdk – Maintainers Guide

This document explains how to maintain, build, and release the **web\_view\_sdk** and publish updates to the **lib repo**.

---

## 🚀 Build & Release Workflow

The release process is **fully automated** via GitHub Actions. On every push to `main`, the workflow will:

1. **Build the SDK** using Xcode (`xcodebuild archive` for device + simulator).
2. **Package into an `.xcframework`.**
3. **Copy into the `web_view_sdk_lib` repo** (used as the public-facing dependency).
4. **Bump the version number** (patch release).
5. **Commit + tag + push** changes to the lib repo.

---

## 🔧 Local Development

### 1. Build SDK locally

If you need to test a build manually before committing:

```bash
chmod +x ./build_sdk.sh
./build_sdk.sh
```

This will:

* Clean previous builds
* Build device + simulator frameworks
* Create `web_view_sdk.xcframework`
* Copy it into `../web_view_sdk_lib/Sources/`
* Commit + tag + push the new version

---

### 2. Versioning

The script automatically bumps the **patch version** (e.g. `1.0.3 → 1.0.4`).
If you need a **minor** or **major** bump, update the version **manually** in the script before committing.

---

## 🛠️ GitHub Actions Workflow

Located at:

```
.github/workflows/build.yml
```

It:

* Runs on `macos-latest`
* Calls `build_sdk.sh`
* Pushes updated `.xcframework` to the lib repo

### Manual trigger

You can also trigger the workflow manually from the **Actions tab**.

---

## 🔐 Auth & Repo Setup

* `web_view_sdk_lib` must either be:

  * a **submodule/sibling folder**, OR
  * configured as a **separate remote** with write access
* GitHub Actions requires a **Personal Access Token (PAT)** if pushing to a **different repo**.

  * Save it in `Settings → Secrets → Actions` as `LIB_REPO_TOKEN`
  * Update the workflow `git push` step to use it.

---

## 🧪 Testing

Before pushing, run:

```bash
xcodebuild test -scheme web_view_sdk -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 📖 Quick Commands

* **Build & release manually:**

  ```bash
  ./build_sdk.sh
  ```

* **Check version tag:**

  ```bash
  git describe --tags --abbrev=0
  ```

* **Reset build artifacts:**

  ```bash
  rm -rf build web_view_sdk.xcframework
  ```

---

## ✅ Best Practices

* Always test in Simulator + real device before release.
* Keep `main` stable — feature work should go to branches.
* Never commit the raw framework builds, only the `.xcframework` packaged output.
* Tag every release (`v1.0.4`, `v1.0.5`, etc.).

---

### 📌 Summary

* Build automation = `build_sdk.sh` + GitHub Actions.
* Releases go straight into `web_view_sdk_lib`.
* Versions bump automatically (patch by default).
* PAT may be required for pushing cross-repo.

---
 
