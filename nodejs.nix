# Node.js and npm development environment
{ config, pkgs, ... }:

{
  # Install Node.js and npm packages
  environment.systemPackages = with pkgs; [
    # Node.js LTS version with npm (npm is included with nodejs)
    nodejs_20  # or nodejs_18, nodejs_22 for different versions
    
    # Package managers
    yarn       # Alternative package manager
    pnpm       # Fast, disk space efficient package manager
    corepack   # Package manager manager (enables yarn/pnpm)
    
    # Core development tools that are commonly available
    nodePackages.typescript    # TypeScript compiler
    nodePackages.typescript-language-server  # TypeScript LSP
    
    # Note: Many packages can be installed locally per project with npm/yarn/pnpm
    # or globally with: npm install -g <package-name>
    # This approach is often better for project-specific versions
    
    # Uncomment specific packages as needed (check availability first):
    # nodePackages.nodemon       # Auto-restart on file changes  
    # nodePackages.ts-node       # TypeScript execution for Node.js
    # nodePackages.eslint        # JavaScript/TypeScript linter
    # nodePackages.prettier      # Code formatter
    # nodePackages.webpack       # Module bundler
    # nodePackages.pm2           # Process manager
    # nodePackages.http-server   # Simple HTTP server
  ];

  # Configure npm to use a user-writable directory for global packages
  environment.variables = {
    # Set npm prefix to user directory to avoid permission issues
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Optional: Configure npm registry and other settings globally
  environment.etc."npmrc".text = ''
    # Configure prefix for global packages
    prefix=/home/leevisuo/.npm-global
    
    # Configure cache directory  
    cache=/home/leevisuo/.npm-cache
    
    # Set log level
    loglevel=warn
    
    # Optional: Use faster registry mirror
    # registry=https://registry.npmjs.org/
  '';
}