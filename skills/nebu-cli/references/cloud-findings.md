# Cloud findings

`nebu findings cloud list|get` reads the findings raised on the user's connected cloud accounts, with their own ids, filters and columns (`FINDING_ID SEVERITY RISK STATUS FLAG CLASS RESOURCE TITLE`).

```
nebu findings cloud list --severity critical,high --status open
nebu findings cloud list --project <cloud_project_id>      # or --env <env_id>, not both
nebu findings cloud get <finding_id> [--full]
```

The account needs NebuSec Cloud Security, and an API key needs permission to read cloud findings.
With one cloud project no scope is needed; with several, exit 2 asks for `--project` or `--env`.
To mark or pin a cloud finding, use the `cloud:…` id `nebu findings list` prints for it ([findings.md](findings.md)).
