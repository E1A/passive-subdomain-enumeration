#!/bin/bash

# Ask the user for the target domain
read -p "Enter the target domain: " target_domain

# Define the output file
output_file="${target_domain}-output.txt"

# Define the custom user agent
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

# Run the commands with the provided target domain and append the output to the output file
curl -s -A "${user_agent}" "https://subdomainfinder.c99.nl/scans/$(date +"%Y-%m-%d")/${target_domain}" | grep -Po '.*?//\K.*?(?=/)' | grep ${target_domain} | awk -F "'" '{print $1}' | sort -u >> "${output_file}"
curl -s -A "${user_agent}" "http://web.archive.org/cdx/search/cdx?url=*.${target_domain}/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e "s/\/.*//" | sort -u >> "${output_file}"
curl -s -A "${user_agent}" "https://crt.sh/?q=%25.${target_domain}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u >> "${output_file}"
curl -s -A "${user_agent}" "https://api.certspotter.com/v1/issuances?domain=${target_domain}&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> "${output_file}"
curl -s -A "${user_agent}" "https://api.subdomain.center/?domain=${target_domain}" | jq '.[]' -r | sort -u >> "${output_file}"
curl -s -A "${user_agent}" "https://shrewdeye.app/domains/${target_domain}.txt?valid=true" >> "${output_file}"

subfinder -d "${target_domain}" -silent >> "${output_file}"
#nmap --script hostmap-crtsh.nse "${target_domain}" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> "${output_file}"

# Remove duplicates and save the results back to the output file
sort -u -o "${output_file}" "${output_file}"

echo "Results have been saved to ${output_file}"
