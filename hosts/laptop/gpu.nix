{ ... }:
{
  # AMD Phoenix3 integrated GPU (Ryzen APU).
  #
  # The iGPU has no real VRAM of its own — it carves a small fixed buffer
  # (only ~1 GB by default) out of system RAM. Heavy GPU clients (Chrome,
  # Slack/Electron, DBeaver) fill that buffer fast and then thrash, evicting
  # buffers in and out of GTT, which stalls the whole Hyprland compositor.
  #
  # The real cure is raising the UMA Frame Buffer Size in the BIOS to 2–4 GB.
  # This module just makes sure the amdgpu driver itself is set up correctly.

  # Load amdgpu early (in initrd) so kernel mode-setting is active from the
  # start — smoother handoff to the compositor than late module loading.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Mesa firmware/microcode for the GPU.
  hardware.enableRedistributableFirmware = true;

  # 32-bit GL/Vulkan, harmless and expected by some prebuilt apps.
  hardware.graphics.enable32Bit = true;
}
