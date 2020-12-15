#!/bin/sh
if [ -f "/tmp/factory_mode" ]; then
  rm -f /tmp/factory_mode
else
  echo '#!/bin/sh
  rm -- "$0"' > /mnt/data/bin/touch
  chmod +x /mnt/data/bin/touch
fi