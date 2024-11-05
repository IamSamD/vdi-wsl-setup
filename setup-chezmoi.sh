#!/bin/bash

set -euo pipefail

CHEZMOI_VERSION="v2.53.1"
AGE_VERSION="v1.2.0"
SHOW_HELP=false
AGE_PUBLIC_KEY=""

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]
Options:
    --help    Display help
Example:
    $(basename "$0")
Example:
    $(basename "$0") --help
EOF
}

log_info() {
    arg1=$1
    echo -e "\033[36m${arg1}\033[0m"
}

log_error() {
    arg1=$1
    echo -e "\033[31m${arg1}\n\033[31m"
}

log_successful() {
    echo -e "\033[32mSuccessful\n\033[0m"
}

write_instructions() {
    cat << EOF
Chezmoi has been successfully installed and initialised.
Full documentation for chezmoi can be found here:  https://www.chezmoi.io/
A stanard config file has been created at ~/.config/chezmoi/chezmoi.yaml
This configures chezmoi to use encryption when adding dotfiles to be tracked by chezmoi.
It also configures chezmoui to auto add, commit and push changes to dotfile when the tracked dotfile is edited with:
chezmoi edit <PATH_TO_DOTFILE>
You can further amend your config file to your liking. 
chezmoi uses ~/.local/share/chezmoi as a git repo for tracking your dotfiles
You should create a private github repo, set it up for ssh and configure the remote as below
cd ~/.local/share/chezmoi
git remote add origin <YOUR_REPO_SHH_CLONE_URL>
git add .
git commit -m "initial commit"
git push -u origin main
To track a dotfile with chezmoi use:
chezmoi add <PATH_TO_DOTFILE>
IMPORTANT: A keypair has been generated for encryption. The private key can be found at ~/.config/chezmoi/chezmoi-private-key.txt
You should back up this key in a password manager or keyvault so that you do not lose it when the VDI is upgraded.
EOF
}

install_chezmoi() {
    chezmoi_filename=chezmoi_${CHEZMOI_VERSION#v}_linux_amd64.tar.gz

    log_info "Downloading chezmoi..."
    curl -sL https://github.com/twpayne/chezmoi/releases/download/${CHEZMOI_VERSION}/${chezmoi_filename} -o /tmp/${chezmoi_filename}
    log_successful

    log_info "Extracting  chezmoi..."
    tar -xzf /tmp/${chezmoi_filename} -C /tmp/
    log_successful

    log_info "Installing chezmoi to ~/bin..."
    mkdir -p ~/bin && cp /tmp/chezmoi $HOME/bin
    log_successful
}

install_age() {
    age_filename=age-${AGE_VERSION}-linux-amd64.tar.gz

    log_info "Downloading age..."
    curl -sL https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${age_filename} -o /tmp/${age_filename}
    log_successful

    log_info "Extracting age..."
    tar -xzf /tmp/${age_filename} -C /tmp/
    log_successful

    log_info "Installing age to ~/bin..."
    cp /tmp/age/age /tmp/age/age-keygen $HOME/bin
    log_successful
}

generate_encryption_keys() {
    mkdir -p $HOME/.config/chezmoi
    log_info "Generating keypair for age encryption..."
    AGE_PUBLIC_KEY=$($HOME/bin/age-keygen -o "$HOME/.config/chezmoi/chezmoi-private-key.txt" 2>&1 | sed -n 's/^Public key: //p')
    log_successful
    log_info "Private key generated and saved in $HOME/.config/chezmoi/chezmoi-private-key.txt\n"
}

generate_chezmoi_config_file() {
    log_info "Generating chezmoi config file..."
    cat <<EOF > $HOME/.config/chezmoi/chezmoi.yaml
sourceDir: ~/.local/share/chezmoi
encryption: age
age:
  identity: .config/chezmoi/chezmoi-private-key.txt
  recipient: ${AGE_PUBLIC_KEY}
format: yaml
progress: true
add:
  encrypt: true
edit:
  command: vim
cd:
  command: /bin/bash
  args:
    - -c
    - cd ~/.local/share/chezmoi && exec bash
git:
  autoAdd: true
  autoCommit: true
  autoPush: true
EOF
log_successful
}

initialise_chezmoi() {
    log_info "Initialising chezmoi..."
    CHEZMOI_BIN="$HOME/bin/chezmoi"

    if [[ ! -x "$CHEZMOI_BIN" ]]; then
        echo "Error: chezmoi binary not found at $CHEZMOI_BIN"
        exit 1
    fi

    "$CHEZMOI_BIN" init
    log_successful
}

add_chezmoi_location_to_bashrc() {
    HOME_BIN="$HOME/bin"

    if [[ ":$PATH:" != *":$HOME_BIN:"* ]]; then
        log_info "Adding ~/bin to PATH in .bashrc"
        if [ -e "$HOME/.bashrc" ]; then
            echo 'export PATH=$PATH:$HOME/bin' >> $HOME/.bashrc
        else
            touch "$HOME/.bashrc"
            echo 'export PATH=$PATH:$HOME/bin' >> $HOME/.bashrc
        fi
        log_successful
    fi
}

# ----------------------
# main execution
# ----------------------

# Parse args
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --help)
            SHOW_HELP=true
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# Show help and exit if --help flag is set
if [[ "$SHOW_HELP" = true ]]; then
    usage
    exit 0
fi

# check dependencies and handle where missing
if ! command -v curl &> /dev/null; then
    log_error "curl is required but not installed"
    exit 1
fi

if ! command -v tar &> /dev/null; then
    log_error "tar is required but not installed"
    exit 1
fi


install_chezmoi
install_age
generate_encryption_keys
generate_chezmoi_config_file
initialise_chezmoi
add_chezmoi_location_to_bashrc
write_instructions