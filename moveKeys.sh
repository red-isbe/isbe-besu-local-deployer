#!/bin/bash

# -----------------------------------------------------------------------------------
# Copyright (c) 2025 Comunidad de Madrid & Alastria
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------------

# Path to folders
KEYS_DIR="./networkFiles/keys"
NODO_BASE="Node"

# Node counter (starting in 1 → Node-1)
i=1
# sort the directories in KEYS_DIR and iterate through them
for address_dir in $(ls "$KEYS_DIR" | sort); do
  src="$KEYS_DIR/$address_dir"
  dest="$NODO_BASE-$i/data"

  if [[ -d "$src" && -d "$dest" ]]; then
    echo "Moving keys from $address_dir → $dest"
    cp "$src/key" "$dest/"
    cp "$src/key.pub" "$dest/"
  else
    echo "Folder unmatched: $src o $dest"
  fi

  i=$((i + 1))
done
