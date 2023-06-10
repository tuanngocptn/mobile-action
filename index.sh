panda_health_check() {
  echo "Panda is Ok"
}
get_funny_idiom() {
  RANDOM_FUNNY_IDIOMS_GIST_URL=https://gist.githubusercontent.com/tuanngocptn/9fabb1979e5b29eca84bce28c6b8d080/raw/random-idioms-vi.sh
  RESULT="$(bash -c "$(curl -fsSL ${RANDOM_FUNNY_IDIOMS_GIST_URL})")"
  echo $RESULT
}

get_message_information() {
  TAG_SOURCE=$GITHUB_REF_NAME || $(git describe --tags)
  AUTHOR=$(git show -s --format='%an')
  VERSION=($(grep -oE '[a-z]{3,4}|[0-9]{1,3}' <<<"$TAG_NAME"))
  VERSION_APPNAME="${VERSION[0]}-${VERSION[1]}"
  VERSION_ENV=$(split_version $TAG_SOURCE environment)
  VERSION_MAJOR=$(split_version $TAG_SOURCE major)
  VERSION_MINOR=$(split_version $TAG_SOURCE minor)
  VERSION_PATCHE=$(split_version $TAG_SOURCE patche)
  VERSION_BUILD_NUMBER=$(split_version $TAG_SOURCE build)
  VERSION_FULL=$(split_version $TAG_SOURCE full)
  TAG_SOURCE="${VERSION_APPNAME}-${VERSION_ENV}-$VERSION_FULL+$VERSION_BUILD_NUMBER"
  MESSAGE_INFO="\n- App: Carz Merchant.\n- Môi trường: $VERSION_ENV.\n- Phiên bản: $VERSION_FULL.\n- Bản build số: $VERSION_BUILD_NUMBER.\n- Thằng bấm nút: ${AUTHOR}."
  echo $MESSAGE_INFO
}
send_telegram() {
  DATA_PUSH=''
  if [ "${2}" ]; then
    if [ "${3}" ]; then
      DATA_PUSH='{
        "chat_id": "'"$1"'",
        "reply_to_message_id": "'"$2"'",
        "text": "'"$3"'"
      }'
    else
      DATA_PUSH='{
        "chat_id": "'"$1"'",
        "text": "'"$2"'"
      }'
    fi
    send_telegram_normal $DATA_PUSH
  else
    send_telegram_liberty $1
  fi
}

send_telegram_normal() {
  curl --location "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    --header 'Content-Type: application/json' \
    --data $1
}

send_telegram_liberty() {
  curl --location "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    --header 'Content-Type: application/json' \
    --data '{
      "chat_id": -1001837632261,
      "reply_to_message_id": 196,
      "text": "'"$1"'"
  }'
}

send_slack() {
  curl --location "https://hooks.slack.com/services/$SLACK_BOT_SERVICE_ID" \
    --header 'Content-Type: application/json' \
    --data '{"text":"'"$1"'"}'
}
get_stage_prompt() {
  title="Chon moi truong build:"
  prompt="Lua chon:"
  options=("Development" "Staging" "Production")

  echo "$title"
  PS3="$prompt "
  STAGE=""
  select opt in "${options[@]}" "Thoat"; do
    case "$REPLY" in
    1) echo "Lua chon build $opt" && STAGE="development" && break ;;
    2) echo "Lua chon build $opt" && STAGE="staging" && break ;;
    3) echo "Lua chon build $opt" && STAGE="production" && break ;;
    $((${#options[@]} + 1)))
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Sai lua chon. chon lai."
      continue
      ;;
    esac
  done
}
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
split_version() {
  TAG_NAME=$1
  VERSION_TYPE=$2 # full, all, major, minor, patche, increment_patche, build, increment_build

  VERSION_NAME_PATH=($(grep -oE '[a-z,0-9,-.+]*' <<<"$TAG_NAME"))
  ARRAY_SIZE=${#VERSION_NAME_PATH[@]}
  VERSION=${VERSION_NAME_PATH[$((ARRAY_SIZE - 1))]}
  ENVIRONMENT=${VERSION_NAME_PATH[$((ARRAY_SIZE - 2))]}
  VERSION_ARRAY=($(grep -oE '[0-9]*' <<<"$VERSION"))

  case $VERSION_TYPE in
  all)
    echo ${VERSION}
    ;;
  full)
    echo "${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${VERSION_ARRAY[2]}"
    ;;
  increment_patche)
    PATCHE_WILL_BUILD=$((VERSION_ARRAY[2] + 1))
    echo "${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${PATCHE_WILL_BUILD}"
    ;;
  major)
    echo ${VERSION_ARRAY[0]}
    ;;
  minor)
    echo ${VERSION_ARRAY[1]}
    ;;
  patche)
    echo ${VERSION_ARRAY[2]}
    ;;
  build)
    echo ${VERSION_ARRAY[3]}
    ;;
  increment_build)
    echo ${VERSION_ARRAY[3]} + 1 | bc
    ;;
  environment)
    echo ${ENVIRONMENT}
    ;;
  esac
}

increment_build_number() {
  STAGE=$2
  if [[ ! "$STAGE" ]]; then
    exit "Missing STAGE environment"
  fi
  PREFIX=''
  if [[ "$1" ]]; then
    PREFIX="$1/"
  fi
  PRO_TAG=$(git tag --sort=-version:refname -l "${PREFIX}production/*" | head -n 1)

  NEW_TAG=''

  if [[ "$STAGE" == "production" ]]; then
    PRO_TAG_FULL=$(split_version $PRO_TAG full)
    PRO_BUILD_NUMBER=$(split_version $PRO_TAG build)
    PRO_BUILD_NUMBER_INCREMENT=$((PRO_BUILD_NUMBER + 1))
    NEW_TAG="${PREFIX}production/v${PRO_TAG_FULL}+${PRO_BUILD_NUMBER_INCREMENT}"
  else
    STAGE_TAG=$(git tag --sort=-version:refname -l "${PREFIX}${STAGE}/*" | head -n 1)
    STAGE_TAG_FULL=$(split_version $PRO_TAG increment_patche)
    STAGE_TAG_LATEST=$(git tag --sort=-version:refname -l "${PREFIX}${STAGE}/v${STAGE_TAG_FULL}+*" | head -n 1)
    STAGE_BUILD_NUMBER=1
    if [[ $STAGE_TAG_LATEST ]]; then
      STAGE_BUILD_NUMBER=$(split_version $STAGE_TAG_LATEST increment_build)
    fi
    NEW_TAG="${PREFIX}${STAGE}/v${STAGE_TAG_FULL}+${STAGE_BUILD_NUMBER}"
  fi
  create_tag $NEW_TAG
}
