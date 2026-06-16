#!/bin/bash
# Core Signing Orchestration

run_signing() {
    echo -e "${GREEN}--> Initializing Signing Process${NC}"
    echo -e "    ${BLUE}Directory:${NC} $KEYS_DIR"
    echo -e "    ${BLUE}Key Size:${NC}  $KEY_SIZE"
    echo -e "    ${BLUE}Skip OTA:${NC}  $SKIP_OTA"

    # Export variables for backend
    export KEYS_DIR="$KEYS_DIR"
    export KEY_SIZE="$KEY_SIZE"
    export SUBJECT_INFO="$SUBJECT_INFO"
    export SKIP_OTA="$SKIP_OTA"
    
    pushd "$SCRIPT_DIR/main" > /dev/null
    bash keys.sh
    popd > /dev/null
    
    echo -e "\n${GREEN}✓ All tasks completed successfully!${NC}"
    echo -e "🔏 ${YELLOW}Generated with Signify by TopexGuy${NC}"
}
