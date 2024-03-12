#!/usr/bin/env bash
set -euo pipefail

install() {
  echo Hello World
  #!/bin/bash

  # Start
  echo "Starting"
  echo "Starting deployment operations..."

  # Check if file exists
  filepath="/cnab/app/bin/release/net7.0/ubuntu.16.04-x64"
  if [ ! -d "$filepath" ]; then
      echo "File does not exist"
      exit 1
  fi

  echo "File exists"

  # Load action configuration
  # Assuming the action configuration is stored in a YAML file
  action=$(cat /cnab/app/action.yaml)

  echo $action
  type=$(echo "$action" | sed -n 's/.*Type: "\(.*\)".*/\1/p')
  echo $type
  displayName=$(echo "$action" | sed -n 's/.*DisplayName: "\(.*\)".*/\1/p')
  echo $displayName
  description=$(echo "$action" | sed -n 's/.*Description: "\(.*\)".*/\1/p')
  echo $description
  capacityId=$(echo "$action" | sed -n 's/.*CapacityId: "\(.*\)".*/\1/p')
  echo $capacityId
  token=$(echo "$action" | sed -n 's/.*Token: "\(.*\)".*/\1/p')
  echo $token

  # Construct the command based on action type
  if [ "$type" = "Workspace" ] || [ -z "$type" ]; then
      # Construct payload for Workspace type
      payload='{"displayName":"'$displayName'","description":"'$description'","capacityId":"'$capacityId'"}'
      cmd="$filepath/Microsoft.Fabric.Provisioning.Client create --token $token --payload '$payload'"
      echo $cmd
  else
      # Construct payload for other types
      payload='{"displayName":"'${action["Steps"][0]["DisplayName"]}'","type":"'${action["Steps"][0]["Type"]}'","description":"'${action["Steps"][0]["Description"]}'","workspaceId":"'${action["Steps"][0]["WorkspaceId"]}'"}'
      cmd="$filepath/Microsoft.Fabric.Provisioning.Client createItem --token ${action["Steps"][0]["Token"]} --payload '$payload'"
  fi

  
# Construct the command based on action type
# if [ "$type" = "Workspace" ] || [ -z "$type" ]; then
#     # Construct payload for Workspace type
#     payload=$(echo "$action" | grep -o 'DisplayName:.*' | awk '{print "{\"displayName\":\""$2"\",\"description\":\""$4"\",\"capacityId\":\""$6"\"}"}')
#     cmd="$filepath/Microsoft.Fabric.Provisioning.Client create --token $(echo "$action" | grep -o 'Token:.*' | awk '{print $2}') --payload '$payload'"
# else
#     # Construct payload for other types
#     payload=$(echo "$action" | grep -o 'DisplayName:.*' | awk '{print "{\"displayName\":\""$2"\",\"type\":\""$4"\",\"description\":\""$6"\",\"workspaceId\":\""$8"\"}"}')
#     cmd="$filepath/Microsoft.Fabric.Provisioning.Client createItem --token $(echo "$action" | grep -o 'Token:.*' | awk '{print $2}') --payload '$payload'"
# fi

  echo "Executing command: $cmd"
  output=$(eval "$cmd")
  if [ $? -ne 0 ]; then
      echo "Error executing command: $cmd"
      exit 1
  fi

  echo "$output"  # Output from the command

}

upgrade() {
  echo World 2.0
}

uninstall() {
  echo Goodbye World
}

view() {
  echo View 
}

# Call the requested function and pass the arguments as-is
"$@"
