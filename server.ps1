$port = 8080
$root = "C:\Users\AHMED\.gemini\antigravity\scratch\stitch_urban_threads_fashion_store"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "=========================================================="
Write-Host " Urban Threads Local Server & Admin Studio Running!       "
Write-Host " Storefront:       http://localhost:$port/                "
Write-Host " Admin Dashboard:  http://localhost:$port/dashboard.html  "
Write-Host "=========================================================="

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

function Send-JsonResponse($response, $data, $statusCode = 200) {
    $json = $data | ConvertTo-Json -Depth 10
    $respBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $response.ContentType = "application/json; charset=utf-8"
    $response.StatusCode = $statusCode
    $response.Headers.Add("Access-Control-Allow-Origin", "*")
    $response.ContentLength64 = $respBytes.Length
    $response.OutputStream.Write($respBytes, 0, $respBytes.Length)
    $response.OutputStream.Close()
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

            # Dashboard shortcuts
            if ($localPath -eq "dashboard" -or $localPath -eq "admin" -or $localPath -eq "admin/") {
                $localPath = "dashboard.html"
            }

            # ----------------------------------------------------
            # API: GET / POST Products Data
            # ----------------------------------------------------
            if ($localPath -eq "api/products") {
                $prodFile = Join-Path $root "data\products.json"
                if ($request.HttpMethod -eq "GET") {
                    if (Test-Path $prodFile) {
                        $content = Get-Content $prodFile -Raw -Encoding UTF8
                        $respBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
                        $response.ContentType = "application/json; charset=utf-8"
                        $response.StatusCode = 200
                        $response.Headers.Add("Access-Control-Allow-Origin", "*")
                        $response.ContentLength64 = $respBytes.Length
                        $response.OutputStream.Write($respBytes, 0, $respBytes.Length)
                        $response.OutputStream.Close()
                    } else {
                        Send-JsonResponse $response @{ products = @() }
                    }
                    continue
                } elseif ($request.HttpMethod -eq "POST") {
                    $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
                    $bodyText = $reader.ReadToEnd()
                    $reader.Close()

                    [System.IO.File]::WriteAllText($prodFile, $bodyText, [System.Text.Encoding]::UTF8)
                    Write-Host "[Admin Studio] Products catalog updated."
                    Send-JsonResponse $response @{ success = $true; message = "Products updated successfully!" }
                    continue
                }
            }

            # ----------------------------------------------------
            # API: GET / POST Store Settings
            # ----------------------------------------------------
            if ($localPath -eq "api/settings") {
                $setFile = Join-Path $root "data\settings.json"
                if ($request.HttpMethod -eq "GET") {
                    if (Test-Path $setFile) {
                        $content = Get-Content $setFile -Raw -Encoding UTF8
                        $respBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
                        $response.ContentType = "application/json; charset=utf-8"
                        $response.StatusCode = 200
                        $response.Headers.Add("Access-Control-Allow-Origin", "*")
                        $response.ContentLength64 = $respBytes.Length
                        $response.OutputStream.Write($respBytes, 0, $respBytes.Length)
                        $response.OutputStream.Close()
                    } else {
                        Send-JsonResponse $response @{ storeName = "Urban Threads" }
                    }
                    continue
                } elseif ($request.HttpMethod -eq "POST") {
                    $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
                    $bodyText = $reader.ReadToEnd()
                    $reader.Close()

                    [System.IO.File]::WriteAllText($setFile, $bodyText, [System.Text.Encoding]::UTF8)
                    Write-Host "[Admin Studio] Store settings updated."
                    Send-JsonResponse $response @{ success = $true; message = "Settings updated successfully!" }
                    continue
                }
            }

            # ----------------------------------------------------
            # API: GET Inquiries
            # ----------------------------------------------------
            if ($localPath -eq "api/inquiries") {
                $inqFile = Join-Path $root "inquiries.json"
                if (Test-Path $inqFile) {
                    $content = Get-Content $inqFile -Raw -Encoding UTF8
                    $respBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
                    $response.ContentType = "application/json; charset=utf-8"
                    $response.StatusCode = 200
                    $response.Headers.Add("Access-Control-Allow-Origin", "*")
                    $response.ContentLength64 = $respBytes.Length
                    $response.OutputStream.Write($respBytes, 0, $respBytes.Length)
                    $response.OutputStream.Close()
                } else {
                    Send-JsonResponse $response @()
                }
                continue
            }

            # ----------------------------------------------------
            # Handle Contact API POST request
            # ----------------------------------------------------
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

                Send-JsonResponse $response @{ success = $true; recipient = "ahmadjamaltariqb@gmail.com" }
                continue
            }

            # ----------------------------------------------------
            # API: POST 1-Click Sync to GitHub
            # ----------------------------------------------------
            if ($localPath -eq "api/sync-github") {
                try {
                    Set-Location $root
                    git add .
                    git commit -m "Admin Studio dashboard update" -ErrorAction SilentlyContinue
                    git push origin main
                    Write-Host "[Admin Studio] Synced to GitHub & Live Site."
                    Send-JsonResponse $response @{ success = $true; message = "Pushed to GitHub successfully!" }
                } catch {
                    Send-JsonResponse $response @{ success = $false; message = $_.Exception.Message } 500
                }
                continue
            }

            # ----------------------------------------------------
            # Static File Serving
            # ----------------------------------------------------
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
            # Ignore client disconnect
        }
    }
} finally {
    $listener.Stop()
}
