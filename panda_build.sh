# /bin/bash -l
source ./main.sh

# env area
PREFIX=''
APP_NAME='carz customer'
# end env area

export LANG=en_US.UTF-8

check_tag_format

get_message_information

is_cleanup

remove_all_tag