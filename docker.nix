# Docker configuration for development
{ config, pkgs, ... }:

{
  virtualisation.docker = {
    # The rootful daemon stays off. Its socket is group-owned by `docker`, and
    # anything that can talk to that socket can ask for a --privileged
    # container bind-mounting /, which is a root shell with no sudo prompt and
    # no lock screen in the way. Leaving `enable = true` here alongside
    # rootless would keep both the privileged socket and the `docker` group
    # (the group only exists while this is true), so the escalation path would
    # still be open for anyone who added themselves back to it.
    enable = false;

    # Containers instead run inside a user namespace owned by the logged-in
    # user, so escaping one lands on an unprivileged uid rather than on root.
    # The trade-off is that published ports are bound as that user and so have
    # to clear net.ipv4.ip_unprivileged_port_start, left at its 1024 default —
    # lowering it would let every process on the machine squat on privileged
    # ports, which is a worse deal than renumbering a container.
    rootless = {
      enable = true;

      # Nothing here corresponds to the rootful enableOnBoot, because the
      # daemon is now a user service: containers come up with the login session
      # and go down with it. Keeping them alive across logout would take
      # users.users.leevisuo.linger, which is left off — nothing on this machine
      # needs a container to outlive the session that started it.
      # Exports DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock via
      # /etc/set-environment, which fish sources through its
      # nixos-env-preinit hook. Without it every tool below would silently
      # look for the /run/docker.sock that no longer exists.
      setSocketVariable = true;

      daemon.settings = {
        # Enable buildx for multi-platform builds
        experimental = true;
        # Unprivileged overlay2 needs kernel >= 5.11; without it the rootless
        # daemon falls back to vfs, which copies whole layers per container.
        storage-driver = "overlay2";
        # Cap log growth — json-file logs are otherwise unbounded and fill the
        # disk after a long-running container has been chatty for a while.
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
        # IPv6 configuration (properly configured with subnet)
        ipv6 = true;
        fixed-cidr-v6 = "2001:db8:1::/64";
      };
    };
  };

  # The rootful daemon module declared these, and dockerd-rootless still builds
  # a docker0 bridge and veth pairs for its default network. Autoload would
  # cover it either way — request_module runs in the initial namespace, so being
  # confined to a user namespace does not stop a module being pulled in — so
  # this is here to keep a dependency of the daemon visible rather than to work
  # around a limitation. The rootful module also declared br_netfilter and
  # xt_nat, deliberately not carried over: those filter traffic crossing a
  # host-level bridge, which the rootless daemon's own network namespace is not.
  boot.kernelModules = [ "bridge" "veth" ];

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
}
