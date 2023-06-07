is_cleanup() {
  git tag -l -n "*merc-carz-dev-*" -n "merc-*carz-pro-*" -n "merc-*carz-stg-*" --sort=creatordate --format "%(refname:short)" | tail -2
  TAG_NAME_TAIL_2=$(git tag -l -n "*merc-carz-dev-*" -n "merc-*carz-pro-*" -n "merc-*carz-stg-*" --sort=creatordate --format "%(refname:short)" | tail -2)
  TAG_NAME_TAIL_2=(${TAG_NAME_TAIL_2//\n/ })

  FILE_CHANGE=$(git diff ${TAG_NAME_TAIL_2[0]} ${TAG_NAME_TAIL_2[1]} --stat --name-only)
  IS_CLEAN=false
  if [[ "$FILE_CHANGE" == *"package.json"* || "$FILE_CHANGE" == *"Podfile"* ]]; then
    IS_CLEAN=true
  fi
}
