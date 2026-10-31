# Warzone 1 🎮

Status: 🚧 In progress

*TryHackMe challenge room — Wireshark pcap analysis.*

## 🎯 Goal

Inspect the PCAP file and retrieve the artifacts to confirm this alert is **a true positive**.

## 🔍 Investigation


1. What was the **alert signature** for Malware Command and Control Activity Detected?
Let's start with statistics -> protocol Hierarchy
<img width="1005" height="468" alt="Screenshot 2026-10-31 152401" src="https://github.com/user-attachments/assets/f68dc290-8557-469f-8730-27ba89f93933" />



TCP Protocol dominates with some protocols thrown in there with possible anomalies (DNS,LDAP,HTTP,ARP,SMB,UDP)

Let's see endpoints as well, 20 IPs

<img width="1091" height="458" alt="Screenshot 2026-10-31 152658" src="https://github.com/user-attachments/assets/b767b8b9-0a0b-4999-ad54-9b2018499871" />



Interesting HTTP 301 Response Code

<img width="806" height="495" alt="Screenshot 2026-10-31 152949" src="https://github.com/user-attachments/assets/f57dd42a-bcbd-4c47-a79c-b86c24609901" />


Another early packet linking to maybe important DNS info


<img width="1249" height="35" alt="Screenshot 2026-10-31 153120" src="https://github.com/user-attachments/assets/e57228db-8a3f-48fb-86d8-57784b88c0a3" />


Not sure what DCERPC is


<img width="1222" height="256" alt="Screenshot 2026-10-31 153344" src="https://github.com/user-attachments/assets/3b2c32bf-aaf6-48c6-b790-3b814787effc" />


Let's gather info to move forward *i took my sweet time because I hadn't used wireshark in a minute*

Private IPs: 3 of them starting with 172.16
172.16.1.2 commonly speaks with 172.16.1.102
172.16.1.1 rarely speaks with 172.16.1.102

172.16.1.102 VERY COMMONLY spoke with every other public IP.

<img width="1238" height="387" alt="Screenshot 2026-10-31 154906" src="https://github.com/user-attachments/assets/5abe5cb7-f71d-49f1-b854-08c69dbfa977" />


I forgot I had **Brim** in my arsenal, and starting off like this would've saved plenty time!

<img width="700" height="105" alt="Screenshot 2026-10-31 160816" src="https://github.com/user-attachments/assets/fc0a4816-e428-4a01-bfdb-807f76f4595e" />

Answer: ```ET Malware MirrorBlast CnC Activity M3```

This made me realize that the highest ROI beginnings are looking at statistics within Wireshark as well as Brim



<img width="335" height="176" alt="Screenshot 2026-10-31 161046" src="https://github.com/user-attachments/assets/64d06fe2-b92e-4fd6-8bba-549985689586" />



3. What is the **source IP address**? *Enter your answer in a defanged format.*

Answer: ```172[.]16[.]1[.]102```



4. What IP address was the **destination IP** in the alert? *Enter your answer in a defanged format.*

Answer: ```169[.]239[.]128[.]11```




5. Still in VirusTotal, under Community, what **threat group** is attributed to this IP address?

<img width="481" height="486" alt="Screenshot 2026-10-31 161552" src="https://github.com/user-attachments/assets/bf1cfb7e-1202-4e96-a535-3f0938d3596a" />

Slight external research on TA505 gave me the answer

Answer: ```TA505```





6. What is the **malware family**?

In the same screenshot above

Answer: MirrorBlast





7. Do a search in VirusTotal for the domain from question 4. What was the majority **file type** listed under Communicating Files?

<img width="384" height="556" alt="Screenshot 2026-10-31 162006" src="https://github.com/user-attachments/assets/ead83090-072f-41f0-b017-093b1e703da1" />



Answer: ```Windows Installer```





8. Inspect the web traffic for the flagged IP address; what is the **user-agent** in the traffic?

Let's look for this on Wireshark flagged IP address as a filter:

<img width="240" height="36" alt="Screenshot 2026-10-31 162250" src="https://github.com/user-attachments/assets/cd8cbc18-2fde-490f-b451-a56ee809dfe1" />

<img width="293" height="16" alt="Screenshot 2026-10-31 162301" src="https://github.com/user-attachments/assets/f4f3590c-9483-4421-86d7-4b6d68d7d3ac" />


Answer: ```REBOL View 2.7.8.3.1```








9. Retrace the attack; there were multiple IP addresses associated with this attack. What were **two other IP addresses**? *Enter the IP addresses defanged and in numerical order. (format: IPADDR,IPADDR)*

Let's filter for HTTP and find the packets with ```Windows Installer``` as User-Agent

<img width="911" height="269" alt="Screenshot 2026-10-31 163202" src="https://github.com/user-attachments/assets/0d5d2265-7d37-479f-9f59-e6d4e7c004b1" />

<img width="936" height="227" alt="Screenshot 2026-10-31 163214" src="https://github.com/user-attachments/assets/bfb8142d-c0ff-4a6d-8048-2f1cccfc8fb7" />



Answer: ```185[.]10[.]68[.]235, 192[.]36[.]27[.]92```





10. What were the **file names of the downloaded files**? *Enter the answer in the order to the IP addresses from the previous question. (format: file.xyz,file.xyz)*

Let's follow the conversations!


<img width="464" height="190" alt="Screenshot 2026-10-31 163449" src="https://github.com/user-attachments/assets/f28ce3c3-4ef8-454e-83f8-8ba2aa458458" />
<img width="981" height="153" alt="Screenshot 2026-10-31 163624" src="https://github.com/user-attachments/assets/3447da02-c7a8-4238-9ca2-60cb818e46ec" />


Answer: ```filter.msi,10opd3r_load.msi```






11. Inspect the traffic for the first downloaded file from the previous question. Two files will be saved to the same directory. What is the **full file path of the directory and the name of the two files**? *(format: C:\path\file.xyz,C:\path\file.xyz)*


I had to just keep following the conversation to the very end, and holy shit this was hard to see with the eye.

<img width="427" height="60" alt="Screenshot 2026-10-31 164403" src="https://github.com/user-attachments/assets/af97e70f-d4aa-45d4-bf20-04e6e2b35876" />


Answer: ```C:\ProgramData\001\arab.bin, C:\ProgramData\001\arab.exe```





12. Now do the same and inspect the traffic from the second downloaded file. Two files will be saved to the same directory. What is the **full file path of the directory and the name of the two files**? *(format: C:\path\file.xyz,C:\path\file.xyz)*


<img width="806" height="50" alt="Screenshot 2026-10-31 164638" src="https://github.com/user-attachments/assets/b2561da8-2579-407e-a226-8a5973ff4211" />




Answer: ```C:\ProgramData\Local\Google\rebol-view-278–3–1.exe, C:\ProgramData\Local\Google\exemple.rb```




## 💡 Takeaways

Brim is a very useful start for basic queries, and statistics is a good start within Wireshark as well. Begin narrowing it down by filtering interesting (baseline -> anomalies) (weird spike of traffic) IPs/Domains/Protocols to narrow it down. It took time in this room because I hadn't used Wireshark/Brim in a while
