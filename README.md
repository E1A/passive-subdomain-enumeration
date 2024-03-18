## Enumerate subdomains of a specified domain without the need of an API key

### Syntax to enumerate subdomains
```
user@debian:~$ ./subdomains.sh -u example.com
All discovered subdomains have been saved to example.com-output.txt
```
<br/>

### Syntax to enumerate subdomains and check if they are active
```
user@debian:~$ ./subdomains.sh -u example.com -ad
All discovered subdomains have been saved to example.com-output.txt
Starting HTTPX on discovered subdomains...

    __    __  __       _  __
   / /_  / /_/ /_____ | |/ /
  / __ \/ __/ __/ __ \|   /
 / / / / /_/ /_/ /_/ /   |
/_/ /_/\__/\__/ .___/_/|_|
             /_/

                projectdiscovery.io

[INF] Current httpx version v1.6.0 (latest)
HTTPX results have been saved to httpx-example.com-subd.txt
```
