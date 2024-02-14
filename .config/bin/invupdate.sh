#!/bin/bash

### Update Invoice Ninja ###

# Set the -euo pipefail option to exit immediately if any command fails or any undefined variable is used
set -euo pipefail

###-------- Define Installation Variables --------###

base_dir="/srv/users/invoicing/apps"


# Name of directory that Invoice Ninja installation is inside
parent_dir="invoicing"

# Name of temp update directory
update_dir="newversion"

# If you need to specify a path for php-cli replace "php" below with the path e.g. "/usr/local/php81/bin/php-cli"
php_cli_cmd="php8.1-sp"

###---------------- Begin Update ----------------###

# Query GitHub for the latest release
url=$(curl --fail -sL -o /dev/null -w %{url_effective} https://github.com/invoiceninja/invoiceninja/releases/latest)

# Check if the curl command was successful
if [ $? -ne 0 ]; then
  # The curl command failed, so print an error message and exit
  echo "Error: Failed to query GitHub for the latest release."
  exit 1
fi

# Extract the version number from the URL
version=$(echo "$url" | grep -oE '[^/]+$')

# Check if the contents of VERSION.txt match the latest version number
version_from_file=$(cat $parent_dir/VERSION.txt)
version_from_file=$(echo "$version_from_file" | sed 's/^/v/')
if [ "$version_from_file" = "$version" ]; then
  echo -e "Latest version already installed! \nInstalled version: $version_from_file \nLatest version: $version"
  exit 1
else
  echo "Downloading latest release $version"
fi

# Construct the download URL for the zip file
zip_url="https://github.com/invoiceninja/invoiceninja/releases/download/$version/invoiceninja.zip"

# Download the release
curl --fail -L --location-trusted "$zip_url" -o invoiceninja.zip

# Check if the curl command was successful
if [ $? -ne 0 ]; then
  # The curl command failed, so print an error message and exit
  echo "Error: Failed to download the latest release."
  exit 1
fi

# Create temp update directory
mkdir -p "$update_dir"

# Move zip file
mv invoiceninja.zip "$update_dir/"

# Unzip the file
echo "Extracting zip file, this can take while..."
unzip -qq $update_dir/invoiceninja.zip -d "$update_dir"

# Delete zip file
rm "$update_dir/invoiceninja.zip"

# Copy the .env file, public/storage folder & snappdf to the update directory
echo "Backing up config, logo, PDF files & snappdf versions"
cp "$parent_dir/.env" "$update_dir/"
cp -r "$parent_dir/public/storage" "$update_dir/public/"
# cp -r "$parent_dir/vendor/beganovich/snappdf/versions" "$update_dir/vendor/beganovich/snappdf/"

# Comment out the line below if you don't want to preserve the logs
cp -r "$parent_dir/storage/logs" "$update_dir/storage/"

# Uncomment and edit the lines below to add any other folders or files that you'd like to keep 
cp "$parent_dir/public/.user.ini" "$update_dir/public/"

# Replace the parent folder with the update folder 
echo "Parent and update folder switcheroo..."
renamed_parent="${parent_dir}_OLD"
mv "$parent_dir" "$renamed_parent"
mv "$update_dir" "$parent_dir"

# Disable cookie bar
sed -i 's/left:0;right:0;bottom:0/left:0;right:0;bottom:0;display:none;/' $parent_dir/public/vendor/cookieconsent@3/cookieconsent.min.css

# Change payment page wording
sed -i 's/ we need more details about you./, please fill out the details below:/' $parent_dir/lang/en/texts.php

# Change payment page wording
sed -i 's/Payment was made by :client/:invoice - Payment was made by :client/' $parent_dir/lang/en/texts.php

# Update config
echo "Updating config and clearing caches..."
$php_cli_cmd "$parent_dir/artisan" clear-compiled
$php_cli_cmd "$parent_dir/artisan" route:clear
$php_cli_cmd "$parent_dir/artisan" view:clear
$php_cli_cmd "$parent_dir/artisan" migrate --force
$php_cli_cmd "$parent_dir/artisan" optimize

# Protect .env from public download
chmod 600 $parent_dir/.env

# Make sure web user owns all files
chown -R invoicing:invoicing $parent_dir

# Remove temp update folder
# echo "Cleaning up old version files..."
# rm -rf "$renamed_parent"

# Check if the contents of VERSION.txt match the latest version number
check_version_from_file=$(cat $parent_dir/VERSION.txt)
check_version_from_file=$(echo "$check_version_from_file" | sed 's/^/v/')
if [ "$check_version_from_file" = "$version" ]; then
  echo -e "Invoice Ninja successfully updated! \nInstalled version: $check_version_from_file"
else
  echo -e "Update failed! \nInstalled version: $check_version_from_file \nLatest version: $version"
fi
