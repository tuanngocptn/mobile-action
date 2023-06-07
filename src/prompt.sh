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
