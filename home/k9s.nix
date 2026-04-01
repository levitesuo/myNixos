{ config, lib, ... }:

let
  colors = config.lib.stylix.colors;
in {
  xdg.configFile."k9s/skins/stylix.yaml".text = ''
k9s:
  body:
    fgColor: "#${colors.base05}"
    bgColor: "#${colors.base00}"
    logoColor: "#${colors.base0D}"
  prompt:
    fgColor: "#${colors.base05}"
    bgColor: "#${colors.base01}"
    suggestColor: "#${colors.base0D}"
  info:
    fgColor: "#${colors.base0D}"
    bgColor: "#${colors.base00}"
  dialog:
    fgColor: "#${colors.base05}"
    bgColor: "#${colors.base01}"
    buttonFgColor: "#${colors.base00}"
    buttonBgColor: "#${colors.base0D}"
    buttonFocusFgColor: "#${colors.base00}"
    buttonFocusBgColor: "#${colors.base0C}"
    labelFgColor: "#${colors.base09}"
    fieldFgColor: "#${colors.base05}"
  frame:
    border:
      fgColor: "#${colors.base03}"
      focusColor: "#${colors.base0D}"
    menu:
      fgColor: "#${colors.base05}"
      keyColor: "#${colors.base0D}"
      numKeyColor: "#${colors.base0E}"
    crumbs:
      fgColor: "#${colors.base00}"
      bgColor: "#${colors.base0D}"
      activeColor: "#${colors.base0C}"
    status:
      newColor: "#${colors.base0C}"
      modifyColor: "#${colors.base0D}"
      addColor: "#${colors.base0B}"
      pendingColor: "#${colors.base09}"
      errorColor: "#${colors.base08}"
      highlightColor: "#${colors.base0A}"
      killColor: "#${colors.base08}"
      completedColor: "#${colors.base03}"
    title:
      fgColor: "#${colors.base05}"
      bgColor: "#${colors.base00}"
      highlightColor: "#${colors.base0B}"
      counterColor: "#${colors.base0C}"
      filterColor: "#${colors.base0D}"
  views:
    charts:
      bgColor: "default"
      defaultDialColors:
        - "#${colors.base0D}"
        - "#${colors.base08}"
      defaultChartColors:
        - "#${colors.base0D}"
        - "#${colors.base08}"
    table:
      fgColor: "#${colors.base05}"
      bgColor: "#${colors.base00}"
      markColor: "#${colors.base0B}"
      header:
        fgColor: "#${colors.base0D}"
        bgColor: "#${colors.base00}"
        sorterColor: "#${colors.base0B}"
    xray:
      fgColor: "#${colors.base05}"
      bgColor: "#${colors.base00}"
      cursorColor: "#${colors.base0D}"
      graphicColor: "#${colors.base0E}"
      showIcons: false
    yaml:
      keyColor: "#${colors.base0D}"
      colonColor: "#${colors.base03}"
      valueColor: "#${colors.base05}"
    logs:
      fgColor: "#${colors.base05}"
      bgColor: "#${colors.base00}"
      indicator:
        fgColor: "#${colors.base0D}"
        bgColor: "#${colors.base01}"
'';

  xdg.configFile."k9s/config.yaml".text = ''
k9s:
  ui:
    skin: stylix
'';
}
