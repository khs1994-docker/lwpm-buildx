Import-Module downloader
Import-Module unzip
Import-Module command
Import-Module cleanup
Import-Module exportPath

$lwpm=ConvertFrom-Json -InputObject (get-content $PSScriptRoot/lwpm.json -Raw)

$stableVersion=$lwpm.version
$preVersion=$lwpm.preVersion
$githubRepo=$lwpm.github
$homepage=$lwpm.homepage
$releases=$lwpm.releases
$bug=$lwpm.bug
$name=$lwpm.name
$description=$lwpm.description
$url=$lwpm.url
$preUrl=$lwpm.preUrl

Function install_after(){

}

Function install($VERSION=0,$isPre=0){
  if(!($VERSION)){
    $VERSION=$stableVersion
  }

  $url=$url.replace('${VERSION}',${VERSION});

  if($isPre){
    $VERSION=$preVersion
    # $url=$preUrl.replace('${VERSION}',${VERSION});
  }else{

  }

  $filename="buildx-v${VERSION}.windows-amd64.exe"
  $unzipDesc="example"

  # _exportPath "/path"
  # $env:path=[environment]::GetEnvironmentvariable("Path","user") `
  #           + ';' + [environment]::GetEnvironmentvariable("Path","machine")

  if($(_command docker)){
    $CURRENT_VERSION=$(docker buildx version).split(' ')[1].trim('v')

    if ($CURRENT_VERSION -eq $VERSION){
        echo "==> $name $VERSION already install"
        return
    }
  }

  # 下载原始 zip 文件，若存在则不再进行下载
  _downloader `
    $url `
    $filename `
    $name `
    $VERSION

  # 验证原始 zip 文件 Fix me

  # 解压 zip 文件 Fix me
  # _cleanup "$unzipDesc"
  # _unzip $filename $unzipDesc

  _mkdir $HOME/.docker/cli-plugins/
  # 安装 Fix me
  Copy-item -r -force "$filename" "$HOME/.docker/cli-plugins/docker-buildx.exe"
  # Start-Process -FilePath $filename -wait
  # _cleanup "$unzipDesc"

  # [environment]::SetEnvironmentvariable("", "", "User")
  # _exportPath "/path"
  # $env:path=[environment]::GetEnvironmentvariable("Path","user") `
  #           + ';' + [environment]::GetEnvironmentvariable("Path","machine")

  install_after

  echo "==> Checking ${name} ${VERSION} install ..."
  # 验证 Fix me
  if($lwpm.scripts.test){
    powershell -c $lwpm.scripts.test
  }
}

Function uninstall($prune=0){
  _cleanup "$HOME/.docker/cli-plugins/docker-buildx.exe"
  # user data
  if($prune){
    # _cleanup ""
  }
}

Function getInfo(){
  . $PSScriptRoot\..\..\..\windows\sdk\github\repos\releases.ps1

  $latestVersion=(getLatestRelease $githubRepo).trim("")

  echo "
Package: $name
Version: $stableVersion
PreVersion: $preVersion
LatestVersion: $latestVersion
HomePage: $homepage
Releases: $releases
Bugs: $bug
Description: $description
"
}

Function bug(){
  return $bug
}

Function homepage(){
  return $homepage
}

Function releases(){
  return $releases
}
