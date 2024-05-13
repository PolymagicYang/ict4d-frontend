#!/bin/sh

# Replace placeholders in static files with values from ConfigMap
sed -i 's|__VITE_APP_API_BASE_URL__|'$(cat /config/VITE_APP_API_BASE_URL)'|g' /usr/share/nginx/html/js/*.js

# Start Nginx
exec nginx -g 'daemon off;'
