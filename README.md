# nx release: empty changelog for a project bumped through a dependency

Minimal reproduction (Nx 23.1.3, `projectsRelationship: independent`, `conventionalCommits: true`).
A project is bumped because a non-releasable library it depends on changed, but its changelog is empty because the commit did not touch the project itself.

## Layout

| project  | releasable | notes                     |
|----------|------------|---------------------------|
| `app`    | yes        | depends on `shared`       |
| `shared` | no         | not in `release.projects` |

## Reproduce

    npm install
    ./scripts/repro.sh

The repo already carries the `app@1.0.0` tag (the baseline release).
The script commits `fix: handle edge case in shared lib`, which only touches `libs/shared/index.js`, then runs `nx release`.

## Actual

`app` is bumped to `1.0.1` (expected: the commit is relevant to it through the project graph), but its changelog is:

    ## 1.0.1
    This was a version bump only for app to align it with other projects, there were no code changes.

## Expected

The changelog lists the commit that caused the bump, `fix: handle edge case in shared lib`.

## Cause

- Versioning picks relevant commits with the project graph (`getCommitsRelevantToProjects` -> `filterAffected`), so commits touching a dependency count.
- The changelog picks commits with `filterProjectCommits`, which only keeps commits touching a path under the project's own root (`c.affectedFiles.find(f => f.startsWith(projectPath))`).
