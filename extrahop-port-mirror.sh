VM_ID=$1;
EXECUTION_PHASE=$2
SOURCE_PORT="enp1s0";
VM_BRIDGE="vmbr1";
LOGGING=/var/log/scripts/extrahop-port-mirror.log;

function create_mirror {

  /usr/bin/date >> $LOGGING;

  /usr/bin/echo "Creating mirror on $VM_BRIDGE for $VM_ID"... >> $LOGGING;

  /usr/bin/ovs-vsctl \
    -- --id=@"$SOURCE_PORT" get Port "$SOURCE_PORT" \
    -- --id=@tap"$VM_ID"i1 get Port tap"$VM_ID"i1 \
    -- --id=@"$VM_ID"m create \
           Mirror name="$VM_ID"-mirror \
           select-dst-port=@"$SOURCE_PORT" \
           select-src-port=@"$SOURCE_PORT" \
           output-port=@tap"$VM_ID"i1 \
    -- add Bridge "$VM_BRIDGE" mirrors @"$VM_ID"m; >> $LOGGING;

  /usr/bin/echo "####################" >> $LOGGING;

}

function clear_mirror {

   /usr/bin/date >> $LOGGING;

  /usr/bin/echo "Clearing mirror on $VM_BRIDGE for $VM_ID..." >> $LOGGING;

  /usr/bin/ovs-vsctl \
    -- --id=@"$VM_ID"m get Mirror "$VM_ID"-mirror \
    -- remove Bridge "$VM_BRIDGE" mirrors @"$VM_ID"m; >> $LOGGGING;

  /usr/bin/echo "####################" >> $LOGGING;

}

function show_mirrors {

  /usr/bin/date >> $LOGGING;

  /usr/bin/echo "Show existing mirrors..." >> $LOGGING;

  /usr/bin/ovs-vsctl list Mirror >> $LOGGING;

  /usr/bin/echo "####################" >> $LOGGING;

}

if [[ "$EXECUTION_PHASE" == "post-start" ]]; then

  clear_mirror;

  create_mirror;

  show_mirrors;

elif [[ "$EXECUTION_PHASE" == "pre-stop" ]]; then

  clear_mirror;

  show_mirrors;

fi
