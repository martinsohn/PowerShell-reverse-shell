# PowerShell-reverse-shell
 
Reverse TCP shell in PowerShell for fun. Made spring 2020 with inspiration from [samratashok/nishang Invoke-PowerShellTcp.ps1](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) that fixes a few things.

## Listener tips
Ensure the send buffer of your listener has enough bytes for your commands.
On Windows some options are:
* (PowerCat)[https://github.com/besimorhino/powercat] to LOTL has send buffer of 65536 bytes (same as my tool)
* (Nmap's Ncat)[https://nmap.org/ncat/] has a unmodifiable send buffer of 512 bytes
* (Netcat)[https://eternallybored.org/misc/netcat/] has a buffer of 4096 bytes.
