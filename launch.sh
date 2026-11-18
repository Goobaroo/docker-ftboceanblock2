#!/bin/bash

set -x

if ! [[ -w "/data" ]]; then
  echo "Directory is not writable, check permissions for /mnt/user/appdata/"
  exit 66
fi

ID=128
VER=100597

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

# CVE-2026-114938 (Java4Shell): disable the Base64 intrinsic on susceptible CPUs
_j4s_flags="$( { grep -m1 '^flags' /proc/cpuinfo 2>/dev/null | cut -d: -f2-
                 sysctl -n machdep.cpu.features machdep.cpu.leaf7_features 2>/dev/null; } \
                 | tr '[:upper:]' '[:lower:]' | tr ' \t' '\n\n' )"
_j4s_hits=0
for _f in avx512f avx512bw avx512vbmi bmi2; do
  printf '%s\n' "$_j4s_flags" | grep -qx "$_f" && _j4s_hits=$((_j4s_hits + 1))
done
if [ "$_j4s_hits" -eq 4 ]; then
  case " ${JVM_OPTS:-} " in
    *" -XX:-UseBASE64Intrinsics "*) ;;
    *) JVM_OPTS="${JVM_OPTS:+$JVM_OPTS }-XX:-UseBASE64Intrinsics" ;;
  esac
fi
unset _j4s_flags _j4s_hits _f

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