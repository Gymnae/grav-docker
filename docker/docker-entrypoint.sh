#!/bin/bash

if ! [ -e index.php -a -e bin/grav ]; then
  echo "Required files not found in $PWD - Copying from ${SOURCE}..."
  cp -r "$SOURCE"/. $PWD
  chown -R nginx:www-data $PWD
  echo "Done."
fi

exec "$@"
