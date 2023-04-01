#!/bin/bash
set -euo pipefail

base_dir="/srv/users"
date=$(date '+%Y%m%d-%H%M')

folders=()
i=1
for app in "$base_dir"/*/; do
    app_name=$(basename "$app")
    wp_config="$base_dir/$app_name/apps/$app_name/public/wp-config.php"
    
    if [[ -f "$wp_config" ]]; then
        folders+=("$app_name")
        printf "%s: %s\n" $i $app_name
        ((i++))
    fi
done

printf "\n"
printf "Enter the number of the app you want to backup: "

read -r selection

# Check if user input is a valid number
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -gt "${#folders[@]}" ]]; then
    printf "Invalid selection. Exiting.\n"
    exit 1
fi

app=${folders[$((selection - 1))]}

printf "Running commands on the selected app: %s \n" $app

appfolder="$base_dir/$app/apps/$app"
wpconfig="$appfolder/public/wp-config.php"
dbname=$(grep DB_NAME "${wpconfig}" | cut -f4 -d"'")
dbuser=$(grep DB_USER "${wpconfig}" | cut -f4 -d"'")
dbpass=$(grep DB_PASSWORD "${wpconfig}" | cut -f4 -d"'")

printf "Database Name: %s \n" $dbname
printf "Database User: %s \n" $dbuser
printf "Database Pass: %s \n" $dbpass

printf "\nRunning mysqldump...\n"

dbdump="$appfolder/$app-$date.sql.gz"
mysqldump --no-tablespaces --add-drop-table -u $dbuser -p$dbpass $dbname | gzip > $dbdump

printf "\nArchiving Files & Database...\n"

chown $app:$app $dbdump
tar czPf $appfolder/$app.tgz $appfolder/public $dbdump
rm $dbdump

printf "\nDone!\n"
