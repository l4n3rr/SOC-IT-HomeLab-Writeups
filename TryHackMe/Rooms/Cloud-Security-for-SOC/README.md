# Cloud Security for SOC 🎮

Status: ✅ Complete

*TryHackMe SOC Level 2 module.*

## 🎯 Goal
Learn how SOC teams monitor and defend cloud environments with SIEM, focused on AWS — detecting threats across cloud identities, services, and workloads.

## 💡 Notes
*Notes from the module — things that look different in a cloud environment than on-prem.*

**Cloud logging basics**
- The concepts in this room (AWS Security Logging) apply to most cloud providers — for example, AWS CloudTrail maps to Azure Activity Log in Microsoft Azure and to Cloud Audit Logs in Google Cloud. By understanding the fundamentals here, especially the three security areas, you can switch between cloud platforms with ease after some practice.
- The 3 areas are: control plane, workloads, and managed services.
- CloudTrail records all control plane activities.
- CloudTrail excludes service-specific actions, but each service has its own logs — for example, CloudFront, S3 data, and VPC Flow logs.
- GuardDuty is for security purposes, of course, but for non-strong security teams or a team with no SOC…
- 80% of attacks on AWS services can be detected with 20% SOC effort.

**IAM is the AD of AWS**
- IAM is a core AWS feature: user, group, role, policy. Quite similar to AD.
- The ARN is a big field when it comes to cloud/AWS — it's the identity string you follow through the logs.
- Cross-account access runs through roles.
- Entities that came up: UsersAvatarsProcessor, Put_Policy, AccessKey, MFADevice.

**Reading CloudTrail logins**
- The existence of the errorMessage field name means authentication failed. There are many more important field names: errorCode, authentication_method, console, user_arn, user_agent, username, src, userIdentity.accessKeyId.
- AccessKey logins have more programmatic userAgent values — AKIA. GUI logins tend to have more web browser userAgent values — ASIA. AKIA is a long-term access key; ASIA is temporary session credentials.

**S3**
- S3 (Simple Storage Service) stores cloud logs or anything just to store.
- Detect early S3 attacks: seeing the moment a bucket goes public — PutBucketPublicAccessBlock, PutBucketPolicy, Sid.
- Detect late S3 attacks: alert on an external object access.

**EC2 and security groups**
- EC2 (Elastic Compute Cloud) is for launching and managing VMs in the cloud — access through RDP/SSH.
- Detect early attacks within this by responding to exposed VMs ASAP.
- Detect late attacks within this by having defense in depth with: 1. GuardDuty, 2. auth.log (Linux), 3. Alert on security group modifications with CloudTrail.
- Security group checks — what to look for: who created the group, what inbound rules changed, which VMs use it now.
- New group created: index=* eventName=CreateSecurityGroup — then check inbound rules: index=* eventName=AuthorizeSecurityGroupIngress sg-xxxxxx — then find VMs using it: index=* eventName IN(RunInstances, ModifyInstanceAttribute) sg-xxxxxx
- Rule modified: index=* eventName IN(*SecurityGroupIngress, ModifySecurityGroupRules) — then find the creation and its author, searching 90+ days back: index=* earliest=-1y eventName=CreateSecurityGroup sg-xxxxxx

**What looks different in cloud workloads**
- Session Manager lets you reach an EC2 instance from the AWS Console without opening SSH or RDP ports — and it leaves no SSH trace in auth.log. Every connection is a StartSession event in CloudTrail instead.
- Auto Scaling spins instances up and down with demand, so static host monitoring doesn't hold.
- Auditd logs raw Linux runtime events but is hard to read and lacks context. Falco adds container context and parent process info, and can send SIEM-style alerts at low volume instead of raw event firehoses.
- Lambda is serverless: just the code plus the execution role. If either is wrong, it becomes persistence, privilege escalation, or a miner. Watch AddPermission*, PublishLayerVersion*, UpdateFunctionCode*, CreateFunction*, UpdateFunctionConfiguration*.
- Denial of Wallet: the SOC detects and triages, it doesn't fully remediate. Validate whether the resource should be public, block bad IPs and user-agents with WAF, cache and rate limit with a CDN, and optimize the compute work.

**How to investigate in cloud logs**
- Sometimes, your current query is hiding the next bit of important information. Example: searching for who created a security group hides modifications and more details on that security group. You build on the information NOT by literally building on the query, but removing and replacing within the query.
- Sometimes, an object or location has a strict ID attached that you can follow.
- Sometimes, you have to look through different sources/sourcetypes to continue the investigation.
- When a SOC takes on a new cloud: inventory every cloud platform holding critical data, enable vendor audit logging in each one, forward logs into SIEM, then build detection rules for suspicious logins and admin actions.
