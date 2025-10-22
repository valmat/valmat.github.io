#!/usr/bin/env bash
set -euo pipefail

# Usage: ./new-post.sh [file_name]
# If no name is provided, prompt the user.

file_name="${1-}"

if [[ -z "$file_name" ]]; then
    read -r -p "Enter file name (slug): " file_name
fi

# Check for empty string (including spaces)
if [[ -z "${file_name// }" ]]; then
    echo "Error: file name cannot be empty." >&2
    exit 1
fi

# Check if Hugo is installed
if ! command -v hugo >/dev/null 2>&1; then
    echo "Error: 'hugo' command not found. Please install Hugo or add it to your PATH." >&2
    exit 127
fi

# Path to the new file
new_file="content/posts/${file_name}/index.md"
new_dir="content/posts/${file_name}/"
if [[ -d "$new_dir" ]]; then
    rm -rf "$new_dir"
fi


# Create the new post
hugo new "posts/${file_name}/index.md"


# Check if the file was created
if [[ ! -f "$new_file" ]]; then
    echo "Error: file '$new_file' was not created." >&2
    exit 2
fi

# Insert 'tags: []' before the closing --- in the front matter (only once)
awk '
    BEGIN {front=0}
    /^---$/ {
        front++
        if(front==2) print "tags: [\"archive\"]"
    }
    {print}
' "$new_file" > "${new_file}.tmp" && mv "${new_file}.tmp" "$new_file"

echo "Post created: $new_file"
