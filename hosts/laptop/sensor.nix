{ ... }:
{
  # Accelerometer mount-matrix quirk for the ThinkPad L13 2-in-1 Gen 6.
  #
  # This machine's HID accelerometer is mounted 180° rotated: with the laptop
  # sitting normally, iio-sensor-proxy reports orientation "bottom-up", so
  # iio-hyprland flips the built-in panel (eDP-1) to transform 2 (upside down).
  # Besides the wrong screen orientation, having a rotated output in the layout
  # triggers a wlroots/grim bug that corrupts multi-output screenshots with a
  # vertical seam at that monitor's edge (x = eDP-1's right edge, 1920).
  #
  # Correct the sensor with a mount matrix that rotates the axes 180° in-plane
  # (negate X and Y), so an upright laptop reads as "normal" (transform 0) and
  # auto-rotation for tablet/tent modes still works — just no longer inverted.
  #
  # The lookup key udev builds (see systemd 60-sensor.rules) is
  #   sensor:modalias:platform:$MODALIAS:$DMI_MODALIAS
  # i.e. sensor:modalias:platform:HID-SENSOR-200073:dmi:...svnLENOVO...pn21RDCTO1WW...
  #
  # Verify after rebuild: `monitor-sensor` should report "orientation: normal"
  # when the laptop is flat. If a different rotation is now wrong, adjust the
  # matrix (each column maps a device axis to a screen axis).
  services.udev.extraHwdb = ''
    sensor:modalias:platform:HID-SENSOR-200073:dmi:*svnLENOVO*:pn21RDCTO1WW*
     ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, -1, 0; 0, 0, 1
  '';
}
