#!/bin/bash

# SCRCPY Wireless Launcher for macOS/Linux
# Author: netphantom.og
# GitHub: https://github.com/netphantom-og
# Instagram: https://instagram.com/netphantom.og

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_banner() {
    echo
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "${CYAN}                                                                ${NC}"
    echo -e "${GREEN}                    SCRCPY WIRELESS LAUNCHER                  ${NC}"
    echo -e "${YELLOW}                        Version 1.0.0                         ${NC}"
    echo -e "${CYAN}                                                                ${NC}"
    echo -e "${MAGENTA}                    Author: netphantom.og                     ${NC}"
    echo -e "${CYAN}                                                                ${NC}"
    echo -e "${CYAN}==================================================================${NC}"
    echo
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to get architecture
get_architecture() {
    if [[ "$(uname -m)" == "x86_64" ]]; then
        echo "64"
    elif [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "aarch64" ]]; then
        echo "arm64"
    else
        echo "32"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to download scrcpy
download_scrcpy() {
    local os=$1
    local arch=$2
    
    echo -e "${CYAN}[INFO] Detecting system and providing download link...${NC}"
    
    if [[ "$os" == "macos" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            echo -e "${GREEN}[INFO] macOS ARM64 detected${NC}"
            echo -e "${GRAY}Download: https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-macos-arm64.tar.gz${NC}"
        else
            echo -e "${GREEN}[INFO] macOS Intel detected${NC}"
            echo -e "${GRAY}Download: https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-macos-x86_64.tar.gz${NC}"
        fi
    elif [[ "$os" == "linux" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            echo -e "${GREEN}[INFO] Linux ARM64 detected${NC}"
            echo -e "${GRAY}Download: https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-linux-arm64.tar.gz${NC}"
        else
            echo -e "${GREEN}[INFO] Linux x86_64 detected${NC}"
            echo -e "${GRAY}Download: https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-linux-x86_64.tar.gz${NC}"
        fi
    fi
    
    echo -e "${GRAY}1. Download the file above${NC}"
    echo -e "${GRAY}2. Extract it to the 'scrcpy' folder${NC}"
    echo -e "${GRAY}3. Make sure adb and scrcpy are executable${NC}"
    echo -e "${GRAY}4. Run this script again${NC}"
    echo
}

# Function to create desktop shortcut
create_desktop_shortcut() {
    local script_path="$1"
    local os="$2"
    
    if [[ "$os" == "macos" ]]; then
        # Create macOS application bundle or alias
        local desktop_dir="$HOME/Desktop"
        local shortcut_name="SCRCPY Wireless Launcher.command"
        local shortcut_path="$desktop_dir/$shortcut_name"
        
        if [[ ! -f "$shortcut_path" ]]; then
            echo -e "${CYAN}[INFO] Creating desktop shortcut...${NC}"
            cat > "$shortcut_path" << EOF
#!/bin/bash
cd "$(dirname "$0")"
cd "$(dirname "$script_path")"
./scrcpy-wireless.sh
EOF
            chmod +x "$shortcut_path"
        fi
    elif [[ "$os" == "linux" ]]; then
        # Create Linux desktop entry
        local desktop_dir="$HOME/Desktop"
        local shortcut_name="SCRCPY Wireless Launcher.desktop"
        local shortcut_path="$desktop_dir/$shortcut_name"
        
        if [[ ! -f "$shortcut_path" ]]; then
            echo -e "${CYAN}[INFO] Creating desktop shortcut...${NC}"
            cat > "$shortcut_path" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=SCRCPY Wireless Launcher
Comment=One-click wireless Android screen mirroring
Exec=$script_path
Icon=phone
Terminal=true
Categories=Utility;
EOF
            chmod +x "$shortcut_path"
        fi
    fi
}

# Main script
main() {
    print_banner
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SCRCPY_DIR="$SCRIPT_DIR/scrcpy"
    
    # Detect OS and architecture
    OS=$(detect_os)
    ARCH=$(get_architecture)
    
    echo -e "${CYAN}[INFO] Detected: $OS ($(uname -m))${NC}"
    
    # Check if scrcpy directory exists
    if [[ ! -d "$SCRCPY_DIR" ]]; then
        echo -e "${YELLOW}[INFO] Creating scrcpy directory...${NC}"
        mkdir -p "$SCRCPY_DIR"
    fi
    
    # Check for adb
    ADB_PATH="$SCRCPY_DIR/adb"
    if [[ ! -f "$ADB_PATH" ]]; then
        echo -e "${RED}[ERROR] Missing file: adb${NC}"
        echo -e "${YELLOW}Expected at: $ADB_PATH${NC}"
        echo
        download_scrcpy "$OS" "$ARCH"
        exit 1
    fi
    
    # Check for scrcpy
    SCRCPY_PATH="$SCRCPY_DIR/scrcpy"
    if [[ ! -f "$SCRCPY_PATH" ]]; then
        echo -e "${RED}[ERROR] Missing file: scrcpy${NC}"
        echo -e "${YELLOW}Expected at: $SCRCPY_PATH${NC}"
        echo
        download_scrcpy "$OS" "$ARCH"
        exit 1
    fi
    
    # Make files executable
    chmod +x "$ADB_PATH" 2>/dev/null
    chmod +x "$SCRCPY_PATH" 2>/dev/null
    
    # Create desktop shortcut
    create_desktop_shortcut "$SCRIPT_DIR/scrcpy-wireless.sh" "$OS"
    
    # Initialize adb server
    echo -e "${CYAN}[INFO] Starting ADB server...${NC}"
    "$ADB_PATH" start-server >/dev/null 2>&1
    
    # Detect existing TCP/IP device first
    echo -e "${CYAN}[INFO] Checking for existing wireless connections...${NC}"
    SERIAL=""
    FOUND_WIRELESS=false
    
    # Check for existing wireless connections
    while IFS= read -r line; do
        if [[ $line =~ :5555[[:space:]]+device ]]; then
            SERIAL=$(echo "$line" | awk '{print $1}')
            FOUND_WIRELESS=true
            echo -e "${GREEN}[INFO] Using existing wireless device $SERIAL${NC}"
            "$ADB_PATH" connect "$SERIAL" >/dev/null 2>&1
            break
        fi
    done < <("$ADB_PATH" devices)
    
    # If no wireless connection, check for USB device
    if [[ "$FOUND_WIRELESS" == false ]]; then
        echo -e "${CYAN}[INFO] Checking for USB devices...${NC}"
        while IFS= read -r line; do
            if [[ $line =~ device$ ]]; then
                SERIAL=$(echo "$line" | awk '{print $1}')
                echo -e "${GREEN}[INFO] USB device detected: $SERIAL${NC}"
                break
            fi
        done < <("$ADB_PATH" devices)
    fi
    
    # If no device found
    if [[ -z "$SERIAL" ]]; then
        echo -e "${YELLOW}[WARNING] No device detected over USB or wireless.${NC}"
        echo -e "${GRAY}➡ If you used this before, just ensure the phone stayed on the same WiFi and try again.${NC}"
        echo -e "${GRAY}➡ Otherwise, connect via USB once to initialize wireless mode.${NC}"
        read -p "Press Enter to continue..."
        exit 1
    fi
    
    # If USB device found, enable wireless
    if [[ "$FOUND_WIRELESS" == false ]]; then
        echo -e "${CYAN}[INFO] Enabling TCP/IP mode (port 5555)...${NC}"
        "$ADB_PATH" tcpip 5555 >/dev/null 2>&1
        sleep 2
        
        # Get device IP using multiple strategies
        echo -e "${CYAN}[INFO] Detecting phone IP address...${NC}"
        IP=""
        
        # Method 1: Android properties (most reliable)
        echo -e "${CYAN}[INFO] Trying Android properties method...${NC}"
        for prop in dhcp.wlan0.ipaddress dhcp.eth0.ipaddress dhcp.wlan1.ipaddress; do
            if [[ -z "$IP" ]]; then
                IP=$("$ADB_PATH" shell "getprop $prop 2>/dev/null")
                if [[ -n "$IP" ]] && [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo -e "${GREEN}[SUCCESS] IP found via property $prop: $IP${NC}"
                    break
                else
                    IP=""
                fi
            fi
        done
        
        # Method 2: Network interfaces
        if [[ -z "$IP" ]]; then
            echo -e "${CYAN}[INFO] Trying network interface method...${NC}"
            for interface in wlan0 eth0 wlan1 rmnet_data0; do
                if [[ -z "$IP" ]]; then
                    IP=$("$ADB_PATH" shell "ip -f inet addr show $interface 2>/dev/null | grep -o 'inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | awk '{print \$2}' | head -1")
                    if [[ -n "$IP" ]]; then
                        echo -e "${GREEN}[SUCCESS] IP found via interface $interface: $IP${NC}"
                        break
                    fi
                fi
            done
        fi
        
        # Method 3: Route-based detection
        if [[ -z "$IP" ]]; then
            echo -e "${CYAN}[INFO] Trying route-based method...${NC}"
            IP=$("$ADB_PATH" shell "ip route 2>/dev/null | grep -o 'src [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | awk '{print \$2}' | head -1")
            if [[ -n "$IP" ]]; then
                echo -e "${GREEN}[SUCCESS] IP found via route: $IP${NC}"
            fi
        fi
        
        # Method 4: Compact addr list
        if [[ -z "$IP" ]]; then
            echo -e "${CYAN}[INFO] Trying compact address method...${NC}"
            IP=$("$ADB_PATH" shell "ip -o -4 addr show 2>/dev/null | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | head -1")
            if [[ -n "$IP" ]]; then
                echo -e "${GREEN}[SUCCESS] IP found via compact method: $IP${NC}"
            fi
        fi
        
        if [[ -z "$IP" ]]; then
            echo -e "${RED}[ERROR] Could not detect phone IP address.${NC}"
            echo -e "${GRAY}➡ Ensure your phone is connected to WiFi.${NC}"
            echo -e "${GRAY}➡ You may need to edit the script (replace wlan0 with eth0).${NC}"
            read -p "Press Enter to continue..."
            exit 1
        fi
        
        echo -e "${GREEN}[INFO] Phone IP detected: $IP${NC}"
        
        # Connect wirelessly
        SERIAL="$IP:5555"
        echo -e "${CYAN}[INFO] Connecting wirelessly to $SERIAL...${NC}"
        CONNECT_OUTPUT=$("$ADB_PATH" connect "$SERIAL" 2>&1)
        
        if echo "$CONNECT_OUTPUT" | grep -qi "failed\|unable\|cannot"; then
            echo -e "${RED}[ERROR] Could not connect wirelessly.${NC}"
            echo -e "${GRAY}➡ Ensure PC and phone are on the same WiFi network.${NC}"
            echo -e "${GRAY}➡ Reconnect USB once and re-run this script.${NC}"
            read -p "Press Enter to continue..."
            exit 1
        fi
    fi
    
    # Launch scrcpy
    echo -e "${GREEN}[INFO] Starting scrcpy...${NC}"
    echo
    echo -e "${YELLOW}[NOTE] If you restart your PC or kill ADB,${NC}"
    echo -e "${YELLOW}you must reconnect your phone via USB once to restore wireless mode.${NC}"
    echo
    echo -e "${RED}Do not close this window.!!!${NC}"
    echo
    echo -e "${YELLOW}Wireless connection is now active and stable.${NC}"
    echo
    echo -e "${GREEN}Use the Desktop shortcut 'SCRCPY Wireless Launcher' for everyday use. Happy journey!${NC}"
    echo
    
    # Launch scrcpy with the detected serial
    "$SCRCPY_PATH" -s "$SERIAL" --verbosity=error
    
    # Keep terminal open if scrcpy exits
    echo
    echo -e "${YELLOW}[NOTE] scrcpy has exited. You can close this window.${NC}"
    read -p "Press Enter to continue..."
}

# Run main function
main "$@"
