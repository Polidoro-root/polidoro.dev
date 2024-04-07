---
title: "Home Network"
url: "/home-network"
date: 2024-04-07
tags: ["networking", "dns", "cloudflared", "docker", "pihole", "ansible", "linux", "ubuntu", "prometheus", "grafana"]
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


