# PowerShell-reverse-shell
 
## powershell-reverse-shell.ps1
Reverse TCP shell in PowerShell for fun. Made in spring 2020 with inspiration from [samratashok/nishang Invoke-PowerShellTcp.ps1](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) that fixes a few things.

## powershell-reverse-shell-DNS-TLS.ps1
An extension of the basic tool to:
* Fetch C2 IP and port via DNS over HTTPS (My domain 'powershell-reverse-shell.demo.martinsohn.dk' in the code has A-record: 127.0.0.1 and TXT-record: 13337)
* Encrypt C2 communication (see Netcat bullet in *Listener tips* section below)

#### Demonstration
![](/powershell-reverse-shell-DNS-TLS-demo.gif)

## Listener tips
* Ensure the send buffer of your listener has enough bytes for your commands.
* On Windows some listeners are:
    * [PowerCat](https://github.com/besimorhino/powercat) is LOTL and has a send buffer of 65536 bytes (same as my tool)
    * [Nmap's Ncat](https://nmap.org/ncat/) has an unmodifiable send buffer of 512 bytes
        * .\ncat.exe -lvnp 13337
        * Use *-ssl* flag to listen for TLS with self-signed random certificate: .\ncat.exe --ssl -lvnp 13337
    * [Netcat](https://eternallybored.org/misc/netcat/) has an unmodifiable buffer of 4096 bytes.
        * .\netcat64.exe -lvnp 13337
