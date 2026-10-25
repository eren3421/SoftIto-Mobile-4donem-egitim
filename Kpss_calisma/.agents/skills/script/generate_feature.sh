#!/bin/bash
# Feature Scaffolding Helper Script
if [ -z "$1" ]; then
  echo "Kullanım: ./generate_feature.sh <feature_name>"
  exit 1
fi

FEATURE_NAME=$1
TARGET_DIR="lib/features/$FEATURE_NAME"

mkdir -p "$TARGET_DIR/widgets"
touch "$TARGET_DIR/${FEATURE_NAME}_screen.dart"

echo "Özellik dizini oluşturuldu: $TARGET_DIR"
echo "- $TARGET_DIR/${FEATURE_NAME}_screen.dart"
echo "- $TARGET_DIR/widgets/"
