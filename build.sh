#!/bin/bash
set -e

echo "=== Ensuring required asset directories and files exist ==="
mkdir -p credentials
touch credentials/.gitkeep

if [ ! -f .env ]; then
  if [ -n "$MAPBOX_ACCESS_TOKEN" ]; then
    echo "Creating .env from Vercel MAPBOX_ACCESS_TOKEN..."
    echo "MAPBOX_ACCESS_TOKEN=$MAPBOX_ACCESS_TOKEN" > .env
  elif [ -f .env.example ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
  else
    touch .env
  fi
fi

echo "=== Checking Flutter SDK ==="
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

echo "=== Building Flutter Web ==="
flutter config --enable-web
flutter pub get
flutter build web --release

echo "=== Flutter Web Build Complete ==="
