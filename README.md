# Zebrunner Mcloud Redroid

Feel free to support the development with a [**donation**](https://www.paypal.com/donate?hosted_button_id=JLQ4U468TWQPS) for the next improvements.

<p align="center">
  <a href="https://zebrunner.com/"><img alt="Zebrunner" src="https://github.com/zebrunner/zebrunner/raw/master/docs/img/zebrunner_intro.png"></a>
</p>

## Usage
1. Setup your machine due to [redroid requirements](https://github.com/remote-android/redroid-doc) 
2. Clone [mcloud-redroid](https://github.com/zebrunner/mcloud-redroid) and setup:
   ```bash
   git clone https://github.com/zebrunner/mcloud-redroid.git && cd mcloud-redroid && ./zebrunner.sh setup
   ```
3. Provide actual data or use default values
4. Start services `./zebrunner.sh start`
   > For default settings visit [Demo Zebrunner STF](https://demo.zebrunner.farm/stf) to see your device. Login with `admin/changeit` credentials
5. Direct Appium url is `http://hostname:4723/wd/hub`
   > To control Redroid video and audio use [scrcpy](https://github.com/Genymobile/scrcpy)
   ```bash
   scrcpy --tcpip=hostanme:5555
   ```
6. [Optional] Setup your own [Zebrunner Device Farm](https://github.com/zebrunner/mcloud) for actual usage.

## Upgrade components
1. Save your settings (`*.env` files)
2. Shutdown your current Mcloud-Redroid instance:
   ```bash
   ./zebrunner.sh shutdown
   ```
3. Pull new repository version:
   ```bash
   git pull
   ```
4. Setup preferred Redroid version in  `.env.original` file:
   ```bash
   REDROID_VERSION=XX.X.X
   ```
5. Setup Redroid according to your previous configuration:
   ```bash
   ./zebrunner.sh setup
   ```

## Documentation and free support
* [Zebrunner PRO](https://zebrunner.com)
* [Zebrunner CE](https://zebrunner.github.io/community-edition)
* [Zebrunner Device Farm](https://github.com/zebrunner/mcloud)
* [Zebrunner Appium](https://github.com/zebrunner/appium)
* [Telegram Channel](https://t.me/zebrunner)
