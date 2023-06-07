# /bin/bash -l
source ./main.sh

PREFIX='customer'

# get_stage_prompt

# git fetch --tags -f

STAGE=staging

if [[ "$PREFIX" ]]; then
  increment_build_number $PREFIX $STAGE
else
  increment_build_number '' $STAGE
fi
