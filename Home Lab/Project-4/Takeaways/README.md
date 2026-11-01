# Takeaways

Jira & Active Directory Offboarding Automation: Troubleshooting & Takeaways
Building an end-to-end automation pipeline across Jira Cloud and on-premise Active Directory comes with unique integration challenges. Below are the key troubleshooting takeaways and technical lessons learned while building and debugging the automated offboarding workflow.

1. Project Keys & Scope (IO vs. KAN)
The Challenge: Initial queries returned zero results because the script was pointed at the wrong project key (IO vs. KAN), or the search scope was too broad.

The Takeaway: Always verify your exact project keys and identifiers first. When queries fail to return expected data, run a lightweight project-discovery script against the Jira REST API (/rest/api/3/project) to audit all available project names, keys, and IDs before writing complex JQL.

2. Request Types vs. Underlying Issue Types
The Challenge: The script was filtering by issuetype = "Offboarding", but "Offboarding" was configured as a Request Type (the customer-facing portal form name) rather than the underlying Jira Issue Type (which was actually a standard Service Request or Task).

The Takeaway: In Jira Service Management (JSM), portal request forms do not equal backend issue types. When writing JQL queries for automation, filter by project, status, and populated custom fields rather than relying on human-facing request type names.

3. Custom Field Visibility on Portal Forms
The Challenge: The custom target username field (customfield_10110) was hidden on the customer portal form layout, causing it to be blank upon submission and skipped by script safety checks.

The Takeaway: Automated scripts that depend on custom metadata will fail if that data isn't collected at the point of submission. Ensure required automation fields are either exposed on the customer request form layout or automatically populated via Jira automation rules. Always include defensive scripting (if (-not $Field) { continue }) to handle blank fields gracefully without crashing the pipeline.

4. Discovering Exact Workflow Transition IDs & Names
The Challenge: The script tried to transition tickets using generic terms like "Done" or "Resolved", but Jira's actual workflow button was named 'Resolve this issue' (Transition ID 761), causing transition failures.

The Takeaway: Never guess Jira workflow states or transition names. Transition names in JSM often differ from their destination status names. Always query the /rest/api/3/issue/{key}/transitions endpoint dynamically to inspect exact transition IDs and names for your specific workflows.

5. The Power of Atomic Diagnostic Scripts
The Challenge: Trying to fix a monolithic master script when an API call fails can quickly become overwhelming.

The Takeaway: Break complex integrations down into small, single-purpose diagnostic scripts (e.g., an endpoint inspector, a transition checker, or an unfiltered project dumper). Isolating authentication, searching, and transitions into atomic test scripts makes troubleshooting faster and infinitely less frustrating.
