#!/bin/bash
# Usage: ./release.sh <major|minor|patch> "Message de la release"

TYPE=$1
MESSAGE=$2

if [[ -z "$TYPE" || -z "$MESSAGE" ]]; then
  echo "Usage: $0 <major|minor|patch> \"Message de la release\""
  exit 1
fi

VERSION_FILE="VERSION"
if [[ ! -f $VERSION_FILE ]]; then
  echo "1.0.0" > $VERSION_FILE
fi

VERSION=$(cat $VERSION_FILE)
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$TYPE" in
  major)
    ((MAJOR++))
    MINOR=0
    PATCH=0
    ;;
  minor)
    ((MINOR++))
    PATCH=0
    ;;
  patch)
    ((PATCH++))
    ;;
  *)
    echo "Type invalide. Utiliser major, minor ou patch."
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo $NEW_VERSION > $VERSION_FILE
echo "Nouvelle version : $NEW_VERSION"

CHANGELOG="CHANGELOG.md"
DATE=$(date '+%Y-%m-%d')

# Prepend new changelog entry
tmpfile=$(mktemp)
echo -e "## [$NEW_VERSION] - $DATE\n### Added\n- $MESSAGE\n\n" > "$tmpfile"
cat "$CHANGELOG" >> "$tmpfile"
mv "$tmpfile" "$CHANGELOG"

echo "CHANGELOG.md mis à jour."
