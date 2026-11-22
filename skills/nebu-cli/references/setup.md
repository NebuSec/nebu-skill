# Get ready: install and sign in

Install when `command -v nebu` fails (Linux and macOS, x64 and arm64):

```
curl -fsSL https://raw.githubusercontent.com/NebuSec/nebu-skill/main/install.sh | sh
```

or `npm install -g @nebusec/nebu`.

Sign in with `nebu auth login` (it opens the sign-in page; `nebu auth login --headless` prints a link and a code for a machine without a browser).
On that page the user picks the sign-in's permission:

- **read**: see projects, repositories, scans and findings; spends nothing.
- **triage**: read, and change a finding's status, severity or pin.
- **write**: triage, and create and run work: projects, repositories, estimates, scans, patches, fix pull requests, triggers.

Tell the user the lowest level the job needs.
A command above the sign-in's level is refused, exit 1, with a `Next:` line naming the permission to choose.
Relay that and stop: only the user can choose a level, on the sign-in page.

Check before anything else; it never signs in or out:

```
nebu auth status --json
# {…,"sign_in":{…,"ends_at":"…Z",…,"kind":"browser"},"signed_in":true,"source":"stored browser session","user":"…"}
```

Exit 3: signing in again is the fix (`error.message` says why).
Exit 1 or 4 (network, an unwritable home, an `--api-url` that is not the platform): it is not; do not loop on `nebu auth login`.

Unattended use (a pipeline, a scheduled job) signs in with an API key that the user creates in the web app and sets as the environment variable `NEBUSEC_PLATFORM_API_KEY` where `nebu` runs; it wins over a stored sign-in.
The user sets it themselves: the secrets rule in [SKILL.md](../SKILL.md) applies.
`NEBU_HOME` names a separate CLI home (its own sign-in and settings) for a second account: create the directory and keep it exported, from before `nebu auth login` on.
