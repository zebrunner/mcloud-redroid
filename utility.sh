#!/bin/bash

export_settings() {
  export -p | grep "ZBR" > backup/settings.env
}

echo_warning() {
    echo "
      WARNING! $1"
}

echo_telegram() {
    echo "
      For more help join telegram channel: https://t.me/zebrunner
      "
}

replace() {
    #TODO: https://github.com/zebrunner/zebrunner/issues/328 organize debug logging for setup/replace
    file=$1
    #echo "file: $file"
    content=$(<"$file") # read the file's content into
    #echo "content: $content"

    old=$2
    #echo "old: $old"

    new=$3
    #echo "new: $new"

    # replace ${old} followed by any characters except end-of-line with ${new}
    # '#' - char used as delimiter to exclude cases with slashes
    content=$(echo "$content" | sed "s#${old}[^$]*#${new}#")

    #echo "content: $content"

    printf '%s' "$content" >"$file"    # write new content to disk
}

confirm() {
    local message=$1
    local question=$2
    local isEnabled=$3

    if [[ "$isEnabled" == "1" ]]; then
      isEnabled="y"
    fi
    if [[ "$isEnabled" == "0" ]]; then
      isEnabled="n"
    fi

    while true; do
      if [[ ! -z $message ]]; then
        echo "$message"
      fi

      read -r -p "$question y/n [$isEnabled]:" response
      if [[ -z $response ]]; then
        if [[ "$isEnabled" == "y" ]]; then
          return 1
        fi
        if [[ "$isEnabled" == "n" ]]; then
          return 0
        fi
      fi

      if [[ "$response" == "y" || "$response" == "Y" ]]; then
        return 1
      fi

      if [[ "$response" == "n" ||  "$response" == "N" ]]; then
        return 0
      fi

      echo "Please answer y (yes) or n (no)."
      echo
    done
}
