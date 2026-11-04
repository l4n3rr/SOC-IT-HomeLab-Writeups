# Step-4: Entra ID Integration via Microsoft Graph

Setup App-Only Authentication using Entra App Registration.

Let's setup azure acct.

Grab the tenant ID.
Let's make a new app registration.
<img width="274" height="430" alt="Screenshot 2026-11-03 123243" src="https://github.com/user-attachments/assets/386094b4-222e-4bb3-9c17-4ae5dbc65d79" />


The new variables being added to the script are for the Microsoft Graph

<img width="448" height="97" alt="Screenshot 2026-11-03 123615" src="https://github.com/user-attachments/assets/2fffb61e-0052-4787-95dc-4d707705fc36" />


Create a John Smith user as well in Entra ID!
<img width="169" height="192" alt="Screenshot 2026-11-03 123738" src="https://github.com/user-attachments/assets/0070f3dd-6d1b-49c6-9e38-1579d3ae7701" />

Through Microsoft Entra admin center, I got the client ID and secret through app registrations. Tenant ID and domain comes with the azure account.

<img width="204" height="323" alt="Screenshot 2026-11-03 125351" src="https://github.com/user-attachments/assets/e5fc6cd2-7c5e-442b-b984-4a4d65ecb9d1" />


<img width="247" height="31" alt="Screenshot 2026-11-03 125359" src="https://github.com/user-attachments/assets/6589c703-a360-4aac-a457-4be7bcdeede3" />



First error to do with something not recognized. Will probably have to install module.

<img width="934" height="79" alt="Screenshot 2026-11-03 144000" src="https://github.com/user-attachments/assets/32bf9675-5862-46f7-b874-2533306c49dc" />




<img width="490" height="20" alt="Screenshot 2026-11-03 144335" src="https://github.com/user-attachments/assets/36e9d7c6-4c0a-40f2-b44b-2d04bd5e4f37" />




Another error.

<img width="936" height="56" alt="Screenshot 2026-11-03 144853" src="https://github.com/user-attachments/assets/4d822463-02de-4854-a935-10179796a12f" />


Supposedly, powershell object expected, but raw string not expected. Let's make a change in the script

<img width="938" height="96" alt="Screenshot 2026-11-03 145128" src="https://github.com/user-attachments/assets/42f7e923-a7d3-4669-85bf-71e090f521cd" />



<img width="813" height="227" alt="Screenshot 2026-11-03 145205" src="https://github.com/user-attachments/assets/b5e7e73a-ec20-483e-aa48-df5ae0fee7e7" />


Half success?



<img width="935" height="534" alt="Screenshot 2026-11-03 145306" src="https://github.com/user-attachments/assets/28e3e45d-2723-4e96-bb53-6e17dd80db4e" />



More errors, more modules to install


<img width="912" height="38" alt="Screenshot 2026-11-03 150430" src="https://github.com/user-attachments/assets/def5590f-350f-4cf6-b662-f514eb0292a1" />



At this point, all these errors within the script kept feeling like hitting my head on a brick wall. So I did some diagnostic script. 
<img width="914" height="423" alt="Screenshot 2026-11-03 195056" src="https://github.com/user-attachments/assets/c27907e8-ee08-4aaf-8c72-2d2a0496b868" />

<img width="322" height="20" alt="Screenshot 2026-11-03 195113" src="https://github.com/user-attachments/assets/672e8c22-31c1-47b6-bd6c-607342ca5463" />


I STILL HAD NO IDEA WHAT THIS MEANT. BUT. This lead to a breakthrough. Imagine you keep bumping into a brick wall trying to walk all the way through, only to realize that the brick wall weighs very little, and you can move it aside with some analytical concentration. Are you for real? **The app registration IDs, there were 2. Secret value, then client value. I kept using the wrong one**


The final thing I had to do was allow permissions to be able to disable the cloud account (Entra ID) just like I do within local AD!



<img width="630" height="182" alt="Screenshot 2026-11-03 200144" src="https://github.com/user-attachments/assets/e827894b-6401-45fa-ad32-989ee8be79a8" />



<img width="399" height="182" alt="Screenshot 2026-11-03 200317" src="https://github.com/user-attachments/assets/20bd058c-47a9-435d-ac31-e95707f01173" />



FULLY SUCCESSFUL!


<img width="923" height="404" alt="Screenshot 2026-11-03 200448" src="https://github.com/user-attachments/assets/61f148c2-fb1c-49c3-909e-a6735cb05188" />


This was a damn project in and of itself.
Takeaways:

OAuth Authentication: Always distinguish between a client secret's Secret ID (the display identifier/GUID) and its Value (the cryptographic secret string). Using direct REST token requests (Invoke-RestMethod) also bypasses internal module wrapper parsing errors.

Cloud Authorization: Assigning permission scopes like User.ReadWrite.All in an App Registration grants the capability, but tenant-wide Admin Consent must be explicitly granted before app-only daemon tokens are authorized to modify directory objects.

Hybrid Sequencing: Strict execution order prevents orphaned accounts. Local directory changes (DC01) must happen first, followed immediately by cloud account disablement and session revocation, ending with ITSM ticket updates in Jira.

Script Resiliency: Relying on hashtable body parameters (-BodyParameter) and direct Graph API endpoints prevents brittle module version conflicts and parameter binding errors in fresh domain controller environments.

