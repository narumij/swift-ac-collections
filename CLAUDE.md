# Session Startup

At the beginning of every session, read `Tests/CLAUDE.md` before doing any work and follow its instructions.

# Communication

Communicate with the user in Japanese. Internal instructions and Codex-to-Claude work requests may be written in English, but explanations, questions, progress updates, and final reports addressed to the user must be in Japanese.

For assignments managed through `Maintanance/CLAUDE_TASK.md`, do not send progress
updates, startup summaries, or completion details to the user. Put all handoff details
in the assigned Markdown file for Codex. If the chat interface requires a final
response after successful completion, respond with exactly `完了` and nothing else.
Only explain details directly when blocked, when a safety issue is found, or when a
decision that only the user can make is required.

# Workspace Boundary

Work only inside `/Users/narumij/Documents/GitHub/swift-ac-collections`.

Do not read, search, create, modify, or delete files outside this repository,
except for a dedicated disposable directory created by this task under the
system temporary directory. In particular, do not inspect parent directories,
the user's home directory, Xcode caches, DerivedData, global SwiftPM caches, or
unrelated contents of system temporary directories.

If a command requests permission to access any other path outside the repository,
cancel it. Ask the user before accessing any external path other than the
task-owned temporary directory, even for read-only investigation.

Prefer terminal output over temporary files. If temporary output is unavoidable,
create a uniquely named task directory with `mktemp -d` under the system temporary
directory, use only that resolved path, and remove it before the final report.
Do not inspect neighboring temporary files or use broad wildcards when cleaning up.

Do not place scratch files, captured compiler output, generated comparison
sources, assembly, or reversible experiment artifacts anywhere inside the
repository, including `.build`, the repository root, source directories, test
directories, and maintenance directories. Files intentionally retained as test
fixtures, benchmark source, or recorded raw benchmark evidence are not scratch
files; name and report them explicitly.
