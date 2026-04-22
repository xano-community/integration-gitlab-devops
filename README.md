# GitLab Integration for Xano

Create issues, open merge requests, manage projects, and configure webhooks with the GitLab integration for Xano.

## Functions

| Function | Description |
| --- | --- |
| `gitlab_create_issue` | Create a new issue in a GitLab project. |
| `gitlab_list_projects` | List GitLab projects accessible to the authenticated user. |
| `gitlab_create_merge_request` | Create a new merge request in a GitLab project. |
| `gitlab_list_merge_requests` | List merge requests for a GitLab project with filtering. |
| `gitlab_create_webhook` | Create a webhook to receive events from a GitLab project. |

## Install

### Option A — Ask Claude Code

With the [Xano MCP](https://github.com/xano-labs/mcp-server) enabled in Claude Code, paste this into Claude:

> Install the integration at https://github.com/xano-community/integration-gitlab-devops into my Xano workspace.

Claude will clone the repo and push the functions to your workspace.

### Option B — Use the Xano CLI

1. Install and authenticate the [Xano CLI](https://docs.xano.com/cli):
   ```sh
   npm install -g @xano/cli
   xano auth
   ```

2. Clone and push this integration:
   ```sh
   git clone https://github.com/xano-community/integration-gitlab-devops.git
   cd integration-gitlab-devops
   xano workspace:push . -w <your-workspace-id>
   ```

   Replace `<your-workspace-id>` with the ID from `xano workspace:list`.

## Configure Credentials

1. Log in to your GitLab account at gitlab.com (or your self-managed instance).
2. Go to User Settings > Access Tokens.
3. Create a new personal access token with the `api` scope.
4. In Xano, set the following environment variable:
   - `GITLAB_ACCESS_TOKEN` — your personal access token

Environment variables used by this integration:

- `GITLAB_ACCESS_TOKEN`

See `.env.example` for a template.

## Usage

Call any function from another function, task, or API endpoint using `function.run`:

```xs
function.run "gitlab_create_issue" {
  input = {
    // See function signature for required parameters
  }
} as $result
```

## Function Reference

### `gitlab_create_issue`

Creates an issue with a title and optional description, labels, assignees, due date, and confidentiality flag. Use this to programmatically file bug reports, feature requests, or tasks from your Xano app.

### `gitlab_list_projects`

Returns a paginated list of projects with optional filtering by search term, visibility, and membership. Use this to build project selectors or sync project metadata into your Xano database.

### `gitlab_create_merge_request`

Opens a merge request from a source branch to a target branch with a title and optional description, assignee, labels, and auto-delete source branch setting. Use this to automate code review workflows from your app.

### `gitlab_list_merge_requests`

Returns a paginated list of merge requests filtered by state (opened, closed, merged, all) and labels. Use this to build MR dashboards or track deployment pipelines.

### `gitlab_create_webhook`

Registers a webhook URL on a project with configurable event triggers for pushes, issues, and merge requests. Supports secret token validation and SSL verification. Use this to set up real-time event notifications from GitLab.

## License

MIT — see [LICENSE](./LICENSE).
