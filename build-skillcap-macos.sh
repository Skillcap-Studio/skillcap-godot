#!/bin/bash
set -e

# Define the version of the Godot engine
GODOT_VERSION=$(python -c "from version import *; print(str(major) + '.' + str(minor) + '.' + str(patch))")

# Compile for Intel (x86-64) powered Macs
scons platform=macos arch=x86_64

# Compile for Apple Silicon (ARM64) powered Macs
scons platform=macos arch=arm64

# Bundle both architectures into a single "Universal 2" binary
lipo -create bin/godot.macos.editor.x86_64 bin/godot.macos.editor.arm64 -output bin/godot.macos.editor.universal

# Check if build directory exists, if not create it
if [ ! -d "build" ]; then
  mkdir build
fi

# Create an .app bundle
cp -r misc/dist/macos_tools.app ./build/Godot\ Skillcap.app
mkdir -p build/Godot\ Skillcap.app/Contents/MacOS
cp bin/godot.macos.editor.universal build/Godot\ Skillcap.app/Contents/MacOS/Godot
chmod +x build/Godot\ Skillcap.app/Contents/MacOS/Godot
codesign --force --timestamp --options=runtime --entitlements misc/dist/macos/editor.entitlements -s - build/Godot\ Skillcap.app

# Print the custom build name
echo "Generated Godot Skillcap build based on Godot Engine version $GODOT_VERSION"
