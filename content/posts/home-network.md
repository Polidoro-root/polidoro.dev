---
title: "Home Network"
url: "/home-network"
date: 2024-04-07
tags: ["networking", "dns", "cloudflared", "docker", "pihole", "ansible", "linux", "debian", "prometheus", "grafana", "heimdall", "bitwarden"]
draft: true
---

Recently I had to change some parameters on my LAN setup, so I decided to document
here the process and tools that I used and explain why I'm doing this things that
aren't required for fastest network but for better privacy.

Let's be honest who likes to see popups, banners and ads in every site that we use?
Because of that I'm always used extensions for browser like
[AdBlocker Ultimate](https://firefox.com), [Privacy Badger](https://firefox.com),
[Don't track me Google](https://firefox.com) and [uBlock origin](https://firefox.com).
And it was okay for just desktop browsering with Ad blocking, then I realized that
most of ads that I was receiving was in my Android phone (Xiaomi Redmi Note 9s, then
Samsumg S21 FE) and there is no "ad blocker" for a whole Operating System neither
specific apps like Whatsapp, Instagram, Youtube, etc...

At the moment I was already confortable with network concepts like DNS, Firewalls,
HTTP, servers and linux to work as Web Developer, deploying applications on managed
clouds and setting up public and private networks. Fortunately, youtube channels
that I was following (and follow yet) published contents about "Ads Protected Home
Network" like [Diolinux](https://youtube.com), [Fabio Akita](https://youtube.com)
and [Slackjeff](https://youtube.com). So I decided to see what they're talking about.

## Setup

For this setup I will be using my old HP notebook with:

- CPU: Intel i5-3230M 2.60GHz (2 cores)
- Memory: 8gb
- Storage: 120gb SSD Sata
- OS: Debian Bookworm

This is a minimal Debian installation with net iso with bare packages to get
apt and network out-of-the-box.

Through this post we'll install and setup:

- [SSH](https://www.cloudflare.com/learning/access-management/what-is-ssh/)
- [Docker](https://www.docker.com/)
- [Ansible](https://www.ansible.com/)
- [PiHole](https://pi-hole.net/)
- [Cloudflared](https://github.com/cloudflare/cloudflared)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Heimdall](https://github.com/linuxserver/Heimdall)
- [Bitwarden](https://bitwarden.com/)

The only thing that we'll need to setup manually is SSH, because every other
program will be automated through Ansible.

We could have done everything in this tutorial manually through SSH or created a
bash script to automate all steps, but I chose Ansible for two reasons: to learn
and because it is more modular to run all together or isolated tasks.

## SSH

If you choose root password in installation you wouldn't have `sudo` command,
if you want it you'll have to run as root:

```bash
su - # switch to root user

apt update # update repositories

apt install sudo # install sudo package

adduser <username> sudo # add <usernam> to sudo group
```

Anyway, with sudo permission or as root user, install `openssh-server` package:

```bash
apt install openssh-server
```

Now we have ssh server installed and `sshd` running. You can try ssh connection with:

```bash
ssh <username>@<ip-address> # example: ssh user@192.168.50.9
```

Note that we were asked to type user password to connect this time.
As we will be connecting through ssh many times and automating with Ansible,
it's highly recommended to generate pair keys for authentication instead passwords.
We can do it running our desktop (not the debian server):

```bash
ssh-keygen -t rsa -b 4096 -C "<any comment you want>" # generate rsa public/private key with 4096 bytes and comment

ls -la ~/.ssh # check if your keys are here

ssh-copy-id -i ~/.ssh/<publicKey>.pub <username>@<ipAddress> # copy your public rsa key to debian server 
```

Now that we have our RSA keys configured, we can change ssh server settings in `/etc/ssh/sshd_config` with:

```bash
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \ # disables login as root
&& sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config \ # set max authentication tries to 3 
&& sed -i 's/#MaxSessions 10/MaxSessions 3/' /etc/ssh/sshd_config \ # set max sessions to 3
&& sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \ 
&& sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \ # disable password authentication
&& sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config \
&& sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/sshd_config

systemctl restart sshd # restart sshd service to apply changes
```

From now on, we'll be using our private rsa key to authenticate on ssh server.

For Ansible automation, we need python installed on our server:

```bash
apt install python3
```

## Ansible

Instead of connecting on SSH manually and running commands step by step,
we can create tasks in ansible to do that for us, keeping track in our git repository.

In our desktop, we will create a repository:

```bash
mkdir homelab

git init -b main
```

The first thing we need to do is install ansible in our host to be the control node,
the source where sends commands to configure hosts

```bash
# Install python on Debian-based distros
sudo apt install python3 python3-pip pipx

# Install python on Arch-based distros
sudo pacman -S python python-pip python-pipx

# Setup pipx
pix ensurepath

# Install ansible
pipx install --include-deps ansible
```

Generate the scaffolding for tasks:

```bash
mkdir roles

cd roles

ansible-galaxy init docker
ansible-galaxy init pihole
ansible-galaxy init cloudflared
ansible-galaxy init prometheus
ansible-galaxy init grafana
ansible-galaxy init heimdall
ansible-galaxy init bitwarden
```

## PiHole

PiHole works as DNS (Domain Name Server) middleware for our network with the purpose
to encrypt the plain text data sent by our devices to the intertet via our ISP
(Internet Service Provider). Before delving into PiHole's functionalities, first
we need to know what is DNS supposed to do.

### DNS

When we are browsering on internet and accessing sites such as [Context: https://google.com.br]
or [Context: https://www.youtube.com], for us humans who speak Brazilian Portuguese
or English it's common to recognize products and companies name written in ASCII
characters in UTF-8, so we can relate these web sites easily each time we need to.
But that is not true for computers.

As we know nowadays computers are [Turing's Universal Discrete Machines](https://google.com)
that can fit data and instructions in eletric circuits using the [Von Neumann Architecture](https://google.com)
that combines CPU, Main Memory, I/O devices and buses. Computers will only manipulate
data in [binary numerical ...](https://google.com).
So how can we type "Youtube" on Google's search bar and receive a list of sites to
access like youtube.com.br, youtube.com or youtube.com.fr? You can see it visually in
[video](https://youtube.com).


