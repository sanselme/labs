#!/bin/bash

# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
set -e

DEFAULT_EXTENSION_LIST=(
  "aaron-bond.better-comments"
  "bierner.github-markdown-preview"
  "christian-kohler.path-intellisense"
  "codezombiech.gitignore"
  "eamodio.gitlens"
  "esbenp.prettier-vscode"
  "formulahendry.code-runner"
  "GitHub.copilot"
  "hbenl.vscode-test-explorer"
  "jerrygoyal.shortcut-menu-bar"
  "minherz.copyright-inserter"
  "ms-vscode.hexeditor"
  "ms-vscode.test-adapter-converter"
  "ms-vscode.vscode-serial-monitor"
  "patbenatar.advanced-new-file"
  "redhat.vscode-yaml"
  "shd101wyy.markdown-preview-enhanced"
  "trunk.io"
  "vscode-icons-team.vscode-icons"
  "wayou.vscode-todo-highlight"
)

# Install extensions execpt tunk.io for windows
for extension in "${DEFAULT_EXTENSION_LIST[@]}"; do
  if [[ "${OSTYPE}" == "msys" && "${extension}" == "trunk.io" ]]; then
    continue
  fi

  code --install-extension "${extension}"
done
