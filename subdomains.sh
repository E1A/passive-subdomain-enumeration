#!/bin/bash

# Initialize variables
target_domain=""
output_file=""
httpx_output_file="httpx-${target_domain}-subd.txt"

# Usage function
usage() {
    echo "Usage: $0 -u <target_domain> [-ad]"
    echo "  -u <target_domain>: Specify the target domain (required)"
    echo "  -ad: Check if the found subdomains are active"
    exit 1
}

# Parse command-line options
while getopts ":u:ad" opt; do
    case ${opt} in
        u)
            target_domain="$OPTARG"
            httpx_output_file="httpx-${target_domain}-subd.txt"
            ;;
        a)
            do_httpx_scan=true
            ;;
        d)
            # Ignore this option for now
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Check if target_domain is provided
if [ -z "$target_domain" ]; then
    echo "Target domain not specified."
    usage
fi

# Define the output file
output_file="${target_domain}-subd.txt"

# Define the custom user agent
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

# Run subdomain discovery commands and append results to the output file
subdomain_commands=(
    "curl -s -A '${user_agent}' 'https://subdomainfinder.c99.nl/scans/$(date +%Y-%m-%d)/${target_domain}' | grep -Po '.*?//\K.*?(?=/)' | grep '${target_domain}' | awk -F \"'\" '{print \$1}'"
    "curl -s -A '${user_agent}' 'http://web.archive.org/cdx/search/cdx?url=*.${target_domain}/*&output=text&fl=original&collapse=urlkey' | sed -e 's_https*://__' -e 's/\/.*//'"
    "curl -s -A '${user_agent}' 'https://crt.sh/?q=%25.${target_domain}&output=json' | jq -r '.[].name_value' | sed 's/\*\.//g'"
    "curl -s -A '${user_agent}' 'https://api.certspotter.com/v1/issuances?domain=${target_domain}&include_subdomains=true&expand=dns_names' | jq .[].dns_names | grep -Po '([\w.-]*)\.([\w]*)\.([A-z])\w+'"
    "curl -s -A '${user_agent}' 'https://api.subdomain.center/?domain=${target_domain}' | jq '.[]' -r"
    "curl -s -A '${user_agent}' 'https://shrewdeye.app/domains/${target_domain}.txt?valid=true'"
    "subfinder -d '${target_domain}' -silent"
    #"nmap --script hostmap-crtsh.nse '${target_domain}' | grep -Po '([\w.-]*)\.([\w]*)\.([A-z])\w+'"
)

for command in "${subdomain_commands[@]}"; do
    eval "${command}" | sort -u >> "${output_file}"
done

# Remove duplicates from the output file
sort -u -o "${output_file}" "${output_file}"

echo "All discovered subdomains have been saved to ${output_file}"

# Run HTTPX scan if -ad option is provided
if [ "$do_httpx_scan" = true ]; then
    echo "Starting HTTPX on discovered subdomains..."
    httpx -l "${output_file}" > "${httpx_output_file}"
    echo "HTTPX results have been saved to ${httpx_output_file}"
fi
