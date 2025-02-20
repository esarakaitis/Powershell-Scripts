$log_file="\\path\to\share\logs\logfile.log"
echo "Checking server uptime..."
echo "Checking server uptime..." | Out-File $log_file -width 240 -Append #logs the result
$servers=Get-XAServer 

foreach($server in $servers){
    echo "`n**** $server ****"
    echo "`n**** $server ****" | Out-File $log_file -width 240 -Append #logs the result
    $ping = new-object System.Net.NetworkInformation.Ping #creates a ping object
    $dns=$server.ServerName
    $ip=$server.IPAddresses

    $result=$ping.send($dns,100).Status.ToString()
    echo "Ping $server by hostname: $result"
    echo "Ping $server by hostname: $result" | Out-File $log_file -width 240 -Append #logs the result
    $result=$ping.send($ip,100).Status.ToString()
    echo "Ping $server by IP: $result"
    echo "Ping $server by IP: $result" | Out-File $log_file -width 240 -Append #logs the result
   
   if($server.LogOnsEnabled -eq $false){
        Write-Host "Logons are disabled on this server!" -ForegroundColor Red
        echo "Logons are disabled on this server!" | Out-File $log_file -width 240 -Append #logs the result
    }


 if($result -eq "Success"){
        try {
            $socket = new-object System.Net.Sockets.TcpClient($ip, $server.IcaPortNumber) #creates a socket connection to see if the port is open
        } catch {
            $socket = $null
        }
  if($socket -ne $null) {
            echo "Socket Connection Successful."
            echo "Socket Connection Successful." | Out-File $log_file -width 240 -Append #logs the result
            $stream = $socket.GetStream() #gets the output of the response
                   
            $buffer = new-object System.Byte[] 1024
            $encoding = new-object System.Text.AsciiEncoding

            Start-Sleep -Milliseconds 500 #records data for half a second
            while($stream.DataAvailable)
            {
                $read = $stream.Read($buffer, 0, 1024)  
                $response=$encoding.GetString($buffer, 0, $read)
                if($response -like '*ICA*'){
                    Write-Host "ICA protocol  found." -ForegroundColor Green
                    echo "ICA protocol  found." | Out-File $log_file -width 240 -Append #logs 

                } else {
                    echo "Something else responded."
                    echo "Something else responded." | Out-File $log_file -width 240 -Append #logs

                }
            }
           
        } else {
            echo "Socket connection failed."
            echo "Socket connection failed." | Out-File $log_file -width 240 -Append #logs the result
        }
    }
}
