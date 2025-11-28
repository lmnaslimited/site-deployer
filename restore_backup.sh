#!/bin/bash

# Load variables from environment file
export SITE_NAME=$(grep -w 'SITE_NAME' variable.env | cut -d '=' -f2)
export BENCH_NAME=$(grep -w 'BENCH_NAME' variable.env | cut -d '=' -f2)

# Find and copy backup files to the Docker container
find ./backups -maxdepth 1 -type f -print0 | xargs -0 -I {} docker cp {} $(docker ps --format "{{.ID}}" --filter "name=${BENCH_NAME}_backend"):/home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/

# Extract filenames
export SQL_FILENAME=$(basename "$(ls ./backups/*.sql.gz | head -n 1)")
export PUBLIC_FILENAME=$(basename "$(ls ./backups/*com-files*.tar | head -n 1)")
export PRIVATE_FILENAME=$(basename "$(ls ./backups/*com-private-files*.tar | head -n 1)")

#check whether the encryption key is present or not in the site configuration json file 

if grep -q '"backup_encryption_key"' ./backups/*.json 2>/dev/null; then
# Bench restore command
  export ENCRYPTION_KEY=$(grep -w "backup_encryption_key" ./backups/*.json | sed -E "s/.*: \"([^\"]+)\".*/\1/")
  docker exec -it $(docker ps --format "{{.ID}}" --filter "name=${BENCH_NAME}_backend") bash -c "bench --site ${SITE_NAME} --force restore /home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/${SQL_FILENAME} --with-public-files /home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/${PUBLIC_FILENAME} --with-private-files /home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/${PRIVATE_FILENAME} --encryption-key ${ENCRYPTION_KEY}"
else
  docker exec -it $(docker ps --format "{{.ID}}" --filter "name=${BENCH_NAME}_backend") bash -c "bench --site ${SITE_NAME} --force restore /home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/${SQL_FILENAME} --with-public-files /home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/${PUBLIC_FILENAME} --with-private-files /home/frappe/frappe-bench/sites/${SITE_NAME}/private/backups/${PRIVATE_FILENAME}"
fi
# migrate the site after restoration
docker exec -it $(docker ps --format "{{.ID}}" --filter "name=${BENCH_NAME}_backend") bash -c "bench --site ${SITE_NAME} migrate"
# enable the server script
docker exec -it $(docker ps --format "{{.ID}}" --filter "name=${BENCH_NAME}_backend") bash -c "bench set-config -g server_script_enabled 1"

echo successfully restored
