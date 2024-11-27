poetry config virtualenvs.in-project true
poetry install --no-root
poetry shell

git push --set-upstream origin main
