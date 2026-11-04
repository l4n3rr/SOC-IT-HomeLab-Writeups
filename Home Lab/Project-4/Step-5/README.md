# Step-5: Windows Task Scheduler Deployment

I don't need to do this on my VM literally. This is how to do it below --

1. Open Task Scheduler
* Press Win + R, type taskschd.msc, and hit Enter.

* In the right-hand actions pane, click Create Task... (not "Create Basic Task", so you get full permission options).

2. Configure General Settings
* Name: Automated Hybrid Offboarding

* Security options:

* Select Run whether user is logged on or not.

* Check Run with highest privileges (required for Active Directory modifications and module execution).

* Check Do not store password if running under a managed service account, or select your administrator account credentials.

3. Set the Trigger (Polling Frequency)
* Go to the Triggers tab and click New...

* Set it to Begin the task: On a schedule.

* Choose Daily (or whatever interval fits your SLA), and under Advanced settings, check Repeat task every: 15 minutes for a duration of Indefinitely.

* Click OK.

4. Configure the Action
* Go to the Actions tab and click New...

* Action: Start a program

* Program/script:

DOS
powershell.exe
Add arguments:

DOS
-ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Users\Administrator\Desktop\JiraScript\PipelineScripts\Offboard-MasterWithEntraID.ps1"
(Using -WindowStyle Hidden prevents a PowerShell terminal window from popping up on the screen every 15 minutes).

Click OK.

5. Finalize and Test
* Go to the Conditions and Settings tabs to adjust parameters like waking the computer or stopping the task if it runs longer than 1 hour.

* Click OK and enter your Windows administrator credentials when prompted.

* Verification: Right-click your new task in the library and click Run. Check your offboard_audit.log file to confirm it executed successfully in the background.
