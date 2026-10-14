#!/bin/sh
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/lua-language-server"
exec /usr/lib/lua-language-server/bin/lua-language-server \
    --logpath="$STATE/log" --metapath="$STATE/meta" "$@"
