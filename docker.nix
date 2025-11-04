# Docker configuration for development
{ config, pkgs, ... }:

{
  # Enable Docker with enhanced configuration for development
  virtualisation.docker = {
    enable = true;
    # Enable Docker daemon on boot
    enableOnBoot = true;
    # Configure Docker daemon for better development experience
    daemon.settings = {
      # Enable buildx for multi-platform builds
      experimental = true;
      # Configure storage driver (overlay2 is recommended)
      storage-driver = "overlay2";
      # Configure default logging driver
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
      # IPv6 configuration (properly configured with subnet)
      ipv6 = true;
      fixed-cidr-v6 = "2001:db8:1::/64";
      # Alternative: disable IPv6 if you don't need it
      # ipv6 = false;
    };
    # Enable rootless Docker (optional - uncomment if you prefer rootless mode)
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  # Enable Docker Compose as a system service (optional)
  # This allows running compose files as system services
  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  #     # Example container configuration
  #     # my-app = {
  #     #   image = "nginx:latest";
  #     #   ports = ["8080:80"];
  #     # };
  #   };
  # };

  # Docker and container development tools
  environment.systemPackages = with pkgs; [
    # Core Docker tools
    docker
    docker-compose
    docker-buildx  # Multi-platform build support
    
    # Container exploration and management tools
    dive           # Tool for exploring docker images
    lazydocker     # Terminal UI for docker
    
    # Additional tools (uncomment as needed)
    # ctop         # Top-like interface for container metrics
    # hadolint     # Dockerfile linter
    # skopeo       # Tool for various operations on container images
  ];

  # Ensure user is in docker group (add this to your user configuration)
  # users.users.<username>.extraGroups = [ "docker" ];
}