# sitemap.xml 자동 생성 스크립트
# 모든 하위 폴더 .html 파일 자동 감지 -> 퍼센트 인코딩 URL 생성

$baseUrl  = "https://bnikorea.us"
$today    = (Get-Date).ToString("yyyy-MM-dd")
$siteRoot = "C:\Users\gkxos\Desktop\bnikorea-site"
$outPath  = "$siteRoot\sitemap.xml"

$excludeFiles   = @("index.html", "admin.html", "setup.sql")
$excludePattern = "^naver"

$htmlFiles = Get-ChildItem -Path $siteRoot -Recurse -Filter "*.html" |
    Where-Object {
        $_.DirectoryName -ne $siteRoot -and
        $_.Name -notmatch $excludePattern -and
        ($excludeFiles -notcontains $_.Name)
    } |
    Sort-Object FullName

$sb = [System.Text.StringBuilder]::new()
$null = $sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
$null = $sb.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
$null = $sb.AppendLine('  <!-- 메인 -->')
$null = $sb.AppendLine('  <url>')
$null = $sb.AppendLine("    <loc>$baseUrl/</loc>")
$null = $sb.AppendLine("    <lastmod>$today</lastmod>")
$null = $sb.AppendLine('    <changefreq>weekly</changefreq>')
$null = $sb.AppendLine('    <priority>1.0</priority>')
$null = $sb.AppendLine('  </url>')

$currentCat = ""
foreach ($file in $htmlFiles) {
    $rel = $file.FullName.Substring($siteRoot.Length + 1)
    $cat = $rel.Split("\")[0]

    if ($cat -ne $currentCat) {
        $null = $sb.AppendLine("  <!-- $cat -->")
        $currentCat = $cat
    }

    $parts   = $rel.Replace("\", "/").Split("/")
    $encoded = ($parts | ForEach-Object { [Uri]::EscapeDataString($_) }) -join "/"
    $url     = "$baseUrl/$encoded"
    $pri     = if ($file.Name -eq "1.html") { "0.8" } else { "0.7" }

    $null = $sb.AppendLine('  <url>')
    $null = $sb.AppendLine("    <loc>$url</loc>")
    $null = $sb.AppendLine("    <lastmod>$today</lastmod>")
    $null = $sb.AppendLine('    <changefreq>monthly</changefreq>')
    $null = $sb.AppendLine("    <priority>$pri</priority>")
    $null = $sb.AppendLine('  </url>')
}

$null = $sb.AppendLine('</urlset>')

$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), $utf8)

Write-Host "sitemap.xml 완료 -- $($htmlFiles.Count + 1)개 URL" -ForegroundColor Green
Write-Host "경로: $outPath"
