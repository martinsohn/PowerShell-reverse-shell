# PowerShell-reverse-shell
Reverse TCP shell in PowerShell for fun. Made in spring 2020 with inspiration from (and a few fixes to) [samratashok/nishang Invoke-PowerShellTcp.ps1](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) and [PoweShell: Encrypt TCP Client-Server Traffic with a self-signed X509 Certificate](https://cyberwardog.blogspot.com/2016/08/poweshell-encrypt-tcp-client-server.html)

## Notes to defend against PowerShell reverse shells and other PowerShell based attacks
Some of these defenses come from [MITRE ATT&CK T1059.001](https://attack.mitre.org/techniques/T1059/001/) - have a look at the Mitigations and Detection sections. If you cannot deploy company wide, deploying defenses on just 20% of your clients reduces the risk probability of ~20%.
* PowerShell
   * Enforce [PowerShell Constrained Language Mode](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes).
      * Configure this with a Computer Policy, not a User Policy which can be overriden by an attacker.
      * Can be configured with AppLocker or Windows Defender Application Control.
   * Set PowerShell execution policy to execute only signed scripts.
   * Remove PowerShell version 1 & 2 from systems where not needed (rarely needed) - these versions bypass AMSI malware detection and bypass Constrained Language Mode.
   * Prevent PowerShell.exe execution completely with e.g. AppLocker or Windows Defender Application Control.
   * Be aware bypasses of above exist, but not all threat actors use bypasses, the probability is therefore still reduced.
* Logging
   * Preventing malware execution cannot be the ultimate goal, logging is in place is key **when** you're attacked.
   * Enable [PowerShell logging](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging)
      * Three logs exist, all should be collected: Transcript, Script Block, and Module logging.
      * [Windows PowerShell Logging Cheat Sheet](https://www.malwarearchaeology.com/cheat-sheets)
   * Log process creation events with e.g. [Sysmon](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon#event-id-1-process-creation)
   * Centrally collect, and if possible alert, on the logs, e.g. with [ELK Stack](https://www.elastic.co/what-is/elk-stack). 
      * If this seems like a big task, at least ensure logging is enabled and client log retention is reasonable (90+ days).
   * Log DNS requests from DNS server logs, and from Windows logs with e.g. [Sysmon](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon#event-id-22-dnsevent-dns-query)
* Network
   * Only allow outgoing/egress network traffic on specicically allowed ports, an example is only allowing egress port 80 and 443 from clients, and egress port 53 from DNS servers. Block anything else.

If I were to implement the least amount of safeguards with mimimum required effort, I would focus on:
* PowerShell Constrained Language Mode
* Removing PowerShell version 1 & 2
* Enabling PowerShell logging

## powershell-reverse-shell.ps1
Basic TCP reverse shell with no encryption.

## powershell-reverse-shell-DNS-TLS.ps1
An extension of the basic shell to:
* Fetch C2 IP and port via DNS over HTTPS (My domain 'powershell-reverse-shell.demo.martinsohn.dk' in the code has the A-record: 127.0.0.1 and TXT-record: 13337)
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
