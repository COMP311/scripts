#!/usr/bin/env bash

INSTALL_DIR=$HOME/.comp311

DIGITAL=https://github.com/hneemann/Digital/releases/download/v0.30/Digital.zip
wget -P $INSTALL_DIR https://github.com/hneemann/Digital/releases/download/v0.30/Digital.zip
unzip $INSTALL_DIR/Digital.zip -d $INSTALL_DIR
mv $INSTALL_DIR/Digital/Digital.jar $INSTALL_DIR
rm -r $INSTALL_DIR/Digital
rm $INSTALL_DIR/Digital.zip

MARS=http://courses.missouristate.edu/kenvollmar/mars/MARS_4_5_Aug2014/Mars4_5.jar
wget -P $INSTALL_DIR http://courses.missouristate.edu/kenvollmar/mars/MARS_4_5_Aug2014/Mars4_5.jar

# A pretend Python dictionary with Bash 3 (pre-installed on macOS, and Bash 4 has native dictionaries)
# keys are names of software, values are local JAR files
JARS=(
    "digital:$INSTALL_DIR/Digital.jar"
    "mars:$INSTALL_DIR/Mars4_5.jar"
)

if ! command -v java &> /dev/null
then
    echo "You do not have Java installed. Would you like to install java $JAVA_VER now and proceed with installation? [y/n]"
    read install_java
    install_java_lower=$(echo "$install_java" | tr '[:upper:]' '[:lower:]')
    if [[ "$install_java_lower" = "y" ]]; then
        echo "Continuing installation"
        JAVA_VER="17.0.9-oracle"
        # Install Java (version $JAVA_VER) and set as default
        curl -s "https://get.sdkman.io" | bash
        source $HOME/.sdkman/bin/sdkman-init.sh
        # sdkman asks whether to set the installed java version
        # as default. Answer yes
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

# Determine name of shell rc file
# This script is always run via bash
# But $SHELL will be user's shell (e.g., /bin/zsh) even so
if [[ $SHELL = *"bash"* ]]; then
	SHELL_RC_FILE=$HOME/.bashrc
elif [[ $SHELL = *"zsh"* ]]; then
	SHELL_RC_FILE=$HOME/.zshrc
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
# Put the commands in the lab writeup instead.
help-comp311 () {
    for kv in "${JARS[@]}" ; do
        COMMAND=${kv%%:*}
        JAR=${kv#*:}
        printf "\tRun \`$COMMAND\` to launch $JAR\n"
    done
    printf "\tFor Digital, run \`digital file.dig\` to directly open file.dig on launch. However, this does not work for MARS.\n"
}

printf "JAR files have been downloaded to $INSTALL_DIR, and aliases for launching the JAR files have been created.\n\n"
echo "Run \`source $SHELL_RC_FILE\` to apply changes to your current shell session; otherwise, restart your terminal. Then,"
help-comp311
