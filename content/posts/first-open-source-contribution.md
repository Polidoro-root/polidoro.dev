---
title: "First open source contribution"
url: "/first-open-source-contribution"
date: 2024-09-09
tags: ["git", "github", "grafana", "jest", "internationalization", "i18n", "testing", "brazilian", "portuguese", "observability"]
draft: false
---

Today, 9/9/2024 at 9:49 AM -03:00 UTC (Brazil), I had [my first pull request merged](https://github.com/grafana/grafana/pull/93070)
into a open source software that I use and is widely adopted, [Grafana](https://grafana.com/).
I know it seems silly for some people, but ever since I've discovered open source
culture and communities I always wanted to do something about it, could be either
contributions or just using and reading code that others
have written to learn new things.

I know that the PR itself doesn't contain too much changes, complexity or
engineering. It's just one test case that asserts the values of languages
constants. But the thing that caught me wasn't the amount of effort I've had,
was the collaboration process that happened and how it flows naturally.

## The Context

First things first, I got to say why I made one PR just to assert constant values
because when we think about constants we don't think about changes. But it can change.

At the work, they asked me to create an internal dashboard to visualize business
metrics about a product that we've released recently. The difference this time is
that it has to query data from many datasources, display together in dashboards and
it won't have any updates from the dashboard so we didn't needed any custom
logic to validate and store data, then I suggested Grafana but no one there knew
why this tool, how to use and manage, so I made some local demo to validate with
them if it solves their problem, and it does.

Before using at work I've been studying for some time with their stack LGTM
([Loki](https://grafana.com/oss/loki/), [Grafana](https://grafana.com/),
[Tempo](https://grafana.com/oss/tempo/), [Mimir](https://grafana.com/oss/mimir/)).
I've always thought about observability with this stack, but with the requisites
above I was confident that it was the right tool for the job.

I've done the required dashboards locally with Docker and it was approved to deploy
in production, one of the things that I said in advantage of Grafana was the acessibility
for viewers as they didn't need to know how to write anything and it was all available
in **Portuguese** too.

## The Problem

Everything that I've worked on locally was in a version that supported Portuguese, but
I deployed to production on Ubuntu with the latest .deb package. Everything was working fine, I've copied
the dashboards, configured the datasources and said "it is working". When I showed to my
coworkers they said "Why is it in English?". Then I went to config, selected the Brazilian
Portuguese option and nothing happened. I thought that it was some bug in select component or
save button so I tried all other languages and all of them worked, but Portuguese.

I was bothered with this bug thinking why just portuguese didn't work and why in that
particular version, then I went to Github Issues to see if anybody had noticed and it
wasn't just noticed as it was solved by another Brazilian, [@JoaoSilvaGrafana](https://github.com/grafana/grafana/pull/89375).
The bug itself was that the constant `BRAZILIAN_PORTUGUESE` had the value `pt-br` but
the correct pattern was `pt-BR`, otherwise it won't be loaded and the default will be used.

With that solved I updated the .deb package on the instance and it worked correctly.
Even some time after the update there was something bothering me, I visualized the PR again
just to confirm that everything was all right, then I thought what if... it happens again?
Because portuguese isn't the most used language in the world and even brazilian companies
often use only english in their operations.

## The Test

I forked the project, wrote the test case and pushed to my account. But when I was almost
creating the PR I thought "Look at all those engineers working there, they won't notice a nobody
like me writing tests for constants values", and started to feel afraid of rejection
without reason, so I went to the commit history and noticed that there are people from
all places in the world contributing, answering questions, updating docs and writing tests
from other people code. That gives me fuel and courage to participate, even if my PR was rejected
I knew that I can learn from that experience at least and if approved I knew it could help
other people to avoid this same bug in other languages too. In the next day I received an email saying
that was approved and merged into main branch by [@ashharrison90](https://github.com/ashharrison90).

I'm not a proud person but in that moment I was proud of myself, my first commit
to a open source project so big and widely used, even being a small change I knew that
it could help someone in the future.

Few hours later I went back on Grafana's repository to see if there are new changes and I saw
[another commit](https://github.com/grafana/grafana/commit/58907a84649fac3a8b9f78e1648015c5f8b9c866) from @ashharrison90
in the same internationalization tests with another test case for canonical locale definition.
Maybe my test gave an insight for that, maybe not, what I've got from that experience is the beauty
of Open Source culture.

## Conclusion

Even a nobody like me working living in a small city, working in a small
startup can participate in big projects with small contributions. That was an awesome experience,
I'm seeking to contribute to more projects and hopefully you, reader, can try it by yourself
in a project that you've created or contributed.
