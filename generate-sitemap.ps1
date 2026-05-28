# sitemap.xml 자동 생성 스크립트
# 배관/청소/인테리어 등 하위 폴더의 모든 .html 파일을 자동 감지

$baseUrl = "https://bnikorea.us"
$today   = (Get-Date).ToString("yyyy-MM-dd")

# 스크립트 위치 결정
if ($PSScriptRoot) {
    $siteRoot = $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    $siteRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    $siteRoot = (Get-Location -PSProvider FileSystem).Path
}

$outPath = [System.IO.Path]::Combine($siteRoot, "sitemap.xml")

# 제외할 루트 파일 목록
$excludeFiles   = @("index.html", "admin.html", "setup.sql")
$excludePattern = "^naver"

# URL 인코딩: 한글 경로 → 퍼센트 인코딩
function Encode-Path($relativePath) {
    $parts   = $relativePath.Replace("\", "/").Split("/")
    $encoded = $parts | ForEach-Object { [Uri]::EscapeDataString($_) }
    return $encoded -join "/"
}

# 하위 디렉토리 html 파일 수집
$htmlFiles = Get-ChildItem -Path $siteRoot -Recurse -Filter "*.html" |
    Where-Object {
        $_.DirectoryName -ne $siteRoot -and
        $_.Name -notmatch $excludePattern -and
        $excludeFiles -notcontains $_.Name
    } |
    Sort-Object FullName

# XML 빌드
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('<?xml version="1.0" encoding="UTF-8"?>')
$lines.Add('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
$lines.Add('')
$lines.Add('  <!-- 메인 -->')
$lines.Add('  <url>')
$lines.Add("    <loc>$baseUrl/</loc>")
$lines.Add("    <lastmod>$today</lastmod>")
$lines.Add('    <changefreq>weekly</changefreq>')
$lines.Add('    <priority>1.0</priority>')
$lines.Add('  </url>')

$currentCategory = ""

foreach ($file in $htmlFiles) {
    $relative = $file.FullName.Substring($siteRoot.Length + 1)
    $category = $relative.Split("\")[0]

    if ($category -ne $currentCategory) {
        $lines.Add('')
        $lines.Add("  <!-- $category -->")
        $currentCategory = $category
    }

    $encodedPath = Encode-Path $relative
    $url         = "$baseUrl/$encodedPath"
    $priority    = if ($file.Name -eq "1.html") { "0.8" } else { "0.7" }

    $lines.Add('  <url>')
    $lines.Add("    <loc>$url</loc>")
    $lines.Add("    <lastmod>$today</lastmod>")
    $lines.Add('    <changefreq>monthly</changefreq>')
    $lines.Add("    <priority>$priority</priority>")
    $lines.Add('  </url>')
}

$lines.Add('')
$lines.Add('</urlset>')

# UTF-8 BOM 없이 저장
$content = $lines -join "`r`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outPath, $content, $utf8NoBom)

Write-Host "sitemap.xml 생성 완료 — $($htmlFiles.Count + 1)개 URL" -ForegroundColor Green
Write-Host "저장 경로: $outPath"
