#! /usr/bin/env bash
set -ueo pipefail
set -o physical
#set -x

REPO_DIR=$(cd $(dirname $0) && pwd)
SRC_DIR=${REPO_DIR}/src

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

THEME_NAME=WhiteSur
COLOR_VARIANTS=('-light' '-dark')
OPACITY_VARIANTS=('' '-solid')
ALT_VARIANTS=('' '-alt')
ICON_VARIANTS=('' '-normal' '-gnome' '-ubuntu' '-arch' '-manjaro' '-fedora' '-debian' '-void')

# COLORS
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # warning color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# Echo like ... with flag type and display message colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

# Check command availability
function has_command() {
  command -v $1 > /dev/null
}

operation_canceled() {
  clear
  prompt  -i "\n Operation canceled by user, Bye!"
  exit 1
}

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-g, --gdm" "Install GDM theme, this option needs root user authority! Please run this with sudo"
  printf "  %-25s%s\n" "-r, --remove" "Remove theme, remove all installed themes"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-a, --alt VARIANTS" "Specify theme titlebutton variant(s) [standard|alt] (Default: All variants)"
  printf "  %-25s%s\n" "-t, --theme VARIANTS" "Change the theme color [blue|purple|pink|red|orange|yellow|green|grey] (Default: MacOS blue)"
  printf "  %-25s%s\n" "-p, --panel VARIANTS" "Change the panel transparency [80%|75%|70%|65%|60%|55%|50%|45%|40%|35%] (Default: 85%)"
  printf "  %-25s%s\n" "-s, --size VARIANTS" "Change the nautilus sidebar width size [220px|240px|260px|280px] (Default: 200px)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Change gnome-shell activities icon [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian|void] (Default: standard)"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local opacity=${4}
  local alt=${5}
  local icon=${6}

  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}
  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}

  local THEME_DIR=${1}/${2}${3}${4}${5}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  prompt -i "Installing '${THEME_DIR}'..."

  mkdir -p                                                                              ${THEME_DIR}
  cp -r ${REPO_DIR}/COPYING                                                             ${THEME_DIR}

  echo "[Desktop Entry]" >>                                                             ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme" >>                                                      ${THEME_DIR}/index.theme
  echo "Name=${name}${color}${opacity}" >>                                              ${THEME_DIR}/index.theme
  echo "Comment=A Stylish Gtk+ theme based on Elegant Design" >>                        ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8" >>                                                              ${THEME_DIR}/index.theme
  echo "" >>                                                                            ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]" >>                                                         ${THEME_DIR}/index.theme
  echo "GtkTheme=${name}${color}${opacity}" >>                                          ${THEME_DIR}/index.theme
  echo "MetacityTheme=${name}${color}${opacity}" >>                                     ${THEME_DIR}/index.theme
  echo "IconTheme=McMojave-circle" >>                                                   ${THEME_DIR}/index.theme
  echo "CursorTheme=McMojave-circle" >>                                                 ${THEME_DIR}/index.theme
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                   ${THEME_DIR}/index.theme

  mkdir -p                                                                              ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/assets/gnome-shell/icons                                             ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/main/gnome-shell/pad-osd.css                                         ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/main/gnome-shell/gdm3${color}.css                                    ${THEME_DIR}/gnome-shell/gdm3.css
  cp -r ${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}${alt}.css             ${THEME_DIR}/gnome-shell/gnome-shell.css
  cp -r ${SRC_DIR}/assets/gnome-shell/common-assets                                     ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/assets/gnome-shell/assets${color}/*.svg                              ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/assets/gnome-shell/activities/activities${icon}.svg                  ${THEME_DIR}/gnome-shell/assets/activities.svg

  cd "${THEME_DIR}/gnome-shell"
  mv -f assets/no-events.svg no-events.svg
  mv -f assets/process-working.svg process-working.svg
  mv -f assets/no-notifications.svg no-notifications.svg

  if [[ ${alt} == '-alt' || ${opacity} == '-solid' ]] &&  [[ ${color} == '-light' ]]; then
    cp -r ${SRC_DIR}/assets/gnome-shell/activities-black/activities${icon}.svg          ${THEME_DIR}/gnome-shell/assets/activities.svg
  fi

  mkdir -p                                                                              ${THEME_DIR}/gtk-2.0
  cp -r ${SRC_DIR}/main/gtk-2.0/gtkrc${color}                                           ${THEME_DIR}/gtk-2.0/gtkrc
  cp -r ${SRC_DIR}/main/gtk-2.0/menubar-toolbar${color}.rc                              ${THEME_DIR}/gtk-2.0/menubar-toolbar.rc
  cp -r ${SRC_DIR}/main/gtk-2.0/common/*.rc                                             ${THEME_DIR}/gtk-2.0
  cp -r ${SRC_DIR}/assets/gtk-2.0/assets${color}                                        ${THEME_DIR}/gtk-2.0/assets

  mkdir -p                                                                              ${THEME_DIR}/gtk-3.0
  cp -r ${SRC_DIR}/assets/gtk-3.0/common-assets/assets                                  ${THEME_DIR}/gtk-3.0
  cp -r ${SRC_DIR}/assets/gtk-3.0/common-assets/sidebar-assets/*.png                    ${THEME_DIR}/gtk-3.0/assets
  cp -r ${SRC_DIR}/assets/gtk-3.0/windows-assets/titlebutton${alt}                      ${THEME_DIR}/gtk-3.0/windows-assets
  cp -r ${SRC_DIR}/assets/gtk-3.0/thumbnail${color}.png                                 ${THEME_DIR}/gtk-3.0/thumbnail.png
  cp -r ${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}.css                                  ${THEME_DIR}/gtk-3.0/gtk-dark.css

  if [[ ${color} == '-light' ]]; then
    cp -r ${SRC_DIR}/main/gtk-3.0/gtk-light${opacity}.css                               ${THEME_DIR}/gtk-3.0/gtk.css
  else
    cp -r ${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}.css                                ${THEME_DIR}/gtk-3.0/gtk.css
  fi

  glib-compile-resources --sourcedir=${THEME_DIR}/gtk-3.0 --target=${THEME_DIR}/gtk-3.0/gtk.gresource ${SRC_DIR}/main/gtk-3.0/gtk.gresource.xml
  rm -rf ${THEME_DIR}/gtk-3.0/{assets,windows-assets,gtk.css,gtk-dark.css}
  echo '@import url("resource:///org/gnome/theme/gtk.css");' >>                         ${THEME_DIR}/gtk-3.0/gtk.css
  echo '@import url("resource:///org/gnome/theme/gtk-dark.css");' >>                    ${THEME_DIR}/gtk-3.0/gtk-dark.css

  mkdir -p                                                                              ${THEME_DIR}/metacity-1
  cp -r ${SRC_DIR}/main/metacity-1/metacity-theme${color}.xml                           ${THEME_DIR}/metacity-1/metacity-theme-1.xml
  cp -r ${SRC_DIR}/main/metacity-1/metacity-theme-3.xml                                 ${THEME_DIR}/metacity-1
  cp -r ${SRC_DIR}/assets/metacity-1/assets/*.png                                       ${THEME_DIR}/metacity-1
  cp -r ${SRC_DIR}/assets/metacity-1/thumbnail${color}.png                              ${THEME_DIR}/metacity-1/thumbnail.png
  cd ${THEME_DIR}/metacity-1 && ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                              ${THEME_DIR}/xfwm4
  cp -r ${SRC_DIR}/assets/xfwm4/assets${color}/*.png                                    ${THEME_DIR}/xfwm4
  cp -r ${SRC_DIR}/main/xfwm4/themerc${color}                                           ${THEME_DIR}/xfwm4/themerc

  mkdir -p                                                                              ${THEME_DIR}/cinnamon
  cp -r ${SRC_DIR}/main/cinnamon/cinnamon${color}${opacity}.css                         ${THEME_DIR}/cinnamon/cinnamon.css
  cp -r ${SRC_DIR}/assets/cinnamon/common-assets                                        ${THEME_DIR}/cinnamon/assets
  cp -r ${SRC_DIR}/assets/cinnamon/assets${color}/*.svg                                 ${THEME_DIR}/cinnamon/assets
  cp -r ${SRC_DIR}/assets/cinnamon/thumbnail${color}.png                                ${THEME_DIR}/cinnamon/thumbnail.png

  mkdir -p                                                                              ${THEME_DIR}/plank
  cp -r ${SRC_DIR}/other/plank/theme${color}/*.theme                                    ${THEME_DIR}/plank
}


install_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
      for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
        for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
          install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${icon}"
        done
      done
    done
  done
}

remove_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
      for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
        [[ -d "${DEST_DIR}/${THEME_NAME}${color}${opacity}${alt}" ]] && rm -rf "${DEST_DIR}/${THEME_NAME}${color}${opacity}${alt}"
      done
    done
  done
}

# Backup and install files related to GDM theme
GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
ETC_THEME_FOLDER="/etc/alternatives"
ETC_THEME_FILE="/etc/alternatives/gdm3.css"
ETC_NEW_THEME_FILE="/etc/alternatives/gdm3-theme.gresource"
UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
UBUNTU_NEW_THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"
UBUNTU_YARU_THEME_FILE="/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource"
UBUNTU_JSON_FILE="/usr/share/gnome-shell/modes/ubuntu.json"
YURA_JSON_FILE="/usr/share/gnome-shell/modes/yaru.json"
UBUNTU_MODES_FOLDER="/usr/share/gnome-shell/modes"

install_gdm() {
  local GDM_THEME_DIR="${1}/${2}${3}"

  echo
  prompt -i "Installing ${2}${3} gdm theme..."

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    prompt -i "Installing '$GS_THEME_FILE'..."
    cp -an "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/main/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing '$UBUNTU_THEME_FILE'..."
    cp -an "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing '$UBUNTU_NEW_THEME_FILE'..."
    cp -an "$UBUNTU_NEW_THEME_FILE" "$UBUNTU_NEW_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR"/gnome-shell/* "$SHELL_THEME_FOLDER"
  fi

  # > Ubuntu 18.04
  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Ubuntu GDM theme..."
    cp -an "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    [[ -d "$SHELL_THEME_FOLDER/$THEME_NAME" ]] && rm -rf "$SHELL_THEME_FOLDER/$THEME_NAME"
    cp -r "$GDM_THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/$THEME_NAME"
    cd "$ETC_THEME_FOLDER"
    [[ -f "$ETC_THEME_FILE.bak" ]] && ln -sf "$SHELL_THEME_FOLDER/$THEME_NAME/gnome-shell.css" gdm3.css
  fi

  # > Ubuntu 20.04
  if [[ -f "$UBUNTU_YARU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Ubuntu GDM theme..."
    cp -an "$UBUNTU_YARU_THEME_FILE" "$UBUNTU_YARU_THEME_FILE.bak"
    cp -af "$GS_THEME_FILE" "$UBUNTU_YARU_THEME_FILE"
    [[ -d "$UBUNTU_MODES_FOLDER" ]] && cp -an "$UBUNTU_MODES_FOLDER" "$UBUNTU_MODES_FOLDER"-bak
    [[ -f "$UBUNTU_JSON_FILE" ]] && sed -i "s|Yaru/gnome-shell.css|gnome-shell.css|" "$UBUNTU_JSON_FILE"
    [[ -f "$YURA_JSON_FILE" ]] && sed -i "s|Yaru/gnome-shell.css|gnome-shell.css|" "$YURA_JSON_FILE"
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$GS_THEME_FILE'..."
    rm -rf "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$UBUNTU_THEME_FILE'..."
    rm -rf "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$UBUNTU_NEW_THEME_FILE'..."
    rm -rf "$UBUNTU_NEW_THEME_FILE" "$SHELL_THEME_FOLDER"/{assets,no-events.svg,process-working.svg,no-notifications.svg}
    mv "$UBUNTU_NEW_THEME_FILE.bak" "$UBUNTU_NEW_THEME_FILE"
  fi

  # > Ubuntu 18.04
  if [[ -f "$ETC_THEME_FILE.bak" ]]; then

    prompt -w "reverting Ubuntu GDM theme..."

    rm -rf "$ETC_THEME_FILE"
    mv "$ETC_THEME_FILE.bak" "$ETC_THEME_FILE"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm -rf $SHELL_THEME_FOLDER/$THEME_NAME
  fi

  # > Ubuntu 20.04
  if [[ -f "$UBUNTU_YARU_THEME_FILE.bak" ]]; then
    prompt -w "reverting Ubuntu GDM theme..."
    rm -rf "$UBUNTU_YARU_THEME_FILE"
    mv "$UBUNTU_YARU_THEME_FILE.bak" "$UBUNTU_YARU_THEME_FILE"
    [[ -d "$UBUNTU_MODES_FOLDER"-bak ]] && rm -rf "$UBUNTU_MODES_FOLDER" && mv "$UBUNTU_MODES_FOLDER"-bak "$UBUNTU_MODES_FOLDER"
  fi
}

install_dialog() {
  if [ ! "$(which dialog 2> /dev/null)" ]; then
    prompt -w "\n 'dialog' needs to be installed for this shell"
    if has_command zypper; then
      sudo zypper in dialog
    elif has_command apt-get; then
      sudo apt-get install dialog
    elif has_command dnf; then
      sudo dnf install -y dialog
    elif has_command yum; then
      sudo yum install dialog
    elif has_command pacman; then
      sudo pacman -S --noconfirm dialog
    fi
  fi
}

sidebar_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    tui=$(dialog --backtitle "${THEME_NAME} gtk theme installer" \
    --radiolist "Choose your nautilus sidebar size (default is 200px width):" 15 40 5 \
      1 "220px" on  \
      2 "240px" off \
      3 "260px" off \
      4 "280px" off --output-fd 1 )
      case "$tui" in
        1) sidebar_size="220px" ;;
        2) sidebar_size="240px" ;;
        3) sidebar_size="260px" ;;
        4) sidebar_size="280px" ;;
        *) operation_canceled ;;
     esac
  fi
}

run_sidebar_dialog() {
  install_dialog && sidebar_dialog && change_size && parse_sass
}

shell_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    tui=$(dialog --backtitle "${THEME_NAME} gtk theme installer" \
    --radiolist "Choose your panel transparency
                 (default is 85%, 100% is fully transparent!):" 20 50 10 \
      1 "80%" on  \
      2 "75%" off \
      3 "70%" off \
      4 "65%" off \
      5 "60%" off \
      6 "55%" off \
      7 "50%" off \
      8 "45%" off \
      9 "40%" off \
      0 "35%" off --output-fd 1 )
      case "$tui" in
        1) panel_trans="0.20" ;;
        2) panel_trans="0.25" ;;
        3) panel_trans="0.30" ;;
        4) panel_trans="0.35" ;;
        5) panel_trans="0.40" ;;
        6) panel_trans="0.45" ;;
        7) panel_trans="0.50" ;;
        8) panel_trans="0.55" ;;
        9) panel_trans="0.60" ;;
        0) panel_trans="0.65" ;;
        *) operation_canceled ;;
     esac
  fi
}

run_shell_dialog() {
  install_dialog && shell_dialog && change_transparency && parse_sass
}

theme_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    tui=$(dialog --backtitle "${THEME_NAME} gtk theme installer" \
    --radiolist "Choose your theme color (default is Mac Blue):" 20 50 10 \
      1 "Blue"   on  \
      2 "Purple" off \
      3 "Pink"   off \
      4 "Red"    off \
      5 "Orange" off \
      6 "Yellow" off \
      7 "Green"  off \
      8 "Grey"   off --output-fd 1 )
      case "$tui" in
        1) theme_color="#2E7CF7" ;;
        2) theme_color="#9A57A3" ;;
        3) theme_color="#E55E9C" ;;
        4) theme_color="#ED5F5D" ;;
        5) theme_color="#E9873A" ;;
        6) theme_color="#F3BA4B" ;;
        7) theme_color="#79B757" ;;
        8) theme_color="#8C8C8C" ;;
        *) operation_canceled ;;
     esac
  fi
}

run_theme_dialog() {
  install_dialog && theme_dialog && change_theme_color && parse_sass
}

parse_sass() {
  cd ${REPO_DIR} && ./parse-sass.sh
}

change_size() {
  cd ${SRC_DIR}/sass/gtk
  cp -an _applications.scss _applications.scss.bak
  sed -i "/\$nautilus_sidebar_size/s/200px/${sidebar_size}/" _applications.scss
  prompt -w "Change nautilus sidebar size ..."
}

change_transparency() {
  cd ${SRC_DIR}/sass
  cp -an _colors.scss _colors.scss.bak
  sed -i "/\$panel_opacity/s/0.16/${panel_trans}/" _colors.scss
  prompt -w "Change panel transparency ..."
}

change_theme_color() {
  notify-send "Notice" "It will take a few minutes to regenerate the assets files, please be patient!" -i face-wink

  cd ${SRC_DIR}/sass
  cp -an _colors.scss _colors.scss.bak
  sed -i "/\$selected_bg_color/s/#0860f2/${theme_color}/" _colors.scss

  cd ${SRC_DIR}/assets/gtk-3.0
  cp -an thumbnail.svg thumbnail.svg.bak
  mv thumbnail-dark.png thumbnail-dark.png.bak
  mv thumbnail-light.png thumbnail-light.png.bak
  sed -i "s/#0860f2/$theme_color/g" thumbnail.svg
  ./render-thumbnails.sh

  cd ${SRC_DIR}/assets/gtk-3.0/common-assets
  cp -an assets.svg assets.svg.bak
  mv assets assets-bak
  sed -i "s/#0860f2/$theme_color/g" assets.svg
  ./render-assets.sh

  cd ${SRC_DIR}/assets/gnome-shell/common-assets
  cp -an checkbox.svg checkbox.svg.bak
  cp -an more-results.svg more-results.svg.bak
  cp -an toggle-on.svg toggle-on.svg.bak
  sed -i "s/#0860f2/$theme_color/g" {checkbox.svg,more-results.svg,toggle-on.svg}

  cd ${SRC_DIR}/main/gtk-2.0
  cp -an gtkrc-dark gtkrc-dark.bak
  cp -an gtkrc-light gtkrc-light.bak
  sed -i "s/#0860f2/$theme_color/g" {gtkrc-dark,gtkrc-light}

  cd ${SRC_DIR}/assets/gtk-2.0
  cp -an assets-dark.svg assets-dark.svg.bak
  cp -an assets-light.svg assets-light.svg.bak
  mv assets-dark assets-dark-bak
  mv assets-light assets-light-bak
  sed -i "s/#0860f2/$theme_color/g" {assets-dark.svg,assets-light.svg}
  ./render-assets.sh

  cd ${SRC_DIR}/assets/cinnamon
  cp -an thumbnail.svg thumbnail.svg.bak
  mv thumbnail-dark.png thumbnail-dark.png.bak
  mv thumbnail-light.png thumbnail-light.png.bak
  sed -i "s/#0860f2/$theme_color/g" thumbnail.svg
  ./render-thumbnails.sh

  cd ${SRC_DIR}/assets/cinnamon/common-assets
  cp -an checkbox.svg checkbox.svg.bak
  cp -an radiobutton.svg radiobutton.svg.bak
  cp -an add-workspace-active.svg add-workspace-active.svg.bak
  cp -an menu-hover.svg menu-hover.svg.bak
  cp -an toggle-on.svg toggle-on.svg.bak
  cp -an corner-ripple.svg corner-ripple.svg.bak
  sed -i "s/#0860f2/$theme_color/g" {checkbox.svg,radiobutton.svg,menu-hover.svg,add-workspace-active.svg,corner-ripple.svg,toggle-on.svg}

  prompt -w "Change theme color ..."
}

restore_assets_files() {
  cd ${SRC_DIR}/assets/gtk-3.0
  mv -f thumbnail.svg.bak thumbnail.svg
  mv -f thumbnail-dark.png.bak thumbnail-dark.png
  mv -f thumbnail-light.png.bak thumbnail-light.png

  cd ${SRC_DIR}/assets/gtk-3.0/common-assets
  mv -f assets.svg.bak assets.svg
  [[ -d assets-bak ]] && rm -rf assets && mv assets-bak assets

  cd ${SRC_DIR}/assets/gnome-shell/common-assets
  mv -f checkbox.svg.bak checkbox.svg
  mv -f more-results.svg.bak more-results.svg
  mv -f toggle-on.svg.bak toggle-on.svg

  cd ${SRC_DIR}/main/gtk-2.0
  mv -f gtkrc-dark.bak gtkrc-dark
  mv -f gtkrc-light.bak gtkrc-light

  cd ${SRC_DIR}/assets/gtk-2.0
  mv -f assets-dark.svg.bak assets-dark.svg
  mv -f assets-light.svg.bak assets-light.svg
  [[ -d assets-dark-bak ]] && rm -rf assets-dark && mv assets-dark-bak assets-dark
  [[ -d assets-light-bak ]] && rm -rf assets-light && mv assets-light-bak assets-light

  cd ${SRC_DIR}/assets/cinnamon
  mv -f thumbnail.svg.bak thumbnail.svg
  mv -f thumbnail-dark.png.bak thumbnail-dark.png
  mv -f thumbnail-light.png.bak thumbnail-light.png

  cd ${SRC_DIR}/assets/cinnamon/common-assets
  mv -f checkbox.svg.bak checkbox.svg
  mv -f radiobutton.svg.bak radiobutton.svg
  mv -f add-workspace-active.svg.bak add-workspace-active.svg
  mv -f menu-hover.svg.bak menu-hover.svg
  mv -f toggle-on.svg.bak toggle-on.svg
  mv -f corner-ripple.svg.bak corner-ripple.svg

  prompt -w "Restore assets files ..."
}

restore_applications_file() {
  cd ${SRC_DIR}/sass/gtk
  [[ -f _applications.scss.bak ]] && rm -rf _applications.scss
  mv _applications.scss.bak _applications.scss
  prompt -w "Restore _applications.scss file ..."
}

restore_colors_file() {
  cd ${SRC_DIR}/sass
  [[ -f _colors.scss.bak ]] && rm -rf _colors.scss
  mv _colors.scss.bak _colors.scss
  prompt -w "Restore _colors.scss file ..."
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        prompt -e "Destination directory does not exist. Let's make a new one..."
        mkdir -p ${dest}
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -r|--remove)
      remove='true'
      shift 1
      ;;
    -a|--alt)
      shift
      for alt in "${@}"; do
        case "${alt}" in
          standard)
            alts+=("${ALT_VARIANTS[0]}")
            shift
            ;;
          alt)
            alts+=("${ALT_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized opacity variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -o|--opacity)
      shift
      for opacity in "${@}"; do
        case "${opacity}" in
          standard)
            opacities+=("${OPACITY_VARIANTS[0]}")
            shift
            ;;
          solid)
            opacities+=("${OPACITY_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized opacity variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized color variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          standard)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          normal)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          gnome)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          ubuntu)
            icons+=("${ICON_VARIANTS[3]}")
            shift
            ;;
          arch)
            icons+=("${ICON_VARIANTS[4]}")
            shift
            ;;
          manjaro)
            icons+=("${ICON_VARIANTS[5]}")
            shift
            ;;
          fedora)
            icons+=("${ICON_VARIANTS[6]}")
            shift
            ;;
          debian)
            icons+=("${ICON_VARIANTS[7]}")
            shift
            ;;
          void)
            icons+=("${ICON_VARIANTS[8]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized icon variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -t|--theme)
      theme='true'
      tdialog='true'
      shift
      for theme_color in "${@}"; do
        case "${theme_color}" in
          blue)
            tdialog='false'
            theme_color='#2E7CF7'
            shift
            ;;
          purple)
            tdialog='false'
            theme_color='#9A57A3'
            shift
            ;;
          pink)
            tdialog='false'
            theme_color='#E55E9C'
            shift
            ;;
          red)
            tdialog='false'
            theme_color='#ED5F5D'
            shift
            ;;
          orange)
            tdialog='false'
            theme_color='#E9873A'
            shift
            ;;
          yellow)
            tdialog='false'
            theme_color='#F3BA4B'
            shift
            ;;
          green)
            theme_color='#79B757'
            shift
            ;;
          grey)
            tdialog='false'
            theme_color='#8C8C8C'
            shift
            ;;
          dialog)
            run_theme_dialog
            ;;
          -*|--*)
            break
            ;;
          *)
            run_theme_dialog
            ;;
        esac
      done
      ;;
    -s|--size)
      size='true'
      sdialog='true'
      shift
      for sidebar_size in "${@}"; do
        case "${sidebar_size}" in
          220px)
            sdialog='false'
            sidebar_size='220px'
            shift
            ;;
          240px)
            sdialog='false'
            sidebar_size='240px'
            shift
            ;;
          260px)
            sdialog='false'
            sidebar_size='260px'
            shift
            ;;
          280px)
            sdialog='false'
            sidebar_size='280px'
            shift
            ;;
          dialog)
            run_sidebar_dialog
            ;;
          -*|--*)
            break
            ;;
          *)
            run_sidebar_dialog
            ;;
        esac
      done
      ;;
    -p|--panel)
      panel='true'
      pdialog='true'
      shift
      for panel_trans in "${@}"; do
        case "${panel_trans}" in
          80%)
            pdialog='false'
            panel_trans='0.20'
            shift
            ;;
          75%)
            pdialog='false'
            panel_trans='0.25'
            shift
            ;;
          70%)
            pdialog='false'
            panel_trans='0.30'
            shift
            ;;
          65%)
            pdialog='false'
            panel_trans='0.35'
            shift
            ;;
          60%)
            pdialog='false'
            panel_trans='0.40'
            shift
            ;;
          55%)
            pdialog='false'
            panel_trans='0.45'
            shift
            ;;
          50%)
            pdialog='false'
            panel_trans='0.50'
            shift
            ;;
          45%)
            pdialog='false'
            panel_trans='0.55'
            shift
            ;;
          40%)
            pdialog='false'
            panel_trans='0.60'
            shift
            ;;
          35%)
            pdialog='false'
            panel_trans='0.65'
            shift
            ;;
          dialog)
            run_shell_dialog
            ;;
          -*|--*)
            break
            ;;
          *)
            run_shell_dialog
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [ ! "$(which glib-compile-resources 2> /dev/null)" ]; then
  prompt -w "\n 'glib2.0' needs to be installed for this shell"
  if has_command apt; then
    sudo apt install libglib2.0-dev-bin
  elif has_command dnf; then
    sudo dnf install -y glib2-devel
  fi
fi

if [[ "${panel:-}" == 'true' ]]; then
  if [[ "${pdialog}" == 'false' ]]; then
    change_transparency && parse_sass
  else
    run_shell_dialog
  fi
  notify-send "Finished" "Enjoy your new WhiteSur theme!" -i face-smile
fi

if [[ "${size:-}" == 'true' ]]; then
  if [[ "${sdialog}" == 'false' ]]; then
    change_size && parse_sass
  else
    run_sidebar_dialog
  fi
  notify-send "Finished" "Enjoy your new WhiteSur theme!" -i face-smile
fi

if [[ "${theme:-}" == 'true' ]]; then
  if [[ "${tdialog}" == 'false' ]]; then
    change_theme_color && parse_sass
  else
    run_theme_dialog
  fi
  notify-send "Finished" "Enjoy your new WhiteSur theme!" -i face-smile
fi

if [[ "${gdm:-}" != 'true' && "${remove:-}" != 'true' ]]; then
  install_theme
fi

if [[ "${gdm:-}" == 'true' && "${remove:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  install_theme && install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}"
fi

if [[ "${gdm:-}" != 'true' && "${remove:-}" == 'true' ]]; then
  remove_theme
fi

if [[ "${gdm:-}" == 'true' && "${remove:-}" == 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  revert_gdm
fi

if [[ -f "${SRC_DIR}"/sass/gtk/_applications.scss.bak ]]; then
  restore_applications_file && parse_sass
fi

if [[ -f "${SRC_DIR}"/sass/_colors.scss.bak ]]; then
  restore_colors_file && parse_sass
fi

if [[ -f "${SRC_DIR}"/assets/gtk-3.0/thumbnail.svg.bak ]]; then
  restore_assets_files
fi

echo
prompt -s Done.
