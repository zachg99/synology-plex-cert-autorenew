# Synology Plex Cert Autorenew
Script to automatically renew plex ssl certificate using the Synology LetsEncrypt certificate.

First, this script was originally created by [ryansully](https://gist.github.com/ryansully/) but he seems to have removed it and replaced it with one for Sickrage.  I tweaked it slightly to work with the Plex cert setup instructions from [Karsten Pearce](https://www.cascadingfalls.com/2017/06/using-lets-encrypt-for-plex-on-synology/).

If you have a LetsEncrypt SSL certificate setup on your Synology it autorenews every 3 months.  Whenever that certificate renews this will automatically update the certificate Plex is using.  Just set it up to run daily in the task scheduler.
