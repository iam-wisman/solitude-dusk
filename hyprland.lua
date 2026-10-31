-- Solitude Dusk: setting-sun gold -> dusk coral glow, quiet charcoal borders
local active_border_color = { colors = { "rgba(db9617ff)", "rgba(d9825fff)" }, angle = 45 }

-- Cursor: Bibata Modern Amber (bibata-cursor-theme-bin) at size 16
hl.env("XCURSOR_THEME", "Bibata-Modern-Amber")
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Amber")
hl.env("HYPRCURSOR_SIZE", "16")

hl.config({
  general = {
    border_size = 1,
    col = {
      active_border = active_border_color,
      inactive_border = "rgba(2d2d2daa)",
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = "rgba(2d2d2d80)",
    },
  },

  decoration = {
    rounding = 6,
    rounding_power = 3,

    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = "rgba(0d0d0dee)",
    },

    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      noise = 0.02,
      contrast = 1.0,
      brightness = 0.9,
      vibrancy = 0.2,
      vibrancy_darkness = 0.5,
    },
  },

  cursor = {
    sync_gsettings_theme = true,
  },
})

-- Workspace switching: smooth slide + fade
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidefadeforwards" })

-- Window open/close animations
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "popin 85%" })

-- Fade animations for smooth transitions
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quick" })

-- Layer animations (panels, bars)
hl.animation({ leaf = "layers", enabled = true, speed = 3.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "linear", style = "fade" })

-- Border animation
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "easeOutQuint" })
