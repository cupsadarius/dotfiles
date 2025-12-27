function set_fzf_theme
    set -l theme $argv[1]
    set -l variant $argv[2]

    # Default to dark if no variant specified
    if test -z "$variant"
        set variant dark
    end

    # Normalize theme name
    switch $theme
        case catppuccin cat mocha latte
            set theme catppuccin
        case rose-pine rose rosepine rose_pine moon dawn
            set theme rose-pine
        case gruvbox gruvbox-dark gruvbox_dark gruvbox-light gruvbox_light
            set theme gruvbox
        case cyberdream cyber
            set theme cyberdream
    end

    # Normalize variant
    switch $variant
        case light l
            set variant light
        case '*'
            set variant dark
    end

    # Set FZF colors based on theme and variant
    switch "$theme-$variant"
        case catppuccin-dark
            # Catppuccin Mocha
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"

        case catppuccin-light
            # Catppuccin Latte
            set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39 \
--color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
--color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
--color=selected-bg:#BCC0CC \
--color=border:#9CA0B0,label:#4C4F69"

        case rose-pine-dark
            # Rose Pine Moon
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#908caa,hl:#ea9a97 \
--color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97 \
--color=border:#44415a,header:#3e8fb0,gutter:#232136 \
--color=spinner:#f6c177,info:#9ccfd8 \
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

        case rose-pine-light
            # Rose Pine Dawn
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#797593,bg:#faf4ed,hl:#d7827e \
--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e \
--color=border:#dfdad9,header:#286983,gutter:#faf4ed \
--color=spinner:#ea9d34,info:#56949f \
--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

        case gruvbox-dark
            # Gruvbox Dark
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c \
--color=marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598 \
--color=selected-bg:#3c3836 \
--color=border:#1d2021,label:#fabd2f"

        case gruvbox-light
            # Gruvbox Light
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#665c54,bg:#fbf1c7,hl:#9d0006 \
--color=fg+:#3c3836,bg+:#ebdbb2,hl+:#9d0006 \
--color=border:#d5c4a1,header:#076678,gutter:#fbf1c7 \
--color=spinner:#b57614,info:#427b58 \
--color=pointer:#8f3f71,marker:#9d0006,prompt:#665c54"

        case cyberdream-dark
            # Cyberdream
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#ffffff,header:#5ea1ff,info:#ffbd5e,pointer:#ff5ea0 \
--color=marker:#5eff6c,fg+:#ffffff,prompt:#bd5eff,hl+:#5ef1ff \
--color=selected-bg:#3c4048 \
--color=border:#3c4048,label:#ffffff"

        case cyberdream-light
            # Cyberdream Light
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#16181a,bg:#ffffff,hl:#d11500 \
--color=fg+:#16181a,bg+:#eaeaea,hl+:#d11500 \
--color=border:#acacac,header:#0057d1,gutter:#ffffff \
--color=spinner:#997b00,info:#008c99 \
--color=pointer:#a018ff,marker:#d11500,prompt:#7b8496"

        case '*'
            # Default to catppuccin dark if unknown
            set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"
    end
end
