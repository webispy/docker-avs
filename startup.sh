#!/bin/bash

BANNER=$(cat << "EOF"
\033[1;30m---------------------------------------------------------- \033[0m
\033[1;36m1. set PULSEAUDIO server address.\033[0m

export PULSE_SERVER=172.17.0.1

\033[1;36m2. Change the clientId and productId in /opt/config.json to
  values corresponding to your AVS device registration.\033[0m

{
    "deviceInfo": {
        "clientId": "<your-client-id>",
        "productId": "<your-product-id>"
    }
}

\033[1;36m3. Generate AlexaClientSDKConfig.json using genConfig.sh tool\033[0m

cd /opt/tools
bash genConfig.sh /opt/config.json 12345 \ 
    /opt/avs/Integration/database /opt/src \ 
    /opt/avs/Integration/AlexaClientSDKConfig.json \ 
    -DSDK_CONFIG_MANUFACTURER_NAME="my_project" \ 
    -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu"

\033[1;36m4. Run the SampleApp\033[0m

cd /opt/avs
./SampleApp ./Integration/AlexaClientSDKConfig.json DEBUG9
\033[1;30m---------------------------------------------------------- \033[0m

EOF
)

echo -e "$BANNER"
echo

exec "$@"