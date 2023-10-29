#!/usr/bin/env bash
# Usage: ./install.sh
# or
# curl -s "https://raw.githubusercontent.com/COMP311/scripts/main/install.sh" | bash
# author: Jesse Wei <jesse@cs.unc.edu>

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

# Not fully tested
if (! command -v pip &> /dev/null) && (! command -v pip3 &> /dev/null); then
    printf "You do not have pip installed (i.e., pip and pip3 commands don't work).
Please install Python 3.9+ (which will come with pip, and 3.9+ is required for COMP 311's SAPsim tool) and re-run this script.\n"
    echo "Exiting."
    exit 1
elif command -v pip &> /dev/null; then
    python -m pip install --upgrade pip
    pip install SAPsim
else
    python3 -m pip install --upgrade pip
    pip3 install SAPsim
fi

INSTALL_DIR=$HOME/.comp311
mkdir -p $INSTALL_DIR

DIGITAL=https://github.com/hneemann/Digital/releases/download/v0.30/Digital.zip
DIGITAL_ZIP="${DIGITAL##*/}"
# wget not pre-installed on macOS
# curl --output-dir is on a high version of cURL that may not be installed on user system
curl -OJL $DIGITAL
unzip $DIGITAL_ZIP
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
    printf "JAR files have been downloaded to $INSTALL_DIR.
    
However, this script cannot create aliases for the JAR files because your \$SHELL is not bash or zsh,
so I don't know what your shell's equivalent to .bashrc or .zshrc is.
You can alias the command yourself, if you'd like.
I assume that since you're not using bash nor zsh, you know how to do this.
Otherwise, the .jar has already been downloaded and can be run however you normally run a .jar file.\n"
    exit 1
fi

# Alias the commands
for kv in "${JARS[@]}" ; do
    COMMAND=${kv%%:*}
    JAR=${kv#*:}
    echo "alias $COMMAND=\"java -jar $JAR\"" >> "$SHELL_RC_FILE"
done

# Kinda want to alias this in user shell too...
# But would have to duplicate JARS variable there, so not doing that.
# Commands are listed in README (remember to update it)
help-comp311 () {
    for kv in "${JARS[@]}" ; do
        COMMAND=${kv%%:*}
        JAR=${kv#*:}
        printf "\tRun \`$COMMAND\` to launch $JAR\n"
    done
    printf "\tFor Digital, run \`digital file.dig\` to directly open file.dig on launch. However, this does not work for MARS.\n"
    printf "\tSAPsim was installed via pip. See https://github.com/jesse-wei/sapsim#usage for usage details.\n"
}

printf "JAR files have been downloaded to $INSTALL_DIR, and aliases for launching the JAR files have been created.\n\n"
echo "Run \`source $SHELL_RC_FILE\` to apply changes to your current shell session; otherwise, restart your terminal. Then,"
help-comp311
