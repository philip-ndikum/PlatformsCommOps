#!/bin/bash

echo "🧹 Cleaning development environment..."

# Check if we're in a hatch shell
if [[ -n "${VIRTUAL_ENV}" ]]; then
    echo "⚠️  Please exit the hatch shell first (use 'exit' command')"
    exit 1
fi

# Check if Jupyter exists
if command -v jupyter &> /dev/null; then
    # List current kernels
    echo "📋 Current Jupyter kernels:"
    jupyter kernelspec list

    # Remove all project-related Jupyter kernels
    echo "🗑️  Removing project-related Jupyter kernels..."
    jupyter kernelspec list | grep -E "project|gpu-project" | awk '{print $1}' | xargs -I {} jupyter kernelspec remove -f {}
else
    echo "⚠️ Jupyter is not installed or available on this system."
fi

# Clean Hatch environments
if command -v hatch &> /dev/null; then
    echo "🧼 Cleaning Hatch environments..."
    hatch env prune
    rm -rf ~/.local/share/hatch/env/virtual/*
else
    echo "⚠️ Hatch is not installed or available on this system."
fi

# Clean Conda environments
if command -v conda &> /dev/null; then
    echo "🐍 Cleaning Conda environments..."
    CONDA_ENVS=$(conda env list | grep project | awk '{print $1}')
    if [ -n "$CONDA_ENVS" ]; then
        echo "Found Conda environments to remove:"
        echo "$CONDA_ENVS"
        for env in $CONDA_ENVS; do
            echo "Removing Conda environment: $env"
            conda env remove -n "$env" -y
        done
    else
        echo "No project-related Conda environments found"
    fi
else
    echo "⚠️ Conda is not installed or available on this system."
fi

# Clean Poetry environments
if command -v poetry &> /dev/null; then
    echo "🎵 Cleaning Poetry environments..."
    POETRY_ENVS=$(poetry env list --full-path | awk '{print $1}')
    if [ -n "$POETRY_ENVS" ]; then
        echo "Found Poetry environments to remove:"
        echo "$POETRY_ENVS"
        for env_path in $POETRY_ENVS; do
            echo "Removing Poetry environment at: $env_path"
            rm -rf "$env_path"
        done
    else
        echo "No Poetry environments found."
    fi
else
    echo "⚠️ Poetry is not installed or available on this system."
fi

# Clear pip cache
echo "🛠️  Cleaning pip cache..."
pip cache purge

# Clear Python cache
echo "🗑️  Clearing Python cache..."
find . -type d -name "__pycache__" -exec rm -r {} +
find . -name "*.pyc" -delete

# Remove build artifacts
echo "🔨 Removing build artifacts..."
find . -type d -name "build" -exec rm -r {} +
find . -type d -name "dist" -exec rm -r {} +
find . -type d -name "*.egg-info" -exec rm -r {} +

# Clean Hatch metadata cache
echo "🧼 Cleaning Hatch metadata cache..."
rm -rf ~/.cache/hatch

# Clean log files
echo "📝 Cleaning old log files..."
find . -type f -name "*.log" -delete

echo "✨ Environment cleaned! You’re ready to start fresh!"
