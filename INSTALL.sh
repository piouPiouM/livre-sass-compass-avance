#!/usr/bin/env sh

NORMAL="\033[m"
UNDERLINE="\033[4m"
COLOR_COLOR_ERROR="\033[37;41m"
COLOR_COLOR_SUCCESS="\033[0;32m"
COLOR_MSG="\033[0;37m"

PWD=`pwd`
MARKER_PREFIX="  → "
MARKER_SUBTAB="    "

marker_error ()
{
  local CHAR_KO='✖'
  printf "\033[0;31m${CHAR_KO}\033[m"
}

set_error ()
{
  printf "%s%s\n" `move_cursor "$[ ${#1} - 2]"` `marker_error`
}


marker_success ()
{
  local CHAR_OK='✓'
  printf "\033[0;32m${CHAR_OK}\033[m"
}

set_success ()
{
  printf "%s%s\n" `move_cursor "$[ ${#1} - 2]"` `marker_success`
}

move_cursor ()
{
  printf "\033[%dD" "$1"
}

check_cmd ()
{
  local indicator="${MARKER_PREFIX}$1"
  local cmd_loc=
  local msg_title="La commande '$2' est introuvable."
  local msg_txt="Reportez-vous au chapitre ${3-1} pour suivre la procédure d'installation."

  printf "$indicator"

  if ! cmd_loc="$(type -p "$2")" || [ -z "$cmd_loc" ]; then
    set_error "$indicator"
    echo "${MARKER_SUBTAB}${COLOR_MSG}$msg_title\n${MARKER_SUBTAB}$msg_txt${NORMAL}"
    print_resume
    exit 1
  else
    set_success "$indicator"
  fi
}

check_gem ()
{
  local indicator="${MARKER_PREFIX}$1"
  local cmd_loc=
  local msg_title="La gem '$2' est absente de votre poste."
  local msg_txt="Reportez-vous au chapitre ${3-1} pour suivre la procédure d'installation."
  
  printf "$indicator"
  grep -q "^$2\b" <<< "$GEMLIST"
  if [ "$?" -ne "0" ]; then
    set_error "$indicator"
    echo "${MARKER_SUBTAB}${COLOR_MSG}$msg_title\n${MARKER_SUBTAB}$msg_txt${NORMAL}"
    print_resume
    exit 1
  else
    set_success "$indicator"
  fi
}

install_source ()
{
  local chapter="$1"
  local indicator="${MARKER_PREFIX}Installation du dossier ${chapter#ch}"
  local error=

  printf "$indicator"
  error=$(bundle install --gemfile="${GEMFILE}" --path "$PWD/.vendors" 2>&1)
  if [ "$?" -ne "0" ]; then
    set_error "$indicator"
    echo "${MARKER_SUBTAB}${COLOR_MSG}Une erreur s'est produite :\n${MARKER_SUBTAB}$error${NORMAL}"
    print_resume
    exit 1
  else
    set_success "$indicator"
  fi
}

print_title ()
{
  echo "\n${UNDERLINE}$1${NORMAL}\n"
}

print_resume ()
{
  echo
}

print_title "Vérification des pré-requis"
check_cmd "Ruby" "ruby"
check_cmd "RubyGems" "gem"

# RubyGems est installé, nous pouvons charger la liste des Gems et tester la
# présence des gems requises.
GEMLIST=`gem list`
check_cmd "Bundler" "bundle" 7
check_gem "Rubygems Bundler" "rubygems-bundler" 1

print_title "Initialisation de l'environnement des codes sources"
for GEMFILE in $(find . -type f -name Gemfile | grep -v .vendors)
do
  if [ -e "$GEMFILE" ] && [ ! -z "$GEMFILE" ]; then
    install_source `dirname $GEMFILE`
  fi
done
print_resume
exit 0
