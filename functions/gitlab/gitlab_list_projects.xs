function "gitlab_list_projects" {
  description = "List GitLab projects accessible to the authenticated user"
  input {
    text search? { description = "Search by project name, path, or description" }
    text visibility? { description = "Filter: public, internal, or private" }
    bool membership?=true { description = "Only projects user is a member of" }
    int per_page?=20 { description = "Results per page (max 100)" }
    int page?=1 { description = "Page number" }
  }
  stack {
    var $query_string { value = "?per_page=" ~ $input.per_page ~ "&page=" ~ $input.page ~ "&membership=" ~ $input.membership }
    conditional {
      if ($input.search != null) {
        var.update $query_string { value = $query_string ~ "&search=" ~ $input.search }
      }
    }
    conditional {
      if ($input.visibility != null) {
        var.update $query_string { value = $query_string ~ "&visibility=" ~ $input.visibility }
      }
    }

    api.request {
      url = "https://gitlab.com/api/v4/projects" ~ $query_string
      method = "GET"
      headers = ["PRIVATE-TOKEN: " ~ $env.GITLAB_ACCESS_TOKEN]
      mock = {
        "lists projects successfully": { response: { status: 200, result: [{ id: 100, name: "my-project", path: "my-project", web_url: "https://gitlab.com/my-group/my-project", visibility: "private" }, { id: 101, name: "api-service", path: "api-service", web_url: "https://gitlab.com/my-group/api-service", visibility: "internal" }] } }
      }
    } as $api_result

    precondition ($api_result.response.status == 200) {
      error_type = "standard"
      error = "GitLab API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "lists projects successfully" {
    input = { }
    expect.to_not_be_null ($response)
  }
}