#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==================================="
echo "Ruby Syntax Check for ./ruby directory"
echo "==================================="
echo

error_count=0
file_count=0

while IFS= read -r file; do
    ((file_count++))
    echo -n "Checking: $file ... "
    
    if ruby -c "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}ERROR${NC}"
        echo -e "${YELLOW}Error details:${NC}"
        ruby -c "$file" 2>&1 | sed 's/^/  /'
        echo
        ((error_count++))
    fi
done < <(find ./ruby -name "*.rb" -type f | sort)

echo
echo "==================================="
echo "Summary:"
echo "Total files checked: $file_count"
if [ $error_count -eq 0 ]; then
    echo -e "${GREEN}All files passed syntax check!${NC}"
    exit 0
else
    echo -e "${RED}Files with syntax errors: $error_count${NC}"
    exit 1
fi