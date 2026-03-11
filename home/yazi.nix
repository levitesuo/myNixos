{ pkgs, ... }:

{
  home.packages = with pkgs; [
    poppler_utils  # pdftoppm for PDF previews
    ffmpegthumbnailer
    unar
    jq
  ];

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = false;
        show_symlink = true;
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
      };

      preview = {
        tab_size = 2;
        max_width = 1920;
        max_height = 1080;
        cache_dir = "";
        image_filter = "triangle";
        image_quality = 75;
        sixel_scale = 1.0;
        ueberzug_scale = 1;
        ueberzug_offset = [ 0 0 0 0 ];
      };
    };
  };
}
