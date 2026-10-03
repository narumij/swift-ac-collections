# Session Startup

At the beginning of every session, read `Tests/CLAUDE.md` before doing any work and follow its instructions.

# Communication

Communicate with the user in Japanese. Internal instructions and Codex-to-Claude work requests may be written in English, but explanations, questions, progress updates, and final reports addressed to the user must be in Japanese.

# Workspace Boundary

Work only inside `/Users/narumij/Documents/GitHub/swift-ac-collections`.

Do not read, search, create, modify, or delete files outside this repository. In particular, do not inspect parent directories, the user's home directory, Xcode caches, DerivedData, global SwiftPM caches, or system temporary directories.

If a command requests permission to access a path outside the repository, cancel it and use a repository-local alternative. Ask the user before accessing any external path, even for read-only investigation.

Prefer terminal output over temporary files. If temporary output is unavoidable, use a repository-local directory only after confirming that Git ignores it.
