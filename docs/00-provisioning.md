# Chapter 00 — Provisioning the Pi

From a bare Raspberry Pi 5 to a hardened, headless host you can SSH into, with a
data disk mounted and a firewall up. No game software yet. Just a clean machine
that is ready to have one built on it.

## What this is

Everything before AzerothCore. You will:

- flash **Ubuntu Server (ARM64)** to the microSD,
- configure the machine **before its first boot** so it comes up headless (no
  monitor, no keyboard) with SSH already working,
- attach and mount the **NVMe** as a data disk,
- give it a **static IP**,
- turn on a **firewall**,
- bring the OS **fully up to date**,
- and take a **baseline image** so you can reset to this exact state later.

## Why it matters

This is the foundation every later chapter stands on. Two decisions here save you
real pain:

- **The OS lives on the microSD; the NVMe is data only.** We do not boot from NVMe.
  On a Pi 5 with a third-party M.2 HAT, NVMe boot is fragile and can hard-hang the
  bootloader with no SD fallback. Booting from SD and using the NVMe purely for data
  sidesteps that entire class of problem. (See Troubleshooting if you want the gory
  detail of why.)
- **We provision headless from the start.** The Pi never needs a monitor. This is how
  a server should be run, and it means the whole process is reproducible from your
  desktop.

## Before you start

- A Raspberry Pi 5 (this guide used the 16 GB model).
- A microSD card (64 GB here) for the OS.
- An NVMe SSD on an M.2 HAT for data. **Confirm it is an NVMe drive** — one notch in
  the gold edge connector (M-key). A two-notch (B+M key) stick is SATA and will
  **never** work in an NVMe HAT. This bit us; see Troubleshooting.
- The official Raspberry Pi 5 power supply (27 W / 5 A), or PoE. Under-powering a Pi
  with an NVMe HAT causes intermittent, maddening failures.
- On your desktop: [Raspberry Pi Imager](https://www.raspberrypi.com/software/), and
  the ability to generate an SSH key.

This guide's host is named **`tpgaming01`** at **`192.168.1.220`**. Substitute your
own names and addresses throughout.

---

## Steps

### 1. Generate an SSH key for this machine

Do this **on your desktop**. We use key-only login and never a password, so the key
must exist before we provision.

```
desktop $ ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_tpgaming -C "you@tpgaming01"
```

- `-t ed25519` — a modern, short, strong key type.
- `-f …` — writes `id_ed25519_tpgaming` (private) and `id_ed25519_tpgaming.pub`
  (public) so this key does not collide with your other keys.
- Set a passphrase when prompted. This encrypts the private key on disk.

The file **without** `.pub` is the private key; the one **with** `.pub` is public. You
give `-i` the private key; the public one goes onto the Pi in the next step.

### 2. Flash Ubuntu Server (ARM64) to the microSD

In Raspberry Pi Imager: choose **Raspberry Pi 5**, then
**Other general-purpose OS → Ubuntu → Ubuntu Server 24.04 LTS (64-bit)**, then your
microSD, and write.

> **Get the edition right.** It must be **Server**, not **Desktop**. Desktop pulls in
> a GUI you will never use and wastes the card. If you are unsure which you flashed,
> after it boots check `dpkg -l | grep -E 'ubuntu-desktop|gdm3'` — Server returns
> nothing.

> **Imager "customisation" is greyed out on Ubuntu images.** That is expected — the
> customisation dialog is Raspberry Pi OS only. Ubuntu is configured a different way,
> which is the next step. Do **not** go hunting for it; see Troubleshooting.

### 3. Headless setup with cloud-init

Ubuntu on the Pi reads a file called **`user-data`** on the boot partition at first
boot and configures itself from it. This is how we set the hostname, create our user,
install our SSH key, and lock down logins — all before the machine has ever been
turned on.

Re-insert the freshly flashed card into your desktop. It mounts a small FAT partition
labelled **`system-boot`**. Replace the `user-data` file there with this, adjusting
the username, hostname, and **your public key**:

```yaml
#cloud-config
hostname: tpgaming01
manage_etc_hosts: true
timezone: America/New_York
locale: en_US.UTF-8
users:
  - name: tphome
    groups: [adm, sudo]
    shell: /bin/bash
    lock_passwd: true
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - ssh-ed25519 AAAA...your-public-key... you@tpgaming01
ssh_pwauth: false
disable_root: true
packages:
  - avahi-daemon
final_message: "tpgaming01 is up after $UPTIME seconds. cloud-init done."
```

What each part buys you:

- `ssh_authorized_keys` — your public key (`cat ~/.ssh/id_ed25519_tpgaming.pub`) goes
  here. This is the only way in.
- `ssh_pwauth: false` + `disable_root: true` — no password logins, no root logins.
- `lock_passwd: true` — the user has no password at all; sudo is passwordless from the
  key-authenticated session.
- **We deliberately leave DHCP on** at this stage. A wrong static IP on a headless box
  you cannot see is unrecoverable without pulling the card. We set the static address
  later, from inside a working SSH session, where a mistake is fixable.

A redacted copy of this file lives at
[`assets/cloud-init/user-data.example`](../assets/cloud-init/user-data.example).

Eject the card cleanly, put it in the Pi, connect ethernet, and power on.

### 4. First boot and first SSH

Give it 3–5 minutes on the first boot — cloud-init runs, installs `avahi-daemon`, and
reboots. Find the address it took from your router's DHCP/client list (ours appeared
as `tpgaming01`), then:

