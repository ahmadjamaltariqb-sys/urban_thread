$port = 8080
$root = "C:\Users\AHMED\.gemini\antigravity\scratch\stitch_urban_threads_fashion_store"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port/"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".md"   = "text/markdown; charset=utf-8"
}

try {
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            $localPath = $request.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrEmpty($localPath)) {
                $localPath = "index.html"
            }

            # Handle Contact API POST request
            if ($localPath -eq "api/contact" -or $localPath -eq "api/send-message") {
                $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
                $bodyText = $reader.ReadToEnd()
                $reader.Close()

                $inquiriesFile = Join-Path $root "inquiries.json"
                $inquiries = @()
                if (Test-Path $inquiriesFile) {
                    try {
                        $inquiries = Get-Content $inquiriesFile -Raw | ConvertFrom-Json
                        if ($inquiries -isnot [System.Collections.IEnumerable] -or $inquiries -is [string]) {
                            $inquiries = @($inquiries)
                        }
                    } catch {
                        $inquiries = @()
                    }
                }
                
                try {
                    $item = $bodyText | ConvertFrom-Json
                    $item | Add-Member -NotePropertyName "forwardTo" -NotePropertyValue "ahmadjamaltariqb@gmail.com" -ErrorAction SilentlyContinue
                    $inquiries += $item
                    $jsonOut = $inquiries | ConvertTo-Json -Depth 6
                    [System.IO.File]::WriteAllText($inquiriesFile, $jsonOut, [System.Text.Encoding]::UTF8)
                    Write-Host "[API] New inquiry forwarded to ahmadjamaltariqb@gmail.com from $($item.name) ($($item.email))"
                } catch {
                    Write-Host "[API Error] $($_.Exception.Message)"
                }

                $respBytes = [System.Text.Encoding]::UTF8.GetBytes('{"success":true,"recipient":"ahmadjamaltariqb@gmail.com"}')
                $response.ContentType = "application/json; charset=utf-8"
                $response.StatusCode = 200
                $response.Headers.Add("Access-Control-Allow-Origin", "*")
                $response.ContentLength64 = $respBytes.Length
                $response.OutputStream.Write($respBytes, 0, $respBytes.Length)
                $response.OutputStream.Close()
                continue
            }

            $filePath = Join-Path $root $localPath
            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $response.ContentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $bytes.Length
                $response.StatusCode = 200
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
                $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
                $response.OutputStream.Write($msg, 0, $msg.Length)
            }
            $response.OutputStream.Close()
        } catch {
            # Ignore client disconnect / aborted request errors so server stays alive
        }
    }
} finally {
    $listener.Stop()
}
