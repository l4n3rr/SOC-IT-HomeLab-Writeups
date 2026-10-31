# Warzone 1 🎮

Status: 🚧 In progress

*TryHackMe challenge room — Wireshark pcap analysis.*

## 🎯 Goal

Inspect the PCAP file and retrieve the artifacts to confirm this alert is **a true positive**.

## 🔍 Investigation


1. What was the **alert signature** for Malware Command and Control Activity Detected?
2. What is the **source IP address**? *Enter your answer in a defanged format.*
3. What IP address was the **destination IP** in the alert? *Enter your answer in a defanged format.*
4. Still in VirusTotal, under Community, what **threat group** is attributed to this IP address?
5. What is the **malware family**?
6. Do a search in VirusTotal for the domain from question 4. What was the majority **file type** listed under Communicating Files?
7. Inspect the web traffic for the flagged IP address; what is the **user-agent** in the traffic?
8. Retrace the attack; there were multiple IP addresses associated with this attack. What were **two other IP addresses**? *Enter the IP addresses defanged and in numerical order. (format: IPADDR,IPADDR)*
9. What were the **file names of the downloaded files**? *Enter the answer in the order to the IP addresses from the previous question. (format: file.xyz,file.xyz)*
10. Inspect the traffic for the first downloaded file from the previous question. Two files will be saved to the same directory. What is the **full file path of the directory and the name of the two files**? *(format: C:\path\file.xyz,C:\path\file.xyz)*
11. Now do the same and inspect the traffic from the second downloaded file. Two files will be saved to the same directory. What is the **full file path of the directory and the name of the two files**? *(format: C:\path\file.xyz,C:\path\file.xyz)*

## 💡 Takeaways

Brim is a very useful start for basic queries, and statistics is a good start within Wireshark as well. Begin narrowing it down by filtering interesting (baseline -> anomalies) (weird spike of traffic) IPs/Domains/Protocols to narrow it down. It took time in this room because I hadn't used Wireshark/Brim in a while
