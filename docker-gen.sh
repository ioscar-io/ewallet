#!/bin/sh

OPTS=hdi:n:p:k:K:
ARGS=$(getopt $OPTS "$*" 2>/dev/null)

print_usage() {
    printf "Usage: %s [-%s]\\n" "$0" "$OPTS"
    printf "\\n"
    printf "     -h         Print this help.\\n"
    printf "     -d         Generate a development override.\\n"
    printf "\\n"
    printf "Config:\\n"
    printf "\\n"
    printf "     -i image   Specify an alternative eWallet image name.\\n"
    printf "     -n network Specify an external network.\\n"
    printf "     -p passwd  Specify a PostgreSQL password.\\n"
    printf "     -k key1    Specify an eWallet secret key.\\n"
    printf "     -K key2    Specify a local ledger secret key.\\n"
    printf "\\n"
}

# shellcheck disable=SC2181
if [ $? != 0 ]; then
    print_usage
    exit 1
fi

# shellcheck disable=SC2086
set -- $ARGS

IMAGE_NAME=""
POSTGRES_PASSWORD=""
EXTERNAL_NETWORK=""
EWALLET_SECRET_KEY=""
LOCAL_LEDGER_SECRET_KEY=""
DEV_MODE=0

while true; do
    case "$1" in
        -i ) IMAGE_NAME=$2;              shift; shift;;
        -n ) EXTERNAL_NETWORK=$2;        shift; shift;;
        -p ) POSTGRES_PASSWORD=$2;       shift; shift;;
        -k ) EWALLET_SECRET_KEY=$2;      shift; shift;;
        -K ) LOCAL_LEDGER_SECRET_KEY=$2; shift; shift;;
        -d ) DEV_MODE=1;  shift;;
        -h ) print_usage; exit 2;;
        *  ) break;;
    esac
done

[ -z "$EWALLET_SECRET_KEY" ]      && EWALLET_SECRET_KEY=$(openssl rand -base64 32)
[ -z "$LOCAL_LEDGER_SECRET_KEY" ] && LOCAL_LEDGER_SECRET_KEY=$(openssl rand -base64 32)
[ -z "$POSTGRES_PASSWORD" ]       && POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr '+/' '-_')

if [ -z "$IMAGE_NAME" ]; then
   if [ $DEV_MODE = 1 ]; then
       IMAGE_NAME="omisegoimages/ewallet-builder:stable"
   else
       IMAGE_NAME="omisego/ewallet:dev"
   fi
fi

YML_SERVICES="
  postgres:
    environment:
      POSTGRESQL_PASSWORD: $POSTGRES_PASSWORD\
" # EOF

YML_SERVICES="
  ewallet:
    image: $IMAGE_NAME
    environment:
      DATABASE_URL: postgresql://postgres:$POSTGRES_PASSWORD@postgres:5432/ewallet
      LOCAL_LEDGER_DATABASE_URL: postgresql://postgres:$POSTGRES_PASSWORD@postgres:5432/local_ledger
      EWALLET_SECRET_KEY: $EWALLET_SECRET_KEY
      LOCAL_LEDGER_SECRET_KEY: $LOCAL_LEDGER_SECRET_KEY\
" # EOF

if [ $DEV_MODE = 1 ]; then
    YML_SERVICES="$YML_SERVICES
    user: root
    volumes:
      - .:/app
      - ewallet-deps:/app/deps
      - ewallet-builds:/app/_build
      - ewallet-node:/app/apps/admin_panel/assets/node_modules
    working_dir: /app
    command:
      - mix
      - omg.server\
" # EOF

    YML_VOLUMES="
  ewallet-deps:
  ewallet-builds:
  ewallet-node:\
" # EOF
fi

if [ -n "$EXTERNAL_NETWORK" ]; then
    YML_NETWORKS="
  intnet:
    external:
      name: $EXTERNAL_NETWORK\
" # EOF
fi

printf "version: \"3\"\\n"
[ -n "$YML_SERVICES" ] && printf "\\nservices:%s\\n" "$YML_SERVICES"
[ -n "$YML_NETWORKS" ] && printf "\\nnetworks:%s\\n" "$YML_NETWORKS"
[ -n "$YML_VOLUMES" ]  && printf "\\nvolumes:%s\\n"  "$YML_VOLUMES"
