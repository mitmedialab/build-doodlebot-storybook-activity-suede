#!/usr/bin/env bash

set -euo pipefail

readonly TARGET_FOLDER="build-a-doodlebot"

# Script to create symlinks for build-a-doodlebot assets
# Usage: ./link.sh <target_location>

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Exactly one argument required" >&2
    echo "Usage: $0 <target_location>" >&2
    exit 1
fi

# Get the target location and validate it exists
TARGET_LOCATION="$1"

if [ ! -d "$TARGET_LOCATION" ]; then
    echo "Error: Target location does not exist: $TARGET_LOCATION" >&2
    exit 1
fi

# Get absolute path of target location
TARGET_LOCATION=$(cd "$TARGET_LOCATION" && pwd)

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the target folder name
readonly TARGET_PATH="$TARGET_LOCATION/$TARGET_FOLDER"

# Define asset directories relative to script location
readonly ASSET_DIRS=("images" "sounds" "videos")

# Check if build-a-doodlebot folder exists and remove it
if [ -d "$TARGET_PATH" ]; then
    echo "Removing existing folder: $TARGET_PATH"
    rm -rf "$TARGET_PATH"
fi

# Create the build-a-doodlebot folder
echo "Creating folder: $TARGET_PATH"
mkdir -p "$TARGET_PATH"

# Function to create symlinks recursively
create_symlinks() {
    local source_dir="$1"
    local target_dir="$2"
    local asset_type="$3"
    
    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory does not exist: $source_dir" >&2
        return 1
    fi
    
    echo "Processing $asset_type..."
    
    # Create target directory structure and symlinks
    find "$source_dir" -type d | while read -r dir; do
        # Get relative path from source_dir
        local rel_path="${dir#$source_dir}"
        rel_path="${rel_path#/}"
        
        # Create corresponding directory in target
        if [ -n "$rel_path" ]; then
            mkdir -p "$target_dir/$rel_path"
        fi
    done
    
    # Create symlinks for all files
    find "$source_dir" -type f | while read -r file; do
        # Get relative path from source_dir
        local rel_path="${file#$source_dir}"
        rel_path="${rel_path#/}"
        
        # Create symlink with relative path
        local target_file="$target_dir/$rel_path"
        local relative_source=$(realpath --relative-to="$(dirname "$target_file")" "$file")
        ln -sf "$relative_source" "$target_file"
    done
}

# Process each asset directory
for asset_dir in "${ASSET_DIRS[@]}"; do
    source_path="$SCRIPT_DIR/$asset_dir"
    target_asset_path="$TARGET_PATH/$asset_dir"
    
    if [ -d "$source_path" ]; then
        # Create the asset directory in target
        mkdir -p "$target_asset_path"
        
        # Create symlinks
        create_symlinks "$source_path" "$target_asset_path" "$asset_dir"
    else
        echo "Skipping $asset_dir (directory not found at $source_path)"
    fi
done

echo "Successfully created symlinks in: $TARGET_PATH"
exit 0
