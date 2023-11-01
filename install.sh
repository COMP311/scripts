#!/usr/bin/env bash
# Install COMP 311 software Digital, SAPsim, MARS
# Usage: ./install.sh [no_sapsim]
# or
# curl -s "https://raw.githubusercontent.com/COMP311/scripts/main/install.sh" | bash[ -s no_sapsim]
# Author: Jesse Wei <jesse@cs.unc.edu>

# TODO: Convert to actual flag (e.g., https://mywiki.wooledge.org/BashFAQ/035), not $1
# getopts is fine but doesn't allow non-single-char flag, prefer the above
# I didn't have time to implement and test - Jesse
FLAG_SAPSIM=$1

if ! command -v java &> /dev/null; then
    JAVA_VER="17.0.9-oracle"
    echo "You do not have Java installed. Would you like to automatically install java $JAVA_VER now and proceed with installation? [y/n]"
    read install_java
    install_java_lower=$(echo "$install_java" | tr '[:upper:]' '[:lower:]')
    if [[ "$install_java_lower" = "y" ]]; then
        echo "Continuing installation"
        # For installing Java (version $JAVA_VER) and setting as default
        curl -s "https://get.sdkman.io" | bash
        source $HOME/.sdkman/bin/sdkman-init.sh
        # Answer yes to setting installed java version as default
        yes | sdk install java $JAVA_VER
        # Make sure it's default
        sdk default java $JAVA_VER
        if ! sdk current java | grep -q "$JAVA_VER"; then
            printf "This script was unable to set your Java version to $JAVA_VER using SDKMAN! Please install java yourself and re-run this script.
Halting.\n"
        fi
    else
        echo "Halting installation. Please install java yourself and re-run this script."
        exit 1
    fi
fi

# Warning: This section was not fully tested across multiple platforms
# Python environment sucks
# TODO: Use flag (e.g., https://mywiki.wooledge.org/BashFAQ/035) instead of $1
# getopts is fine but doesn't allow non-single-char flag, prefer the above
# I didn't have time to implement and test - Jesse
if [[ "$FLAG_SAPSIM" != "no_sapsim" ]]; then
    if (! command -v python &> /dev/null) && (! command -v python3 &> /dev/null); then
        echo "You do not have Python 3.9+ installed (i.e., python and python3 commands both not found). Please install Python 3.9+ (required for SAPsim tool) and re-run this script."
        echo "Exiting."
        exit 1
    elif command -v python &> /dev/null; then
        python -m pip install --upgrade pip
        python -m pip install SAPsim
    else
        python3 -m pip install --upgrade pip
        python3 -m pip install SAPsim
    fi
fi

INSTALL_DIR=$HOME/.comp311
mkdir -p $INSTALL_DIR

DIGITAL=https://github.com/hneemann/Digital/releases/download/v0.30/Digital.zip
DIGITAL_ZIP="${DIGITAL##*/}"
# wget not pre-installed on macOS
# curl --output-dir is on a high version of cURL that may not be installed on user system
# Unfortunately, this means we can't curl to $INSTALL_DIR
# Must curl to cwd then mv to $INSTALL_DIR
curl -OJL $DIGITAL
unzip $DIGITAL_ZIP > /dev/null
rm $DIGITAL_ZIP
mv Digital/Digital.jar $INSTALL_DIR
rm -r Digital

MARS=http://courses.missouristate.edu/kenvollmar/mars/MARS_4_5_Aug2014/Mars4_5.jar
MARS_JAR="${MARS##*/}"
# -J makes this slow
curl -OL $MARS
mv $MARS_JAR $INSTALL_DIR

# Pretend dictionary in bash 3
# If changing this, update README.md with new command(s)
JARS=(
    "digital:$INSTALL_DIR/Digital.jar"
    "mars:$INSTALL_DIR/$MARS_JAR"
)

# Determine name of shell rc file
# This script is always run via bash
# But $SHELL will be user's shell (e.g., /bin/zsh) even so
if [[ $SHELL = *"bash"* ]]; then
	SHELL_RC_FILE=$HOME/.bashrc
elif [[ $SHELL = *"zsh"* ]]; then
	SHELL_RC_FILE=$HOME/.zshrc
# Extreme edge case
else
    printf "\nJAR files have been downloaded to $INSTALL_DIR.
    
However, this script cannot create aliases for the JAR files because your \$SHELL is not bash or zsh,
so I don't know what your shell's equivalent to .bashrc or .zshrc is.
You can alias the command yourself, if you'd like.
I assume that since you're not using bash nor zsh, you know how to do this.
Otherwise, the .jar has already been downloaded and can be run however you normally run a .jar file.\n"
    exit 1
fi

SHELL_RC_FILE_OWNER=$(ls -l $SHELL_RC_FILE | awk '{print $3}')

if [[ "$SHELL_RC_FILE_OWNER" != "$USER" ]]; then
    echo "ERROR: Owner of $SHELL_RC_FILE is not you ($USER)."
    # Group is left out, so the group becomes the default group for $USER
    echo "Run \`sudo chown $USER: $SHELL_RC_FILE\` to change ownership, then re-run this script."
    echo "Exiting."
    exit 1
fi

# Alias the commands
for kv in "${JARS[@]}" ; do
    COMMAND=${kv%%:*}
    JAR=${kv#*:}
    echo "alias $COMMAND=\"java -jar $JAR\"" >> "$SHELL_RC_FILE"
done

printf "\nJAR files have been downloaded to $INSTALL_DIR, and aliases for launching the JAR files have been created.\n\n"
printf "**Run \`source $SHELL_RC_FILE\` to apply changes to your current shell session; otherwise, restart your terminal.** Then,\n\n"

USAGE_FILE=$INSTALL_DIR/usage.txt
USAGE=""

for kv in "${JARS[@]}" ; do
    COMMAND=${kv%%:*}
    JAR=${kv#*:}
    USAGE+="Run \`$COMMAND\` to launch $JAR\n"
done
USAGE+="For Digital, run \`digital file.dig\` to directly open file.dig on launch. However, this does not work for MARS.\n"
if [[ "$FLAG_SAPSIM" != "no_sapsim" ]]; then
    USAGE+="SAPsim was installed via pip.\n"
fi

printf "$USAGE" | tee $USAGE_FILE

echo "alias help-comp311=\"cat $USAGE_FILE\"" >> "$SHELL_RC_FILE"
echo "To view this message again, run \`help-comp311\`."
