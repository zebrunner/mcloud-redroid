# Zebrunner Mcloud Redroid

Feel free to support the development with a [**donation**](https://www.paypal.com/donate?hosted_button_id=JLQ4U468TWQPS) for the next improvements.

<p align="center">
  <a href="https://zebrunner.com/"><img alt="Zebrunner" src="https://github.com/zebrunner/zebrunner/raw/master/docs/img/zebrunner_intro.png"></a>
</p>

## Usage
1. Setup your machine due to [redroid requirements](https://github.com/remote-android/redroid-doc) 
2. Clone [mcloud-redroid](https://github.com/zebrunner/mcloud-redroid) and setup:
   ```
   git clone https://github.com/zebrunner/mcloud-redroid.git && cd mcloud-redroid && ./zebrunner.sh setup
   ```
3. Provide actual data or use default values
4. Start services `./zebrunner.sh start`
   > For default settings visit [Demo Zebrunner STF](https://demo.zebrunner.farm/stf) to see your device. Login with `admin/changeit` credentials
6. Direct Appium url is `http://hostname:4723/wd/hub`
   > To control Redroid video and audio use [scrcpy](https://github.com/Genymobile/scrcpy)
   ```
   scrcpy --tcpip=hostanme:5555
   ```
7. [Optional] Setup your own [Zebrunner Device Farm](https://github.com/zebrunner/mcloud) for actual usage.

## Update components
1. Pull a new version of the image you want to update:
   ```
   docker pull <image_name>:<image_version>
   ```
2. Change updated component version in `.env` file
3. Setup and restart
   ```
   ./zebrunner.sh setup
   ./zebrunner.sh restart
   ```

## Documentation and free support
* [Zebrunner PRO](https://zebrunner.com)
* [Zebrunner CE](https://zebrunner.github.io/community-edition)
* [Zebrunner Device Farm](https://github.com/zebrunner/mcloud)
* [Zebrunner Appium](https://github.com/zebrunner/appium)
* [Telegram Channel](https://t.me/zebrunner)
