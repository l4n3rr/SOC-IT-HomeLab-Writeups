# Takeaways

Lessons learned building the ServiceNow incident lab.

* Impact plus Urgency sets Priority, and that decides what gets worked first.
* Work notes should say what you did, what you found, and what is next, at each step.
* On Hold pauses SLA, Resolved is not Closed.
* A knowledge article is for a repeat issue, a known error is a Problem record, not the same thing.
* Honest scope: incident create, triage, prioritize, assign, resolve, close, SLA basics, and knowledge linking in a developer instance. Not production ServiceNow administration, custom development, or Problem, Change, and CMDB work. All test data was fictional.

With the honest scope, I truly believe it will be helpful right off the bat to navigate this industry-recognized tool, understand terminology, and the experience of any lifecycle to see the workflow from start to finish.

## Jira vs ServiceNow

Same ticket lifecycle in both — create, triage, prioritize, work, resolve, close. In Jira, in Project-3 and Project-4, tickets lived in a project and queue, and I moved them through transitions with the REST API. In ServiceNow, incidents live in a table, Impact plus Urgency drives Priority, and there is an Assignment group and an SLA engine that pauses on hold. The work is the same, the fields and SLA handling are what change.
