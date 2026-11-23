#!/usr/bin/env bash
# Checks that SiteCore, the app's model, stays free of UI frameworks and of global state.
# Usage: check.sh [repository root]
set -uo pipefail

root="${1:-.}"
core="$root/SiteKit/Sources/SiteCore"
status=0

fail() {
  echo "::error::$1"
  status=1
}

# Source lines of SiteCore without the comment lines, as "file:line:text".
code() {
  grep -rn --include='*.swift' '' "$core" | grep -vE '^[^:]+:[0-9]+:\s*//'
}

# 1. A UI or App Intents framework.
if hits=$(code | grep -E ':\s*import\s+(SwiftUI|UIKit|AppKit|WidgetKit|AppIntents)\b'); then
  echo "$hits"
  fail "SiteCore must not import a UI or App Intents framework. The views are in SiteUI, and the app supplies what needs the others."
fi

# 2. Global state, reached without being given.
if hits=$(code | grep -E '\.shared\b|UserDefaults|\.standard\b|Bundle\.main|ProcessInfo\.processInfo'); then
  echo "$hits"
  fail "SiteCore must not reach a singleton, user defaults, the main bundle or the process. Take it as a parameter, with the app's own as the app's choice."
fi

# 3. A shared service, allowed only as the default of a parameter that a test can replace.
if hits=$(code | awk '{
  text = $0
  sub(/^[^:]+:[0-9]+:/, "", text)
  if (text ~ /(FileManager|NotificationCenter|CSSearchableIndex)\.default/ \
      && text !~ /[A-Za-z_]+: *[^=:]+= *(FileManager|NotificationCenter)\.default/) print
}'); [ -n "$hits" ]; then
  echo "$hits"
  fail "SiteCore may use FileManager.default or NotificationCenter.default only as the default value of a parameter."
fi

if [ "$status" -eq 0 ]; then
  echo "SiteCore keeps to its boundaries."
fi
exit "$status"
