# create_tag() {
#   TAG_NAME=$1
#   echo "New release for $TAG_NAME at $(date '+%d/%m/%Y %H:%M:%S')" >>release.txt
#   CURRENT_BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
#   HEAD_HASH="$(git rev-parse --short HEAD)"
#   {
#     git add release.txt &&
#       git commit -m "LC-0/build: Release $TAG_NAME" &&
#       git push origin $CURRENT_BRANCH &&
#       git tag -a $TAG_NAME -m "New release for $TAG_NAME" &&
#       git push origin $TAG_NAME
#   } || {
#     git reset --soft $HEAD_HASH
#     git checkout $HEAD_HASH release.txt
#   }
# }

create_tag() {
  TAG_NAME=$1
  {
    git tag -a $TAG_NAME -m "New release for $TAG_NAME" &&
      git push origin $TAG_NAME
  } || {
    git tag -d $TAG_NAME
  }
}

init_version_tag() {
  PREFIX=''
  if [ "${1}" ]; then
    PREFIX="$1/"
  fi
  create_tag "${PREFIX}development/v1.0.1+0"
  create_tag "${PREFIX}staging/v1.0.1+0"
  create_tag "${PREFIX}production/v1.0.0+0"
}

delete_tag() {
  git tag -d "$1"
  git push --delete origin "$1"
}

check_tag_format() {
  git fetch
  TAG_SOURCE=$GITHUB_REF_NAME || $(git describe --tags)
  REGEX_MATCH_TAGS_BUILD="(development|staging|production)\/((v|\.|\+)[0-9]*){4}"
  if [ "${PREFIX}" ]; then
    REGEX_MATCH_TAGS_BUILD="^.*${PREFIX}\/${REGEX_MATCH_TAGS_BUILD}$"
  else
    REGEX_MATCH_TAGS_BUILD="^.*${REGEX_MATCH_TAGS_BUILD}$"
  fi
  if [[ "$TAG_SOURCE" =~ $REGEX_MATCH_TAGS_BUILD ]]; then
    echo "INFO: Tag name '$TAG_SOURCE' is the right format tag name for building the new version."
  else
    exit "ERROR: Tag name '$TAG_SOURCE' is NOT the right format tag name for building the new version."
  fi
}

remove_all_tag() {
  git fetch
  git push origin --delete $(git tag -l)
  git tag -d $(git tag -l)
}
