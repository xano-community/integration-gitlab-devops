function "gitlab_create_merge_request" {
  description = "Create a new merge request in a GitLab project"
  input {
    text project_id { description = "Project ID or URL-encoded path" }
    text source_branch { description = "Source branch name" }
    text target_branch { description = "Target branch name" }
    text title { description = "Merge request title" }
    text description? { description = "Merge request description (Markdown supported)" }
    int assignee_id? { description = "User ID to assign" }
    text labels? { description = "Comma-separated label names" }
    bool remove_source_branch?=false { description = "Remove source branch after merge" }
  }
  stack {
    var $params {
      value = {
        source_branch: $input.source_branch,
        target_branch: $input.target_branch,
        title: $input.title,
        remove_source_branch: $input.remove_source_branch
      }
    }
    var.update $params { value = $params|set_ifnotempty:"description":$input.description }
    var.update $params { value = $params|set_ifnotempty:"assignee_id":$input.assignee_id }
    var.update $params { value = $params|set_ifnotempty:"labels":$input.labels }

    api.request {
      url = "https://gitlab.com/api/v4/projects/" ~ $input.project_id ~ "/merge_requests"
      method = "POST"
      headers = ["PRIVATE-TOKEN: " ~ $env.GITLAB_ACCESS_TOKEN, "Content-Type: application/json"]
      params = $params
      mock = {
        "creates merge request successfully": { response: { status: 201, result: { id: 2001, iid: 15, title: "Add new feature", state: "opened", web_url: "https://gitlab.com/my-group/my-project/-/merge_requests/15", created_at: "2026-03-17T10:00:00Z" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "GitLab API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates merge request successfully" {
    input = { project_id: "12345", source_branch: "feature-branch", target_branch: "main", title: "Add new feature" }
    expect.to_equal ($response.iid) { value = 15 }
    expect.to_equal ($response.state) { value = "opened" }
  }
}