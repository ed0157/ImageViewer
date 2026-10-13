# Layout of the installer window, read by dmgbuild (see scripts/package.sh).
import os

app = defines.get("app", "build/ImageViewer.app")  # noqa: F821  (`defines` is provided by dmgbuild)
app_name = os.path.basename(app)

format = "UDZO"
files = [app]
symlinks = {"Applications": "/Applications"}
icon = "Resources/AppIcon.icns"

window_rect = ((200, 140), (660, 462))  # 462 = 430 of picture + title bar
default_view = "icon-view"
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

icon_size = 128
text_size = 13
arrange_by = None
icon_locations = {
    app_name: (170, 190),
    "Applications": (490, 190),
}
