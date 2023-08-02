#!bin/bash

#this script is for monitoring gitlab license using textfile collector node exporter

#define api url
json_data=$(curl --insecure --location 'http://your-gitlab-address/api/v4/license' --header 'PRIVATE-TOKEN: your-access-token')

#get user limit from api
user_limit=$(echo "$json_data" | jq -r '.user_limit')

#get active user from api
user_active=$(echo "$json_data" | jq -r '.active_users')

#calculate how much users are left
user_remaining=$((user_limit - user_active))

#get expired date from api
expired_date=$(echo "$json_data" | jq -r '.expires_at')

#convert expired date to unix timestamp format
target_timestamp=$(date -d "$expired_date" +%s)

#convert current date to unix timestamp format
current_timestamp=$(date +%s)

#calculate timestamp
time_difference=$((target_timestamp - current_timestamp))

#calculate timestamp (1 day = 86400 seconds)
days_difference=$((time_difference / 86400))

echo gitlab_expired_date{remaining_days=\"days\"} $days_difference

echo gitlab_user_limit{user_limit=\"limit\"} $user_limit

echo gitlab_user_active{user_active=\"active\"} $user_active

echo gitlab_user_remaining{user_remaining=\"remaining\"} $user_remaining

systemctl restart node_exporter.service