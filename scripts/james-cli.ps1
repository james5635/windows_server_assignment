# ----------------------------------------------------------------------------
# PowerShell startup script for Apache James CLI (no setenv.bat)
# ----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# ----- BASEDIR = parent of current script path -----
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BASEDIR = Resolve-Path "$ScriptDir\.."

Write-Host "Base directory: $BASEDIR"

# ----- Defaults -----
$JAVACMD = "java"
$JAVA_OPTS = ""
$REPO = "lib"   # original default is ..\lib relative to BASEDIR

# ----- Resolve paths -----
$ConfPath = Join-Path $BASEDIR "conf"
$RepoPath = Join-Path $BASEDIR $REPO

if (!(Test-Path $ConfPath)) {
    throw "conf/ folder not found: $ConfPath"
}

if (!(Test-Path $RepoPath)) {
    throw "lib/ folder not found: $RepoPath"
}

# ----- Build classpath (ABSOLUTE PATHS, MANDATORY FOR JAVA) -----
$CLASSPATH = "$ConfPath;$RepoPath\*"

Write-Host "Classpath: $CLASSPATH"

# ----- Build Java args -----
$JavaArgs = @(
    $JAVA_OPTS
    "-XX:+HeapDumpOnOutOfMemoryError"
    "-Xms128m"
    "-Xmx512m"
    "-Dcom.sun.management.jmxremote=true"
    "-Dcom.sun.management.jmxremote.authenticate=false"
    "-Dmail.mime.multipart.ignoremissingendboundary=true"
    "-Dmail.mime.multipart.ignoremissingboundaryparameter=true"
    "-Dmail.mime.ignoreunknownencoding=true"
    "-Dmail.mime.uudecode.ignoreerrors=true"
    "-Dmail.mime.uudecode.ignoremissingbeginend=true"
    "-Dmail.mime.multipart.allowempty=true"
    "-Dmail.mime.base64.ignoreerrors=true"
    "-Dmail.mime.encodeparameters=true"
    "-Dmail.mime.decodeparameters=true"
    "-Dmail.mime.address.strict=false"
    "-Djmx.remote.x.mlet.allow.getMBeansFromURL=false"
    "-Djames.jmx.unregister.log4j.mbeans=true"
    "-Djames.message.usememorycopy=false"
    "-Djdk.tls.ephemeralDHKeySize=2048"
    "-Dopenjpa.Multithreaded=true"
    "-cp"
    "`"$CLASSPATH`""
    "-Dapp.name=james-cli"
    "-Dapp.repo=$RepoPath"
    "-Dapp.home=$BASEDIR"
    "-Dbasedir=$BASEDIR"
    "org.apache.james.cli.ServerCmd"
)

# ----- Add user arguments -----
$JavaArgs += $args

# ----- Run Java -----
Write-Host "Running James CLI..."
& $JAVACMD @JavaArgs

exit $LASTEXITCODE
