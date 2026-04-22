function "gitlab_create_issue" {
  description = "Create a new issue in a GitLab project"
  input {
    text project_id { description = "Project ID or URL-encoded path (e.g. my-group%2Fmy-project)" }
    text title { description = "Issue title" }
    text description? { description = "Issue description (Markdown supported)" }
    text labels? { description = "Comma-separated label names" }
    json assignee_ids? { description = "Array of user IDs to assign" }
    bool confidential?=false { description = "Mark issue as confidential" }
    text due_date? { description = "Due date in YYYY-MM-DD format" }
  }
  stack {
    var $params {
      value = {
        title: $input.title,
        confidential: $input.confidential
      }
    }
    var.update $params { value = $params|set_ifnotnull:"description":$input.description }
    var.update $params { value = $params|set_ifnotnull:"labels":$input.labels }
    var.update $params { value = $params|set_ifnotnull:"assignee_ids":$input.assignee_ids }
    var.update $params { value = $params|set_ifnotnull:"due_date":$input.due_date }

    api.request {
      url = "https://gitlab.com/api/v4/projects/" ~ $input.project_id ~ "/issues"
      method = "POST"
      headers = ["PRIVATE-TOKEN: " ~ $env.GITLAB_ACCESS_TOKEN, "Content-Type: application/json"]
      params = $params
      mock = {
        "creates issue successfully": { response: { status: 201, result: { id: 1001, iid: 42, title: "Bug report", state: "opened", web_url: "https://gitlab.com/my-group/my-project/-/issues/42", created_at: "2026-03-17T10:00:00Z" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "GitLab API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates issue successfully" {
    input = { project_id: "12345", title: "Bug report" }
    expect.to_equal ($response.iid) { value = 42 }
    expect.to_equal ($response.state) { value = "opened" }
  }
}