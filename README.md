## Move all contents of Linux into the home directory and replace vscode by .vscode

## Install linux packages

bash /home/ubuntu/.local/bin/linux_software.sh

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
curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.0 /home/ubuntu/.pyenv/shims/python - --yes

poetry config virtualenvs.in-project true
```

## Git setup

git config --global init.defaultBranch main
git config --global user.name "Jaime Roquero"
git config --global user.email jaime.roquero@gmail.com

## SSH setup

ssh-keygen -t ed25519 -C "RGTechMain_GitHub"

Stored in ~/.ssh as id_ed25519 and id_ed25519.pub.
Upload id_ed25519.pub to Github, check with ssh -T git@github.com

## AWS setup

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --install-dir ~/.local/lib/ --bin-dir ~/.local/bin/
rm -r ./aws && rm awscliv2.zip

Need to generate from AWS both AWS Access Key ID and AWS Secret Access Key.

aws configure

Stored in ~/.aws/credentials

## SSL certificate for Jupyter notebooks

Create folder ~/ssl/

openssl req -x509 -noenc -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.pem

## VSCode setup

xargs -I {} code --install-extension {} < ~/.vscode/extensions.txt

## Create Cron jobs at startup

Edit the sudo crontab

sudo crontab -e

Add lines to the file:

@reboot /home/ubuntu/.local/bin/aws_mount_script.sh

@reboot /home/ubuntu/.local/bin/startup_script.sh
