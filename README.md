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
get_git_branch() {
    dependency.sh -d git || return $?;
    git rev-parse --abbrev-ref HEAD;
}
```
