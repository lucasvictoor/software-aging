#!/usr/bin/env bash

# GLOBAL_VARIABLES
# DESCRIPTION:
#   start globall tools
#
# READONLY VARIABLES:
#   KERNEL_VERSION
GLOBAL_VARIABLES() {
    KERNEL_VERSION=$(uname -r)
    readonly KERNEL_VERSION
}

# CHECK_ROOT
# DESCRIPTION:
#   check if script is running as root
CHECK_ROOT() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Run Script as Super Administrator ( need root )"
        exit 1
    fi
}

# GET_DISTRIBUTION
# DESCRIPTION:
#   verify linux distribution and get id of distribution with version codename
GET_DISTRIBUTION() {
    if [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        distribution_id="$ID"
        distr_codename="$VERSION_CODENAME"
        return 0
    else
        echo -e "\nERROR: error getting machine information\n" && exit 1
    fi
}

# INSTALLING_PACKAGES
# DESCRIPTION:
#   install linux-headers, linux-image, gnupg, wget, curl, sysstat, openssh-server and systemtap
INSTALLING_PACKAGES() {
    apt update

    apt install linux-headers-"$KERNEL_VERSION" linux-image-"$KERNEL_VERSION"-dbg gnupg wget curl sysstat systemtap openssh-server -y || {
        echo -e "\nERROR: Error installing Linux packages and Error installing general packages\n"
        exit 1
    }
}

# CHECKING_STAP_AVAILABLE
# DESCRIPTION:
#   checking stap command availability
CHECKING_STAP_AVAILABLE() {
    if command -v stap &>/dev/null; then
        echo -e "\nsystemtap is already installed\n"
        echo -e "\nEXECUTING THE STAP COMMAND:"

        stap -v -e 'probe oneshot { println("hello world") }'

        return 0
    else
        echo -e "\nsystemtap is not installed\n" >&2
        exit 1
    fi
}

# CONFIGURE_SYSTEMTAP_BINARIES
# DESCRIPTION:
#   Systemtap may need a linux-build style System.map file to find kernel function/data addresses.
#   It may be possible to create it manually
#
# REFERENCES:
#   https://man7.org/linux/man-pages/man7/warning::symbols.7stap.html
CONFIGURE_SYSTEMTAP_BINARIES() {
    echo -e "\nconfiguring debug binaries for systemtap...\n"

    cp /proc/kallsyms /boot/System.map-"$KERNEL_VERSION"

    if [[ $? -eq 0 ]]; then
        echo -e "\nSUCCESS: successfully configured!\n"
        return 0
    else
        echo -e "\nERROR: configuration of systemtap debug binaries failed\n" && exit 1
    fi
}

# Function to check if the VirtualBox repository is already present in sources.list
CHECKING_VIRTUALBOX() {
    if grep -q "download.virtualbox.org" /etc/apt/sources.list; then
        echo "The VirtualBox repository is already configured."
        return 0 # Returns 0 indicating the repository is already present
    else
        echo "Adding the VirtualBox repository..."
        return 1 # Returns 1 indicating the repository needs to be added
    fi
}

# DOWNLOADING_VIRTUALBOX
# DESCRIPTION:
#   backup of sourcers.list, configure and add repository, assiganture keys and download of virtualbox-7.0
DOWNLOADING_VIRTUALBOX() {
    # Checking if the repository is already configured
    if CHECKING_VIRTUALBOX; then
        echo "Skipping repository addition as it's already configured."
    else
        mkdir -p /etc/apt/backup
        cp /etc/apt/sources.list /etc/apt/backup/

        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $distr_codename contrib" >>/etc/apt/sources.list

        wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

        apt update
        if ! apt install virtualbox-7.0 -y; then
            echo -e "\nVirtualBox installed successfully\n"
        else
            echo -e "\nERROR: Error when trying to install virtualbox\n" >&2
            exit 1
        fi
    fi
}

# START_DEPENDENCIES
# DESCRIPTION:
#   starts dependency checking and install dependencies requirements
START_DEPENDENCIES() {
    CHECK_ROOT

    GLOBAL_VARIABLES # get global variables
    GET_DISTRIBUTION # get id and version codename of machine dist

    case $distribution_id in
    "debian")
        reset

        INSTALLING_PACKAGES          # installing util packages and linux packages
        CHECKING_STAP_AVAILABLE      # checking if stap available
        CONFIGURE_SYSTEMTAP_BINARIES # config depuration of systemtap
        DOWNLOADING_VIRTUALBOX       # download virtualbox

        apt update

        echo -e "\nInstallations Completed\n"
        echo "leaving and finishing..."
        exit 0
        ;;

    *)
        echo "ERROR: error identifying the distribution"
        exit 1
        ;;
    esac
}
