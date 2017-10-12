#!/bin/bash

if [[ -f checkmk.conf ]]; then
  read -r -p "config file checkmk.conf exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv checkmk.conf checkmk.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -z "$CHECKMK_HOSTNAME" ]; then
  read -p "Hostname (FQDN): " -ei "checkmk.example.org" CHECKMK_HOSTNAME
fi

if [ -z "$CHECKMK_ADMIN_MAIL" ]; then
  read -p "CheckMK admin Mail address: " -ei "mail@example.com" CHECKMK_ADMIN_MAIL
fi

[[ -f /etc/timezone ]] && TZ=$(cat /etc/timezone)
if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
fi

cat << EOF > checkmk.conf
# ------------------------------
# checkmk web ui configuration
# ------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
CHECKMK_HOSTNAME=${CHECKMK_HOSTNAME}

# ------------------------------
# CHECKMK admin user
# ------------------------------
CHECKMK_ADMIN=checkmkadmin
CHECKMK_ADMIN_MAIL=${CHECKMK_ADMIN_MAIL}
CHECKMK_PASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------
# Bindings
# ------------------------------

# You should use HTTPS, but in case of SSL offloaded reverse proxies:
HTTP_PORT=5000
HTTP_BIND=0.0.0.0

# Your timezone
TZ=${TZ}

# Fixed project name
COMPOSE_PROJECT_NAME=checkmk

EOF

