# cPanel-TestEnvs-AutoConfig
Automate IP address and DNS updates for cPanel/WHM in a test environment context.

Ordinarily, it would be necessary to run through a number of steps in the WHM interface to complete setup (since the IP address and various other details are set on install); this script removes the need for that.

Designed for usage with instances built from images/snapshots in OpenStack, though workable in any situation so long as the hypervisor / orchestration management platform handles NIC configuration automatically.

## Setup

1. Add `setup_testenv.sh` to a directory of your choosing (`/root` works fine)
2. Add `setup_testenv.service` to `/etc/systemd/system`, and ensure that the path to the script is correct in the `[Service]` section.
3. Run `systemctl enable setup_testenv.service` to make the script run on boot

Then create an image in OpenStack, and any new instances created from that image will be ready to go!

## Troubleshooting

If you encounter any problems (e.g. IP addresses for accounts have not been updated), make sure to check `/root/setup.log`. This contains the output (and errors, if applicable) of all commands executed by the script.

You can always manually run `./root/setup_testenv.sh` if you need to!
