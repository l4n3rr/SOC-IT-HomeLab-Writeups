# Warzone 2 🎮

Status: **done**

*TryHackMe challenge room.*

## 🎯 Goal

## 🔍 Investigation

1. What was the **alert signature** for A Network Trojan was Detected?

Let's start with Brim

Activity Overview
<img width="286" height="346" alt="Screenshot 2026-11-04 211116" src="https://github.com/user-attachments/assets/a40bbb90-43eb-4994-af25-3a1f2a488b91" />


Alert Signatures
<img width="661" height="210" alt="Screenshot 2026-11-04 211136" src="https://github.com/user-attachments/assets/77d0d3c9-405a-4979-82da-6155a0891046" />


<img width="514" height="21" alt="Screenshot 2026-11-04 211332" src="https://github.com/user-attachments/assets/56626dab-0729-47ed-b6b8-ace40661041c" />





```ET MALWARE Likely Evil EXE download from MSXMLHTTP non-exe extension M2```


2. What was the **alert signature** for Potential Corporate Privacy Violation?


<img width="500" height="24" alt="Screenshot 2026-11-04 211416" src="https://github.com/user-attachments/assets/2dda7ab3-2cd0-4d95-a83c-40e9d053ee55" />



```ET POLICY PE EXE or DLL Windows file download HTTP```

3. What was the **IP to trigger either alert**? *Enter your answer in a defanged format.*






```185[.]118[.]164[.]8```




4. Provide the **full URI for the malicious downloaded file**. *In your answer, defang the URI.*

Maybe got ahead finding this filename:
<img width="445" height="18" alt="Screenshot 2026-11-04 212007" src="https://github.com/user-attachments/assets/2eddf1b5-dd33-4ecf-ba93-ace811faa8e9" />


Full URI here:
<img width="599" height="17" alt="Screenshot 2026-11-04 212040" src="https://github.com/user-attachments/assets/f9588458-4046-4184-b151-9efc69ae17d7" />




```awh93dhkylps5ulnq-be[.]com/czwih/fxla[.]php?l=gap1[.]cab```



5. What is the **name of the payload within the cab file**?


Got stuck on this for quite a bit, but I can ```File -> Export Objects``` which allows me to extract and then I can get the hash through Bash!


<img width="666" height="122" alt="Screenshot 2026-11-04 212844" src="https://github.com/user-attachments/assets/19d72fa7-3833-4244-81b0-1e6ece6227b9" />

<img width="671" height="39" alt="Screenshot 2026-11-04 212954" src="https://github.com/user-attachments/assets/1cd6f649-fff3-4987-bbbd-6b896eafa7ea" />


<img width="555" height="64" alt="Screenshot 2026-11-04 213046" src="https://github.com/user-attachments/assets/be9e8918-242d-41de-a28f-d82957b13778" />






```draw.dll```



6. What is the **user-agent** associated with this network traffic?


User-Agent by following HTTP stream (forgot to screenshot)






```Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 10.0; WOW64; Trident/8.0; .NET4.0C; .NET4.0E)```


7. What **other domains** do you see in the network traffic that are labelled as malicious by VirusTotal? *Enter the domains defanged and in alphabetical order. (format: domain[.]zzz,domain[.]zzz)*


In the Same VirusTotal, I just look for these domains



<img width="637" height="292" alt="Screenshot 2026-11-04 213157" src="https://github.com/user-attachments/assets/a13f6955-a39b-44a7-9235-2fba8982d652" />

<img width="1024" height="214" alt="Screenshot 2026-11-04 213334" src="https://github.com/user-attachments/assets/60162a0c-b867-4435-aeb0-d8c791475694" />





```a-zcorner[.]com,knockoutlights[.]com```



8. There are IP addresses flagged as Not Suspicious Traffic. What are the **IP addresses**? *Enter your answer in numerical order and defanged. (format: IPADDR,IPADDR)*



```64[.]225[.]65[.]166,142[.]93[.]211[.]176```




9. For the first IP address flagged as Not Suspicious Traffic. According to VirusTotal, there are several domains associated with this one IP address that was flagged as malicious. What were the **domains you spotted in the network traffic** associated with this IP address? *Enter your answer in a defanged format. Enter your answer in alphabetical order, in a defanged format. (format: domain[.]zzz,domain[.]zzz,etc)*



```safebanktest[.]top, tocsicambar[.]xyz, ulcertification[.]xyz```


10. Now for the second IP marked as Not Suspicious Traffic. What was the **domain you spotted in the network traffic** associated with this IP address? *Enter your answer in a defanged format. (format: domain[.]zzz)*


```2partscow[.]top```



## 💡 Takeaways
