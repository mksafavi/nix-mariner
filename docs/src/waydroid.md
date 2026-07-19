# Android emulation (Waydroid)

You can run Android inside a microVM via [Waydroid](https://waydro.id/).
Enabling Waydroid enables graphics support it needs for rendering the Android UI window.


```nix
{{#include ../../examples/android.nix}}
```

## Storage
Android `/data`(installed apps, their data, internal storage) is on the user's `$HOME` on the persist volume.
Increase the persist volume size if you need more storage space inside Android.

## Viewing Android UI
Waydroid is running inside the VM and [waypipe](https://gitlab.freedesktop.org/mstoeckl/waypipe) proxies the UI window to your host.

### Guest

On the guest, `waydroid-init.service` initializes Waydroid and downloads the selected image on the first start.
After that `waydroid-session-start.service` starts Waydroid session inside a `waypipe` server.
Both steps run automatically on boot, so you don't need to touch anything.

For troubleshooting, check the service logs:
```shell
journalctl -u waydroid-init
journalctl -u waydroid-session-start
sudo waydroid log
```

### Host
The waypipe client service is enabled when you import mariner's host module, and starts automatically with your graphical session:
```shell
systemctl status --user mariner-waypipe-client.service
```
If your compositor doesn't manage a systemd graphical session, activate `graphical-session.target` or start the client manually.
```shell
waypipe --vsock -s 6000 client
```

And then:

```shell
ssh vm@<addr> waydroid show-full-ui
```

## Network access on first boot
By default Waydroid downloads the Android system and vendor images on first initialization.
After that the images persist on the waydroid volume and waydroid can start offline.
You can also manually copy your images to `/etc/waydroid-extra/images` which will override the downloaded images.

## Known limitations

- No audio: Audio is not configured yet
- Blank window flashes: When the Waydroid session is starting you might see blank windows opening for a split second, mostly a cosmetic issue.
- Turning off or Restarting Waydroid doesn't restart the session. you need to manually restart `waydroid-session-start.service`
- Android network is not reachable from LAN/host.
- Manual images directory is not persisted on the waydroid volume yet.
