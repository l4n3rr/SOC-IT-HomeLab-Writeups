# Step-3: Finalize Script

Variables in script document

<img width="81" height="107" alt="Screenshot 2026-11-01 150247" src="https://github.com/user-attachments/assets/1e1eb5af-2969-449d-8c1d-9ec28103bd15" />


If I run it now, it wont work without connection. This wasn't even a connection-based error though.

<img width="900" height="254" alt="Screenshot 2026-11-01 151043" src="https://github.com/user-attachments/assets/28811af1-4a2b-4e69-b6bf-6be790ee9a20" />


Script couldn't see my offboarding ticket? At least it ran, and Jira is connected

<img width="704" height="70" alt="Screenshot 2026-11-01 151728" src="https://github.com/user-attachments/assets/9a065bde-37fd-41d6-957c-bdf0b842ee41" />



Let's do diagnostic scripts to check exact spelling and important parameters
<img width="669" height="47" alt="Screenshot 2026-11-01 153101" src="https://github.com/user-attachments/assets/8a92abe4-1130-49c7-8044-8fd77cea776b" />



<img width="689" height="53" alt="Screenshot 2026-11-01 154021" src="https://github.com/user-attachments/assets/1cad986e-52f4-47ee-96f2-37b155de9094" />



API token was expired!!!! Had to make a new one

<img width="554" height="96" alt="Screenshot 2026-11-01 154327" src="https://github.com/user-attachments/assets/fa10cbae-638a-48fd-8d0d-69fa093e5753" />



Not only was it an expired API token, but a poor JQL query attempt within the script.

<img width="647" height="48" alt="Screenshot 2026-11-01 160012" src="https://github.com/user-attachments/assets/cbcf310d-e1a2-422f-85fa-22abe55699dc" />


Very flawed ^. The issue type is a service request. There's no issue type that would be offboarding. That's more specific and considered 'request type' (Jira Terminology)




A good query will include the custom field and a keyword for offboarding (custom field didnt work, so stuck with offboarding only!)



<img width="732" height="37" alt="Screenshot 2026-11-01 160739" src="https://github.com/user-attachments/assets/f2f0a80b-b8d5-446c-8dd0-778c5ce5fbdb" />



Success! There's an Entra ID part to this but I haven't gotten to it yet. Let's confirm the success within AD + Jira


<img width="921" height="213" alt="Screenshot 2026-11-01 160845" src="https://github.com/user-attachments/assets/83aaff60-c877-4bc5-ba0a-cfa6a8963c86" />


<img width="153" height="37" alt="Screenshot 2026-11-01 161022" src="https://github.com/user-attachments/assets/b6d2f9d7-e41a-476b-aaee-23a20cd49051" />




The Jira ticket didn't change in status, so I modified the script to ensure that.

This is another diagnostic script that will help me transition ticket from inprogress->complete

<img width="590" height="83" alt="Screenshot 2026-11-01 162933" src="https://github.com/user-attachments/assets/6e0bf3e1-9055-4e2d-853f-c42dce588a5d" />


Boom! Confirmed as well



<img width="949" height="387" alt="Screenshot 2026-11-01 163246" src="https://github.com/user-attachments/assets/aef9ebdd-24b4-43d2-86f3-dadefe84ad5a" />



<img width="873" height="51" alt="Screenshot 2026-11-01 163345" src="https://github.com/user-attachments/assets/fd5d4351-3434-4a2d-ab35-ac442cc76b5a" />





