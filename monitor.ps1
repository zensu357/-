# Define function to monitor program
function Monitor-Program {
    $lastStatus = ""
    $programPath = "D:\Log in\1.bat"
    
    # Main loop, used to restart program
    while ($true) {
        # Start 1.bat and capture output to temporary file
        $process = Start-Process $programPath -NoNewWindow -PassThru -RedirectStandardOutput "temp_output.txt"
        $lastLineNumber = 0
        
        # Inner loop, used to monitor program running status
        while (!$process.HasExited) {
            # Read new lines from output file
            if (Test-Path "temp_output.txt") {
                $allLines = Get-Content "temp_output.txt"
                $currentLineCount = $allLines.Count
                
                # Display new output lines
                if ($currentLineCount -gt $lastLineNumber) {
                    for ($i = $lastLineNumber; $i -lt $currentLineCount; $i++) {
                        Write-Host $allLines[$i]
                        
                        # Check if this line contains the trigger text
                        if ($allLines[$i] -match "Next Retry: 480") {
                            Write-Host "Detected 'Next Retry: 480' - Restarting program..." -ForegroundColor Yellow
                            
                            # Terminate current process
                            Stop-Process -Id $process.Id -Force
                            
                            # Clean up temporary file
                            Remove-Item "temp_output.txt" -ErrorAction SilentlyContinue
                            
                            # Reset status and break inner loop
                            $lastStatus = ""
                            break
                        }
                    }
                    $lastLineNumber = $currentLineCount
                }
            }
            
            # Wait before next check
            Start-Sleep -Milliseconds 100
        }
        
        # If program exits normally, clean up and continue loop
        if ($process.HasExited) {
            Remove-Item "temp_output.txt" -ErrorAction SilentlyContinue
            Write-Host "Program has exited, 3 seconds later will restart..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
        }
    }
}

# Run monitoring function
Write-Host "Starting monitor script..." -ForegroundColor Green
Write-Host "Watching for 'Next Retry: 480' pattern..." -ForegroundColor Green
Monitor-Program
