# Git Performance Optimization Commands

# These have been applied to speed up Git operations:

# 1. Enable preload index (faster file operations)
git config --global core.preloadindex true

# 2. Enable file system cache (Windows optimization)  
git config --global core.fscache true

# 3. Disable auto garbage collection during operations
git config --global gc.auto 0

# 4. Optimize for large repositories
git config --global core.untrackedCache true

# 5. Enable parallel processing
git config --global checkout.workers 0

# 6. Set reasonable defaults
git config --global fetch.parallel 0

# Additional Windows-specific optimizations:
git config --global core.autocrlf false
git config --global core.symlinks false