```
desktop $ ssh -i ~/.ssh/id_ed25519_tpgaming tphome@<dhcp-ip>
```

Enter your key passphrase.

> If you get `Permission denied (publickey)`, that is often a **client** problem, not
> the Pi: a passphrase-protected key with no ssh-agent, or `-i` pointed at the `.pub`
> file by mistake. Point `-i` at the **private** key. See Troubleshooting.

Once in, confirm cloud-init finished cleanly:

```
tpgaming01 $ cloud-init status --long
```

You want `status: done` and `errors: []`.

### 5. Attach and mount the NVMe

Check the drive is seen:

```
tpgaming01 $ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

You should see an `nvme0n1`. **If you do not**, stop and read the Troubleshooting entry
"NVMe not detected (`link down`)" before going further — a lit HAT LED does **not** mean
the drive is working.

With the drive present, wipe it and give it one ext4 partition spanning the disk. **Be
certain `nvme0n1` is the blank data drive and not something you care about** —
`lsblk` shows sizes and mountpoints; nothing you want should be mounted on it.

```
tpgaming01 $ sudo wipefs -a /dev/nvme0n1
tpgaming01 $ sudo parted /dev/nvme0n1 --script mklabel gpt
tpgaming01 $ sudo parted /dev/nvme0n1 --script mkpart primary ext4 0% 100%
tpgaming01 $ sudo partprobe /dev/nvme0n1
tpgaming01 $ sudo mkfs.ext4 -m 1 -L azeroth-data /dev/nvme0n1p1
```

- `-m 1` lowers ext4's root-reserved space from the default 5 % to 1 %. On a data disk
  that hands you back several GB you would otherwise never use.
- `-L azeroth-data` gives the filesystem a human label.

Now mount it permanently, **by UUID** (device names can renumber; UUIDs do not). Get
the UUID, then add it to `/etc/fstab`:

```
tpgaming01 $ sudo blkid /dev/nvme0n1p1
```

Take the `UUID="…"` value and append a line to `/etc/fstab` (use **your** UUID):

```
UUID=<your-uuid>  /mnt/nvme  ext4  defaults,noatime,nofail,x-systemd.device-timeout=10  0  2
```

- **`nofail`** is important on a headless box: if the NVMe ever fails to appear, the
  machine still boots instead of hanging forever at a console you cannot reach. We
  learned the hard way that this drive *can* vanish; `nofail` is insurance, not
  paranoia.
- `x-systemd.device-timeout=10` fails fast (10 s) instead of stalling 90 s.
- `noatime` cuts needless write traffic.

Then create the mountpoint, mount, and take ownership:

```
tpgaming01 $ sudo mkdir -p /mnt/nvme
tpgaming01 $ sudo systemctl daemon-reload
tpgaming01 $ sudo mount -a
tpgaming01 $ sudo chown tphome:tphome /mnt/nvme
tpgaming01 $ findmnt /mnt/nvme
```

If `mount -a` errors, do **not** reboot — fix the fstab line first.

### 6. Static IP

Now, from a working SSH session, we pin the address. First **read your real gateway
and DNS** — do not assume `192.168.1.1`; ours was `192.168.1.254`:

```
tpgaming01 $ ip route | grep default
tpgaming01 $ resolvectl status
```

Note the `default via X.X.X.X` value (gateway) and the DNS servers.

Tell cloud-init to stop managing the network, then write a static netplan config
(substitute **your** address, gateway, and DNS):

```
tpgaming01 $ echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

