# alacritty.nix
{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [ alacritty ];

  # Set up user configuration directory
  system.activationScripts = {
    alacritty-config = {
      text = ''
                CONFIG_DIR=/home/cameron/.config/alacritty
                mkdir -p $CONFIG_DIR
                cat > $CONFIG_DIR/alacritty.toml << 'EOL'
        [window]
        opacity = 0.8
        dynamic_title = true

        [window.padding]
        x = 5
        y = 5

        [font]
        size = 11.0

        [font.normal]
        family = "JetBrainsMono Nerd Font"
        style = "Regular"

        [font.bold]
        family = "JetBrainsMono Nerd Font"
        style = "Bold"

        [font.italic]
        family = "JetBrainsMono Nerd Font"
        style = "Italic"

        [colors.primary]
        background = "#1d1f21"
        foreground = "#c5c8c6"

        [colors.normal]
        black = "#1d1f21"
        red = "#cc6666"
        green = "#b5bd68"
        yellow = "#f0c674"
        blue = "#81a2be"
        magenta = "#b294bb"
        cyan = "#8abeb7"
        white = "#c5c8c6"

        [colors.bright]
        black = "#666666"
        red = "#d54e53"
        green = "#b9ca4a"
        yellow = "#e7c547"
        blue = "#7aa6da"
        magenta = "#c397d8"
        cyan = "#70c0b1"
        white = "#eaeaea"

        [cursor.style]
        shape = "Block"
        blinking = "On"

        [scrolling]
        history = 10000
        multiplier = 3
        EOL
                chown -R cameron:users /home/cameron/.config/alacritty
      '';
    };
  };
}
