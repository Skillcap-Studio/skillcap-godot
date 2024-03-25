#!/bin/bash
set -e

# Define the version of the Godot engine
GODOT_VERSION=$(python -c "from version import *; print(str(major) + '.' + str(minor) + '.' + str(patch))")

echo "Select build option:"
echo "1. Build engine"
echo "2. Build export templates"
echo "3. Build both engine and export templates"
read -p "Enter your choice (1/2/3): " BUILD_CHOICE

build_engine() {
  # Compile for Intel (x86-64) powered Macs
  scons platform=macos arch=x86_64 module_text_server_fb_enabled=yes

  # Compile for Apple Silicon (ARM64) powered Macs
  scons platform=macos arch=arm64 module_text_server_fb_enabled=yes

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

  echo "Built Godot Skillcap for macOS! The app bundle is located in the 'build' directory."
}

build_export_templates() {
  echo "Select template build mode:"
  echo "1. Release"
  echo "2. Debug"
  echo "3. Both"
  read -p "Enter your choice (1/2/3): " TEMPLATE_MODE

  case $TEMPLATE_MODE in
    1)
      scons platform=macos target=template_release arch=x86_64
      scons platform=macos target=template_release arch=arm64
      ;;
    2)
      scons platform=macos target=template_debug arch=x86_64
      scons platform=macos target=template_debug arch=arm64
      ;;
    3)
      scons platform=macos target=template_release arch=x86_64
      scons platform=macos target=template_debug arch=x86_64
      scons platform=macos target=template_release arch=arm64
      scons platform=macos target=template_debug arch=arm64
      ;;
    *)
      echo "Invalid choice. Exiting."
      exit 1
      ;;
  esac

  echo "Built export templates for macOS."
}

case $BUILD_CHOICE in
  1)
    build_engine
    ;;
  2)
    build_export_templates
    ;;
  3)
    build_engine
    build_export_templates
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Print the custom build name
echo "Generated Godot Skillcap build based on Godot Engine version $GODOT_VERSION"
