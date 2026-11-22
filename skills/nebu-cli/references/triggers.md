# Pull request triggers

A trigger starts a scan on its own for each matching pull request of a GitHub repository, each charged to the account when it runs, with no price shown to anyone first; the trigger rule in [SKILL.md](../SKILL.md) says when to create or enable one.

```
nebu triggers list [--repo <repo>]
nebu triggers create --repo <repo> [--depth quick] [--check-behavior fail-high] [--base-branch-mode default]
nebu triggers update --repo <repo> <trigger_id> --disable
nebu triggers logs --repo <repo> [--trigger <trigger_id>]
nebu triggers delete --repo <repo> <trigger_id>
```

`create` without options starts quick reviews on every base branch when a pull request is opened, reopened, synchronized or ready for review, with an informational check; `update` changes only the settings given.
Which pull requests it takes (base branch, source branch, author, changed paths, who may open them) and what it runs are settings: `nebu triggers create --help` and `nebu triggers update --help` list them, with a flag that empties each list.
`triggers logs` shows why a pull request was scanned or skipped, and when GitHub refused the check or the review comments.
