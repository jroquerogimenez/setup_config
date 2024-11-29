## Move all contents of Linux into the home directory and replace vscode by .vscode

mv $HOME/setup_config/Linux/* $HOME/
mv $HOME/vscode $HOME/.vscode

sudo bash $HOME/.local/bin/home_mount_startup.sh
sudo bash $HOME/.local/bin/setup_services_startup.sh

## Install linux packages

sudo bash $HOME/.local/bin/linux_software_startup.sh

## Install pyenv

First install pyenv

```
curl https://pyenv.run | bash
```

Then start a new shell and install python

```
pyenv install 3.12.7
pyenv global 3.12.7
```

## Install poetry

```
curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.0 $HOME/.pyenv/shims/python - --yes

poetry config virtualenvs.in-project true
```

## Git setup

git config --global init.defaultBranch main
git config --global user.name "Jaime Roquero"
git config --global user.email jaime.roquero@gmail.com

## SSH setup

ssh-keygen -t ed25519 -C "RGTechMain_GitHub"

Stored in $HOME/.ssh as id_ed25519 and id_ed25519.pub.
Upload id_ed25519.pub to Github, check with ssh -T git@github.com

## AWS setup

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --install-dir $HOME/.local/lib/ --bin-dir $HOME/.local/bin/
rm -r ./aws && rm awscliv2.zip

Need to generate from AWS both AWS Access Key ID and AWS Secret Access Key.

aws configure

Stored in $HOME/.aws/credentials

## Prepare mount point for AWS S3

sudo mkdir -p /data
sudo chown -R $USER /data

## SSL certificate for Jupyter notebooks

openssl req -x509 -noenc -days 365 -newkey rsa:2048 -keyout $HOME/.ssl/mykey.key -out $HOME/.ssl/mycert.pem -config $HOME/.ssl/openssl.cnf

## VSCode setup

xargs -I {} code --install-extension {} < $HOME/.vscode/extensions.txt
