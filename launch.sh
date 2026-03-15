#!/bin/bash

set -x

if ! [[ -w "/data" ]]; then
  echo "Directory is not writable, check permissions for /mnt/user/appdata/"
  exit 66
fi

ID=130
VER=100212

cd /data

if ! [[ "$EULA" = "false" ]] || grep -i true eula.txt; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA by in the container settings."
	exit 9
fi

if ! [[ -f serverinstall_${ID}_${VER} ]]; then
  rm -f serverinstall_${ID}* forge-*.jar run.sh start.sh
  curl -Lo serverinstall_${ID}_${VER} https://api.feed-the-beast.com/v1/modpacks/public/modpack/${ID}/${VER}/server/linux
  chmod +x serverinstall_${ID}_${VER}
   ./serverinstall_${ID}_${VER} -dir /data -no-java -auto -force
fi

if [[ -n "$MOTD" ]]; then
    sed -i "/motd\s*=/ c motd=$MOTD" /data/server.properties
fi
if [[ -n "$LEVEL" ]]; then
    sed -i "/level-name\s*=/ c level-name=$LEVEL" /data/server.properties
fi
if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' > ops.txt
fi
if [[ -n "$ALLOWLIST" ]]; then
    echo $ALLOWLIST | awk -v RS=, '{print}' > white-list.txt
fi

sed -i 's/server-port.*/server-port=25565/g' server.properties

[[ -f run.sh ]] && chmod 755 run.sh
[[ -f start.sh ]] && chmod 755 start.sh
if [[ -f run.sh || -f start.sh ]]; then
  if [[ -f user_jvm_args.txt ]]; then
    echo $JVM_OPTS > user_jvm_args.txt
  fi
  [[ -f run.sh ]] && ./run.sh || ./start.sh
else
  rm -f forge-*-installer.jar
  FORGE_JAR=$(ls forge-*.jar)

  java -server -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Dfml.queryResult=confirm $JVM_OPTS -jar $FORGE_JAR nogui
fi