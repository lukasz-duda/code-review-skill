# Code review skill

Code review for GitLab merge requests.

Requirements:

- [Docker](https://www.docker.com/)

Start:

- Set `GITLAB_HOST` to the GitLab hostname, such as `gitlab.com`.
- Put the GitLab access token in `gitlab_token.txt` and restrict it with `chmod 600 gitlab_token.txt`.
- Keep token files local; they are ignored by Git.
- TLS verification is enabled by default. For a temporary connection to a server with an untrusted certificate, run `GITLAB_SKIP_TLS_VERIFY=true ./start.sh`; this weakens security and should only be used when necessary.

```bash
./start.sh
```
