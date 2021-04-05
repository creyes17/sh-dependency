# sh-dependency
Support library for installing missing shell script dependencies

# Installation
Clone the repository and add the included `dependency.sh` to your path. For example:
```bash
gh repo clone creyes17/sh-dependency;  # Using the GitHub CLI
mkdir -p $HOME/bin && ln -s sh-dependency/dependency.sh $HOME/bin/dependency.sh;
[ command -v dependency.sh >/dev/null ] || echo 'export PATH="\$HOME/bin:$PATH";' >> ~/.bashrc  # If $HOME/bin isn't already in your PATH
```

# Usage
```bash
# For example, if you're making a new function or script and
# you want to make sure all of the dependencies are present,
# you can call dependency.sh at the start to let users know.
get_git_branch() {
    dependency.sh -d git || return $?;
    git rev-parse --abbrev-ref HEAD;
}

# You could also add an argument to your script to optionally
# try to install any missing dependencies.
get_git_branch_install() {
    local shouldInstall;
    shouldInstall="$1";
    if [ -z "$shouldInstall" ]; then
        dependency.sh -d git || return $?;
    else
        # Tries to install git if it's not already installed.
        dependency.sh -d git -i || return $?;
    fi
    
    git rev-parse --abbrev-ref HEAD;
}
```
