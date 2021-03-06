set -e

# check if MongoDB is bound via linking
if ! [[ -z ${MONGO_NAME+x} ]]; then
  # resolve name from /etc/hosts
  MONGO_IP_ADDR=$(gethostip -d mongo)
  # override MONGO_URL with the url from the linked container
  export MONGO_URL=mongodb://$MONGO_IP_ADDR:$DB_PORT/$DB_NAME
  # if user wants to use oplog, defined the corresponding variable
  if ! [[ -z ${OPLOG_DB_NAME+x} ]]; then
    export MONGO_OPLOG_URL=mongodb://$MONGO_IP_ADDR:$DB_PORT/$OPLOG_DB_NAME
  fi
fi

if [ -d /bundle ]; then
  cd /bundle
  tar xzf *.tar.gz
  cd /bundle/bundle/programs/server/
  npm i
  cd /bundle/bundle/
elif [[ $BUNDLE_URL ]]; then
  cd /tmp
  wget $BUNDLE_URL -O bundle.tar.gz
  tar xzf bundle.tar.gz
  cd /tmp/bundle/programs/server/
  npm i
  cd /tmp/bundle/
else
  cd /built_app
fi

if [[ $REBULD_NPM_MODULES ]]; then
  cd programs/server
  bash /opt/meteord/rebuild_npm_modules.sh
  cd ../../
fi

export PORT=80
echo "starting meteor app on port:$PORT"
node main.js
