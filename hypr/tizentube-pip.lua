-- >>> tizentube-pip (managed by tizentube-pip install.sh, do not edit inside) >>>
-- TizenTube PiP: float, pin (all workspaces / on top), keep 16:9, bottom-right.
-- The YouTube TV app window's class is url-derived: chrome-www.youtube.com__tv-Default
o.window("^(chrome|brave)-www\\.youtube\\.com__tv.*$", {
  float = true,
  pin = true,
  size = { 960, 540 },
  keep_aspect_ratio = true,
  move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})
o.window({ class = "^mpv$", title = "^TizenTube PiP" }, {
  float = true,
  pin = true,
  size = { 960, 540 },
  keep_aspect_ratio = true,
  move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})
-- <<< tizentube-pip <<<
