# Cloud Security for SOC 🎮

Status: 🚧 In progress

*TryHackMe SOC Level 2 module.*

## 🎯 Goal
Learn how SOC teams monitor and defend cloud environments with SIEM, focused on AWS — detecting threats across cloud identities, services, and workloads.

## 🔍 Investigation

## 💡 Takeaways
- The concepts in this room (AWS Security Logging) apply to most cloud providers — for example, AWS CloudTrail maps to Azure Activity Log in Microsoft Azure and to Cloud Audit Logs in Google Cloud. By understanding the fundamentals here, especially the three security areas, you can switch between cloud platforms with ease after some practice.
- The 3 areas are: control plane, workloads, and managed services.
- CloudTrail records all control plane activities.
- GuardDuty is for security purposes, of course, but for non-strong security teams or a team with no SOC…
- CloudTrail excludes service-specific actions, but each service has its own logs — for example, CloudFront, S3 data, and VPC Flow logs.
- Next: monitoring AWS logins, services, and workloads — starting with AWS logins, probably within the control plane.
