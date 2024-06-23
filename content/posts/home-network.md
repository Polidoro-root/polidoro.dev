---
title: "Home Network"
url: "/home-network"
date: 2024-04-07
tags: ["networking", "dns", "firewall", "cloudflared", "docker", "pihole", "ansible", "linux", "debian", "heimdall"]
draft: false
---

Recently I had to change some parameters on my LAN setup, so I decided to document
here the process and tools that I used and explain why I'm doing this things that
aren't required for fastest network but for better privacy.

Let's be honest who likes to see popups, banners and ads in every site that we use?
Because of that I'm always used extensions for browser like
[AdBlocker Ultimate](https://addons.mozilla.org/en-US/firefox/addon/adblocker-ultimate),
[Privacy Badger](https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/),
[Don't track me Google](https://addons.mozilla.org/en-US/firefox/addon/dont-track-me-google1/)
and [uBlock origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/).
And it was okay for just desktop browsering with Ad blocking, then I realized that
most of ads that I was receiving was in my Android phone (Xiaomi Redmi Note 9s, then
Samsumg S21 FE) and there is no "ad blocker" for a whole Operating System neither
specific apps like Whatsapp, Instagram, Youtube, etc...

At the moment I was already confortable with network concepts like DNS, Firewalls,
HTTP, servers and linux to work as Web Developer, deploying applications on managed
clouds and setting up public and private networks. Fortunately, youtube channels
that I was following (and follow yet) published contents about "Ads Protected Home
Network" like [Diolinux](https://www.youtube.com/@Diolinux),
[Fabio Akita](https://www.youtube.com/@Akitando) and
[Slackjeff](https://www.youtube.com/@SlackJeff). So I decided to see what they're talking about.

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
- [Ansible](https://www.ansible.com/)
- [Docker](https://docker.com/)
- [Cloudflared](https://github.com/cloudflare/cloudflared)
- [PiHole](https://pi-hole.net/)
- [Heimdall](https://github.com/linuxserver/Heimdall)

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
ansible-galaxy init firewall
ansible-galaxy init cloudflared
ansible-galaxy init heimdall
```

## Firewall

As we'll make it a DNS server, for security it's recommended that we allow just the
necessary ports for communication.

In this case, we'll install `ufw` package and enable ssh, http/https and dns ports
only.

We'll setup Firewall `roles/firewall/tasks/main.yaml` with:

> Note that ssh port is not the default 22 and does not accept any host, that because
we want to reduce the possible connections to the server through ssh

```yaml
---
- name: install firewall
  apt:
    name:
      - ufw
    state: present
    update_cache: yes


- name: enable ssh port
  community.general.ufw:
    rule: allow
    port: "{{ ufw_ssh_port }}"
    proto: tcp
    direction: in
    from_ip: "{{ ufw_ssh_from_ip }}"
    state: enabled
    to_ip: "{{ ufw_ssh_to_ip }}"

- name: enable http port
  community.general.ufw:
    rule: allow
    port: 80
    proto: tcp

- name: enable https port
  community.general.ufw:
    rule: allow
    port: 443
    proto: tcp

- name: enable dns tcp port
  community.general.ufw:
    rule: allow
    port: 53
    proto: tcp

- name: enable dns udp port
  community.general.ufw:
    rule: allow
    port: 53
    proto: udp

- name: enable ipv6 range rule
  community.general.ufw:
    rule: allow
    port: 546:547
    proto: udp

- name: enable firewall
  community.general.ufw:
    state: enabled

```

## Docker

To isolate each application environments, we'll use Docker containers instead
of running on bare metal.

With the directory `roles/docker` created by ansible-galaxy, we'll setup Docker
in `roles/docker/tasks/main.yaml` with:

```yaml
---
- name: install libs
  apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - python3-pip
      - virtualenv
      - python3-setuptools
      - python3-jsondiff
      - python3-requests
    state: present
    update_cache: yes

- name: install docker gpg key
  apt_key:
    url: https://download.docker.com/linux/debian/gpg
    state: present

- name: Add docker repository
  apt_repository:
    repo: deb https://download.docker.com/linux/debian "{{ ansible_distribution_release }}" stable
    state: present

- name: install docker
  apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    state: present

- name: setup docker user and group
  ansible.builtin.user:
    name: "{{ ansible_user }}"
    state: present
    groups: docker
    append: true

```

## Cloudflared

We could use any service that give us DoH (DNS over HTTPS), in this case I chose
Cloudflared because I have previous experience in managing it. But it could be
Unbound for example.

We'll setup Cloudflared in `roles/cloudflared/tasks/main.yaml` with:

```yaml
---
- name: run cloudflared container
  docker_container:
    name: cloudflared
    state: started
    image: docker.io/cloudflare/cloudflared:latest
    command: proxy-dns
    network_mode: host
    env:
      TUNNEL_DNS_UPSTREAM: "https://1.1.1.1/dns-query,https://1.0.0.1/dns-query"
      TUNNEL_DNS_PORT: "5053"
      TUNNEL_DNS_ADDRESS: "0.0.0.0"
      TUNNEL_METRICS: "{{ cloudflared_metrics }}"
    restart_policy: unless-stopped
```

Using `network_mode: host` means that we don't have to deal with NAT and port
forwarding, in this configuration we are telling to `cloudflared` to listen DNS
requests on port 5053 and redirect them to nameservers 1.1.1.1 or 1.0.0.1 from
Cloudflare, applying DoH.

## PiHole

PiHole works as DNS (Domain Name Server) middleware for our network with the purpose
to encrypt the plain text data sent by our devices to the internet via our ISP
(Internet Service Provider).

We'll setup PiHole in `roles/pihole/tasks/main.yaml` with:

```yaml
---
- name: run pihole docker container
  docker_container:
    state: started
    name: pihole
    image: docker.io/pihole/pihole:latest
    network_mode: host
    env:
      DNSMASQ_USER: pihole
      TZ: America/Sao_Paulo
      PIHOLE_DNS_: 127.0.0.1#5053
      WEBTHEME: default-darker
      WEBPASSWORD: "{{ pihole_webpassword }}"
      WEB_PORT: "{{ pihole_webport }}"
    volumes:
      - "/home/{{ ansible_user }}/pihole:/etc/pihole"
      - "/home/{{ ansible_user }}/etc-dnsmasq.d:/etc/dnsmasq.d"
    restart_policy: unless-stopped
```

This container also is running on `network_mode: host`, so the ports 53/udp,
53/tcp, 546/udp, 547/udp and the one choosen for `pihole_webport` will be
available on host.

## Heimdall
