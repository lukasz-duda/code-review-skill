# Code review

Code review for merge request in GitLab.

Requirements:

- [Docker](https://www.docker.com/)

Running:

- Set `GITLAB_HOST` to the GitLab host name, for example `gitlab.com`.
- Set `GITLAB_PATH` to the repository path, for example `group/project`.
- Set `GITLAB_MR_ID` to the ID of the merge request you want to review.
- Set `GITLAB_TOKEN` to the GitLab group access token with the Reporter role and `api`, `read_repository` permissions used for cloning the repository, reviewing merge requests and adding comments.
- Set `GITHUB_TOKEN` to the personal GitHub Fine-grained token with the `Copilot Requests` permission used for making Copilot requests during code review.

```bash
docker build -f agent/Dockerfile -t code-review-agent ./agent
docker run \
    -e GITLAB_HOST=gitlab.com \
    -e GITLAB_PATH=group/project \
    -e GITLAB_MR_ID=1 \
    -e GITLAB_TOKEN=your_gitlab_token \
    -e GITHUB_TOKEN=your_github_token \
    code-review-agent
```