```yaml
# /etc/netplan/99-static.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      optional: true
      addresses:
        - 192.168.1.220/24
      routes:
        - to: default
          via: 192.168.1.254
      nameservers:
        addresses:
          - 192.168.1.254
          - 1.1.1.1
        search:
          - attlocal.net
```

Remove the old DHCP config, lock permissions, and **validate the syntax without
applying it** (this does not touch the live connection):

```
tpgaming01 $ sudo rm /etc/netplan/50-cloud-init.yaml
tpgaming01 $ sudo chmod 600 /etc/netplan/99-static.yaml
tpgaming01 $ sudo netplan generate
```

Silence from `netplan generate` means it is valid. Apply by rebooting, which proves the
box comes up static on its own:

```
tpgaming01 $ sudo reboot
desktop $ ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
```

> **If `.220` never answers:** the box now has no DHCP fallback, so a wrong static makes
> it unreachable. Recovery is not a reflash — pull the microSD, mount its ext4 root
> partition (`…p2`, labelled `writable`) on a Linux desktop, and fix
> `/etc/netplan/99-static.yaml`.

### 7. Firewall

Deny everything inbound except SSH. Later chapters open the game ports; nothing else
gets in. **Allow SSH before enabling, or you lock yourself out.**

```
tpgaming01 $ sudo ufw default deny incoming
tpgaming01 $ sudo ufw default allow outgoing
tpgaming01 $ sudo ufw allow OpenSSH
tpgaming01 $ sudo ufw enable
tpgaming01 $ sudo ufw status verbose
```

`ufw enable` warns it may disrupt SSH — answer `y`. Because SSH is already allowed, your
session survives.

### 8. Update, then image the baseline

Bring the OS current before anything is built on it, so your baseline snapshot is
already patched:

```
tpgaming01 $ sudo apt update
tpgaming01 $ sudo NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
tpgaming01 $ sudo apt autoremove --purge -y
```

The env vars keep it non-interactive so no blue "restart services?" dialog stalls a
pasted session. If it says a reboot is required (kernel/firmware), reboot and reconnect.

Finally, **image the card** so loops 2 and 3 of the validation process reset to this
exact clean state in minutes instead of re-running this whole chapter. Shut the Pi
down, move the card to your desktop, identify it with `lsblk` (match the size and the
`system-boot`/`writable` labels — **do not guess the device**), then read it to a
compressed image:

```
tpgaming01 $ sudo shutdown -h now
desktop $ lsblk
desktop $ sudo dd if=/dev/sdX bs=4M status=progress | gzip > ~/pi-baselines/tpgaming01-ch00-baseline.img.gz
```

Reading the card to a file is non-destructive; the only dangerous direction is writing
*back*. Keep this image **out of any git repository** — it contains host keys and your
provisioned state.

---

## ✅ Checkpoint

From your desktop, a single reconnect and check:

```
desktop $ ssh -i ~/.ssh/id_ed25519_tpgaming tphome@192.168.1.220
tpgaming01 $ hostnamectl --static          # tpgaming01
tpgaming01 $ ip -brief -4 addr show eth0    # 192.168.1.220/24
tpgaming01 $ findmnt /mnt/nvme             # mounted from nvme0n1p1
tpgaming01 $ sudo ufw status | head -1     # Status: active
```

If the box answers at its static address, mounts its data disk, and the firewall is
active — all from a cold boot — Chapter 00 is done. You have a clean, hardened,
headless host. The realm gets built on this.

## ⚠ If it went wrong

The failures we actually hit provisioning this machine are written up in
[TROUBLESHOOTING.md](TROUBLESHOOTING.md):

- **NVMe not detected (`link down`)** — the drive does not appear, even with the HAT
  LEDs lit. (ARM64-specific.)
- **Imager customisation greyed out** on Ubuntu images.
- **Desktop vs Server** — telling which Ubuntu edition you actually flashed.
- **`Permission denied (publickey)`** on first SSH — usually a client-side key problem.
