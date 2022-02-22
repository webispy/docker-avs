# docker-avs

Docker image for the avs-device-sdk SampleApp runtime environment.

## Requirements

* Network enabled PulseAudio server.
  * e.g. `/etc/pulse/default.pa` configuration file.
    ```sh
    ...
    load-module module-native-protocol-tcp auth-ip-acl=172.17.0.0/24;127.0.0.1;192.168.0.0/16
    ...
    ```

## Usage

1. Create and start the docker container

    ```sh
    docker run -it webispy/avs
    ```

2. set the PulseAudio server address.

    ```sh
    export PULSE_SERVER=172.17.0.1
    ```

3. Change the clientId and productId in /opt/config.json to values corresponding to your AVS device registration.

    ```json
    {
        "deviceInfo": {
            "clientId": "<your-client-id>",
            "productId": "<your-product-id>"
        }
    }
    ```

4. Generate AlexaClientSDKConfig.json using genConfig.sh tool

    ```sh
    cd /opt/tools
    bash genConfig.sh /opt/config.json 12345 \
        /opt/avs/Integration/database /opt/src \
        /opt/avs/Integration/AlexaClientSDKConfig.json \
        -DSDK_CONFIG_MANUFACTURER_NAME="my_project" \
        -DSDK_CONFIG_DEVICE_DESCRIPTION="ubuntu"
    ```

5. Run the SampleApp

    ```sh
    cd /opt/avs
    ./SampleApp ./Integration/AlexaClientSDKConfig.json DEBUG9

    # or run without debug message

    ./SampleApp ./Integration/AlexaClientSDKConfig.json
    ```
