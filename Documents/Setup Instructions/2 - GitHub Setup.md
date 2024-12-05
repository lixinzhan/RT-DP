<h3>GitHub/Git Setup</h3>

  ```
  # RHEL
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install gh
  ```

  ```
  # Ubuntu/Debian
  wget https://cli.github.com/packages/githubcli-archive-keyring.gpg
  sudo cp githubcli-archive-keyring.gpg /etc/apt/keyrings/
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh
  ```

  ```
  gh auth login
  gh repo clone <repo>
  git mv <oldname> <newname>
  git add <newlymodified files>
  git commit -a
  git push
  git pull
  git restore <removed file>
  ```

  ```
  # Set global preferences
  git config --global user.email "me@email.org"
  git config --global user.name "First Last"
  git config --global core.editor "vim"
  ```
