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
