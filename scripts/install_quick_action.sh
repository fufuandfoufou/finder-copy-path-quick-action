#!/bin/zsh
set -euo pipefail

SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_NAME="Copy Absolute Path"
WORKFLOW_DIR="$SERVICES_DIR/$WORKFLOW_NAME.workflow"
CONTENTS_DIR="$WORKFLOW_DIR/Contents"
DOCUMENT_WFLOW="$CONTENTS_DIR/document.wflow"
INFO_PLIST="$CONTENTS_DIR/Info.plist"
LOG_DIR="$HOME/.finder-copy-path"

mkdir -p "$SERVICES_DIR" "$LOG_DIR"
rm -rf "$WORKFLOW_DIR"
mkdir -p "$CONTENTS_DIR"

cat > "$DOCUMENT_WFLOW" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>AAModelVersion</key>
  <integer>1</integer>
  <key>AAWorkflowType</key>
  <string>Action</string>
  <key>actions</key>
  <array>
    <dict>
      <key>action</key>
      <dict>
        <key>ActionBundlePath</key>
        <string>/System/Library/Automator/Run AppleScript.action</string>
        <key>ActionName</key>
        <string>Run AppleScript</string>
        <key>ActionParameters</key>
        <dict>
          <key>source</key>
          <string>on run {input, parameters}
	set logDir to POSIX path of ((path to home folder as text) &amp; ".finder-copy-path")
	set logFile to logDir &amp; "/quick-action.log"
	do shell script "/bin/mkdir -p " &amp; quoted form of logDir
	do shell script "/bin/echo ===== quick-action ===== &gt;&gt; " &amp; quoted form of logFile
	set outputText to ""
	repeat with anItem in input
		try
			set p to POSIX path of anItem
		on error
			set p to (anItem as text)
		end try
		do shell script "/bin/echo " &amp; quoted form of p &amp; " &gt;&gt; " &amp; quoted form of logFile
		if outputText is not "" then set outputText to outputText &amp; linefeed
		set outputText to outputText &amp; p
	end repeat
	if outputText is not "" then
		set the clipboard to outputText
		try
			display notification "Absolute path copied to clipboard" with title "Copy Absolute Path"
		end try
	end if
	return input
end run</string>
        </dict>
        <key>BundleIdentifier</key>
        <string>com.apple.RunAppleScript</string>
        <key>CFBundleVersion</key>
        <string>2.0.1</string>
        <key>CanShowSelectedItemsWhenRun</key>
        <true/>
        <key>Category</key>
        <array>
          <string>AMCategoryUtilities</string>
        </array>
        <key>Class Name</key>
        <string>RunAppleScriptAction</string>
        <key>Keywords</key>
        <array/>
        <key>UUID</key>
        <string>8A7B1B9C-0B9A-4A4A-8E77-COPYABSAPPLE0001</string>
      </dict>
      <key>isViewVisible</key>
      <true/>
    </dict>
  </array>
  <key>connectors</key>
  <dict/>
  <key>state</key>
  <dict>
    <key>bundleIdentifierHistory</key>
    <array>
      <string>com.apple.RunAppleScript</string>
    </array>
    <key>selectedView</key>
    <integer>0</integer>
  </dict>
  <key>workflowMetaData</key>
  <dict>
    <key>applicationBundleID</key>
    <string>com.apple.Automator</string>
    <key>applicationVersion</key>
    <string>2.10</string>
    <key>documentVersion</key>
    <string>2</string>
    <key>inputTypeIdentifier</key>
    <string>com.apple.Automator.fileSystemObject</string>
    <key>outputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>presentationMode</key>
    <integer>15</integer>
    <key>processesInput</key>
    <integer>0</integer>
    <key>serviceInputTypeIdentifier</key>
    <string>com.apple.Automator.fileSystemObject</string>
    <key>serviceOutputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>serviceProcessesInput</key>
    <integer>0</integer>
    <key>systemImageName</key>
    <string>doc.on.doc</string>
    <key>workflowTypeIdentifier</key>
    <string>com.apple.Automator.servicesMenu</string>
  </dict>
</dict>
</plist>
EOF

cat > "$INFO_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>Automator Runner</string>
  <key>CFBundleIdentifier</key>
  <string>local.finder.copyabsolutepath</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$WORKFLOW_NAME</string>
  <key>CFBundlePackageType</key>
  <string>XPC!</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>NSServices</key>
  <array>
    <dict>
      <key>NSMenuItem</key>
      <dict>
        <key>default</key>
        <string>$WORKFLOW_NAME</string>
      </dict>
      <key>NSMessage</key>
      <string>runWorkflowAsService</string>
      <key>NSPortName</key>
      <string>$WORKFLOW_NAME</string>
      <key>NSSendFileTypes</key>
      <array>
        <string>public.item</string>
      </array>
    </dict>
  </array>
</dict>
</plist>
EOF

/usr/bin/pluginkit -a "$WORKFLOW_DIR" >/dev/null 2>&1 || true
/usr/bin/killall Finder >/dev/null 2>&1 || true

echo "Installed Quick Action: $WORKFLOW_NAME"
echo "Location: $WORKFLOW_DIR"
echo "Log file: $LOG_DIR/quick-action.log"
