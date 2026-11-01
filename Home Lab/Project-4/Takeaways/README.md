# Takeaways

Roadblock Faced,What Caused It,The Takeaway / Best Practice
1. Intermittent 401 Unauthorized Errors,Expired or invalid Jira API tokens.,"Always keep a fresh API token handy, and verify basic authentication headers (Base64 encoding of email + token) before digging into complex logic."
2. Zero Results in JQL Search,Confusing Jira Service Management (JSM) request types (the portal form) with backend issue types or searching the wrong project key (IO vs KAN).,Use a discovery script to list all project keys and inspect raw issue data with zero filters first to see what Jira actually stores.
3. Hidden Custom Fields,"The target username field (customfield_10110) was hidden on the customer portal form, making it blank upon submission.","When automating, ensure fields required by your script are either exposed on the portal or populated via automation rules. Always add safety checks (if (-not $Field) { continue }) to prevent script crashes."
4. Ticket Transition Mismatch,"The script looked for a button/transition named ""Done"" or ""Resolved"", but Jira's actual workflow transition button was named 'Resolve this issue' (ID 761).",Never guess workflow names. Use a small transition diagnostic script to query /rest/api/3/issue/{key}/transitions to see exact IDs and names.
5. The Power of Diagnostic Scripts,Trying to fix a master script blindly when something fails.,"Break complex workflows into atomic diagnostic tools. Isolating authentication, searching, and transitions into small standalone tests makes debugging infinitely faster."
