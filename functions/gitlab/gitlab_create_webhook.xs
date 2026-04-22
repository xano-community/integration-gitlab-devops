function "gitlab_create_webhook" {
  description = "Create a webhook for a GitLab project"
  input {
    text project_id { description = "Project ID or URL-encoded path" }
    text url { description = "Webhook destination URL" }
    bool push_events?=true { description = "Trigger on push events" }
    bool issues_events?=false { description = "Trigger on issue events" }
    bool merge_requests_events?=false { description = "Trigger on merge request events" }
    text token? { description = "Secret token for payload validation" }
    bool enable_ssl_verification?=true { description = "Enable SSL verification" }
  }
  stack {
    var $params {
      value = {
        url: $input.url,
        push_events: $input.push_events,
        issues_events: $input.issues_events,
        merge_requests_events: $input.merge_requests_events,
        enable_ssl_verification: $input.enable_ssl_verification
      }
    }
    var.update $params { value = $params|set_ifnotnull:"token":$input.token }

    api.request {
      url = "https://gitlab.com/api/v4/projects/" ~ $input.project_id ~ "/hooks"
      method = "POST"
      headers = ["PRIVATE-TOKEN: " ~ $env.GITLAB_ACCESS_TOKEN, "Content-Type: application/json"]
      params = $params
      mock = {
        "creates webhook successfully": { response: { status: 201, result: { id: 5001, url: "https://example.com/webhook", push_events: true, issues_events: false, merge_requests_events: true, created_at: "2026-03-17T10:00:00Z" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "GitLab API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates webhook successfully" {
    input = { project_id: "12345", url: "https://example.com/webhook", merge_requests_events: true }
    expect.to_equal ($response.id) { value = 5001 }
    expect.to_equal ($response.push_events) { value = true }
  }
}