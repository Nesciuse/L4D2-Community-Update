# Introduction

Hey there!

We are thrilled that you would like to help.

As a community pursuit, everything we do is motivated by passion. While we are not officially greenlit like with [The Last Stand](https://www.l4d.com/laststand/), with the right amount of persistence and [a lot](https://developer.valvesoftware.com/wiki/Valve_Time) of patience, we aim to get out what we put in.

By participating, you agree to our [Code of Conduct](/CODE_OF_CONDUCT.md).

# Contributor Guidelines

## Coordination

In general, coordinate with us first to minimize the chance of your PR sitting in limbo. Fixes are cheap while our maintenance of them, and Valve's time spent verifying them, can be expensive. We value your time and rejection is a last resort, though sometimes the costs are unjustifiable or you may be overly ambitious.

We use [lumps](https://github.com/Tsuey/L4D2-Community-Update/tree/master/root/maps) for I/O and other complex map fixes so please always open an issue for those cases. VScript fixes [more specifically](https://github.com/Tsuey/L4D2-Community-Update/blob/master/root/scripts/vscripts/community/) focus on Versus, clips we can easily move across modes depending on feedback, and easy reverts for Mutations or custom servers. Please discuss any new functions or globals with us before opening a VScript PR, since we may need to implement as a lump instead.

Please contact [Lt. Rocky](https://github.com/ltrockyy) `Lt. Rocky#7341` directly when it comes to model, animation, texture, or other source files. We store all source files separately and cannot accept them here.

If you are a VScripter or SourceModder, please contact [someone here](/CODE_OF_CONDUCT.md#Contact) and ask about our **L4D Scripting** Discord server.

## Submissions

Please follow the provided templates when submitting an [issue](https://github.com/Tsuey/L4D2-Community-Update/issues) (bugs, questions, and suggestions) or [Pull Request](https://github.com/Tsuey/L4D2-Community-Update/pulls) (PR).

If in doubt, consider posting to this [Steam forum thread](https://steamcommunity.com/app/550/discussions/0/3083268548812820489/) instead.

Always search to see [if an issue already exists](https://github.com/Tsuey/L4D2-Community-Update/issues?q=is%3Aopen) before you open a new one. If you wish to help solve an existing issue that is not yet assigned to anyone, narrow down the search using the labels as filters to find one that interests you.

Things to keep in mind when it comes to changes:

- Valve needs to verify every byte we edit, so maintenance tasks such as optimization and changelogs are the responsibility of maintainers.
- Check if your file is already on the repo and, if not, please submit un-modified files from the live game as your earliest commits.
- Usage of leading tabs are preferred over spaces for non-generated text files, as are [VDF/KeyValue](https://developer.valvesoftware.com/wiki/KeyValues) tokens enclosed in double quotes.
- [ByteOrderMark](https://en.wikipedia.org/wiki/Byte_order_mark#UTF-8) is not allowed for text files encoded with UTF-8.
- Keep changes as focused as possible. If there are multiple changes that are not dependent on each other, consider a separate PR.
- The [least astonishing](https://en.wikipedia.org/wiki/Principle_of_least_astonishment) solution is probably the best one.
- The amount of noise generated by a change can be inversely proportional to the complexity of the change - [bikeshedding](https://docs.freebsd.org/en/books/faq/#bikeshed-painting)

When you submit your PR, enable the checkbox to [allow maintainer edits](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork) so the branch can be updated for a merge. If it is not yet ready for review, please [mark it as a draft](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/changing-the-stage-of-a-pull-request). We will then review it and [suggest changes](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/incorporating-feedback-in-your-pull-request) or comment with questions. As you update your PR and apply changes, [mark each conversation as resolved](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/commenting-on-a-pull-request#resolving-conversations).

### Resources

By [forking](https://github.com/Tsuey/L4D2-Community-Update/fork) a repository you make a copy of it for yourself that you can push changes to without affecting the original project. Forked repositories, or branches, are what you finally submit as a PR for review and merging.

&emsp;[About Pull Requests (PR's)](https://help.github.com/articles/about-pull-requests/)<br/>
&emsp;[Getting started with Github Desktop](https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/getting-started-with-github-desktop)<br/>
&emsp;[How to fork a repository with Github Desktop](https://docs.github.com/en/desktop/contributing-and-collaborating-using-github-desktop/cloning-and-forking-repositories-from-github-desktop) or [command line](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository)<br/>
&emsp;[Linking a PR to an issue if you are resolving one](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)<br/>
&emsp;[Searching issues and PR's](https://docs.github.com/en/github/searching-for-information-on-github/searching-on-github/searching-issues-and-pull-requests#search-by-the-title-body-or-comments)<br/>
&emsp;[Writing good commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)<br/>
&emsp;[Git tutorials for merge issues](https://lab.github.com/githubtraining/managing-merge-conflicts) and a [branching tutorial](https://learngitbranching.js.org/)<br/>

## Responsibility

Project maintainers have the right and responsibility to remove, edit, or reject comments, commits, code, wiki edits, issues, and other contributions that are not aligned with our [Code of Conduct](/CODE_OF_CONDUCT.md), or to ban temporarily or permanently any contributor for other behaviors that they deem inappropriate, threatening, offensive, or harmful.

On this repository, each category of content has a primary [owner](https://www.linkedin.com/pulse/engineering-ownership-introduction-david-weinberg) (or reviewer), even though we all try to wear different hats. You can address additional questions to:

- [Lt. Rocky](https://github.com/ltrockyy) for models and textures;
- [Nescius](https://github.com/Nesciuse) for Navmesh;
- [Rayman1103](https://github.com/Rayman1103) for Mutations and map lumps;
- [shqke](https://github.com/shqke) for organization;
- [Tsuey](https://github.com/Tsuey) for VScript map changes; and
- [Xanaguy](https://github.com/xanaguy) for Talker files.