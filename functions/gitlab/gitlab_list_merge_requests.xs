function "gitlab_list_merge_requests" {
  description = "List merge requests for a GitLab project"
  input {
    text project_id { description = "Project ID or URL-encoded path" }
    text state?="opened" { description = "Filter: opened, closed, locked, merged, all" }
    text labels? { description = "Comma-separated label filter" }
    int per_page?=20 { description = "Results per page (max 100)" }
    int page?=1 { description = "Page number" }
  }
  stack {
    var $query_string { value = "?state=" ~ $input.state ~ "&per_page=" ~ $input.per_page ~ "&page=" ~ $input.page }
    conditional {
      if ($input.labels != null) {
        var.update $query_string { value = $query_string ~ "&labels=" ~ $input.labels }
      }
    }

    api.request {
      url = "https://gitlab.com/api/v4/projects/" ~ $input.project_id ~ "/merge_requests" ~ $query_string
      method = "GET"
      headers = ["PRIVATE-TOKEN: " ~ $env.GITLAB_ACCESS_TOKEN]
      mock = {
        "lists merge requests successfully": { response: { status: 200, result: [{ id: 2001, iid: 15, title: "Add new feature", state: "opened", web_url: "https://gitlab.com/my-group/my-project/-/merge_requests/15" }, { id: 2002, iid: 14, title: "Fix bug", state: "merged", web_url: "https://gitlab.com/my-group/my-project/-/merge_requests/14" }] } }
      }
    } as $api_result

    precondition ($api_result.response.status == 200) {
      error_type = "standard"
      error = "GitLab API error: " ~ ($api_result.response.result|json_encode)
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "lists merge requests successfully" {
    input = { project_id: "12345" }
    expect.to_not_be_null ($response)
  }
}