# Add a repository

```
nebu repos add --github example-org/acme-web --wait            # from the user's GitHub connection
nebu repos add --gitlab example-org/platform/acme-api --wait   # a GitLab project, its whole path
nebu repos add --git-url https://example.com/acme-tool.git --wait   # a public HTTPS Git URL
nebu repos add --path . --wait                                 # upload a local directory
```

- An upload (`--path`) is never matched with an existing repository; the upload rule in [SKILL.md](../SKILL.md) says when to make one.
- `nebu repos list --git-remote github.com/<owner>/<name>` finds a repository already on the platform; an `<owner>/<name>` is not its name there.
  When it lists several (the same source in several projects), `nebu repos get <id>` shows each one's project and the user says which, unless the task is the same for all.
- `--project <project>` adds it to a project; `nebu projects create <name>` makes one (exit 2 when that name exists: use it).
- `--wait` returns when the repository can be scanned (exit 5 if fetching failed, 7 after 15 minutes); without it, `nebu repos get <repo>` shows its `state`.
- A GitHub, GitLab or Git URL source already in that project (or yours, without `--project`) is refused (exit 2): use the one `Next:` names; if it says that one failed, tell the user.
  Add a duplicate (`--allow-duplicate`) only when the user asks.
- Exit 8 here is a GitHub or GitLab connection to make or fix in the web app (exit 8 in [SKILL.md](../SKILL.md)); do not poll or retry.

Next: scan it ([scans.md](scans.md)).
