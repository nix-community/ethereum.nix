# Contributions

Contributions to this project are very **welcome** and will be fully **credited**.

## How to report a bug

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

Before creating bug reports, please check the [before-submitting-a-bug-report](#before-submitting-a-bug-report) checklist as you might find out that you don't need to create one. When you are creating a bug report, please [include as many details as possible](#how-do-i-submit-a-good-bug-report).

> **Note:** If you find a **Closed** issue that seems like it is the same thing that you're experiencing, open a new issue and include a link to the original issue in the body of your new one.

#### Before Submitting A Bug Report

- **Confirm the problem** is reproducible in the latest version of the software.
- **Perform a [cursory search of project issues](https://github.com/41North/ethereum.nix/issues)** to see if the problem has already been reported. If it has **and the issue is still open**, add a comment to the existing issue instead of opening a new one.

#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as [Github issues](https://github.com/41North/ethereum.nix/issues).

Explain the problem and include additional details to help maintainers reproduce the problem:

- **Use a clear and descriptive summary** for the issue to identify the problem.
- **Describe the exact steps which reproduce the problem** in as many details as possible. For example, start by explaining what happend when you executed the software, e.g. which command did you use in the terminal, or were you running it as a run profile in Intellij etc.
- **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets, which you use in those examples. If you're providing snippets in the issue, use backticks (```) to format them.
- **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
- **Explain which behavior you expected to see instead and why.**
- **Include screenshots** which show you following the described steps and clearly demonstrate the problem.

Provide more context by answering these questions:

- **Did the problem start happening recently** (e.g. after updating to a new version of the software) or was this always a problem?
- If the problem started happening recently, **can you reproduce the problem in an older version of the software?** What's the most recent version in which the problem doesn't happen?
- **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.

Include details about your configuration and environment:

- **Which version of the software are you using?**
- **What OS & Version are you running?**
  - **For Linux - What kernel are you running?** You can get the exact version by running `uname -a` in your terminal.
- **Are you running in a virtual machine?** If so, which VM software are you using and which operating systems and versions are used for the host and the guest?
- **Are you running in a docker container?** If so, what version of docker?
- **Are you running in a a Cloud?** If so, which one, and what type/size of VM is it?
- **What version of Java are you running?** You can get the exact version by looking at the besu logfile during startup.

## Submitting changes

We accept contributions via regular Pull Requests (PRs) on [Github](https://github.com/41North/ethereum.nix). Below there's a list of rules to follow whenever you want to send a PR:

- **Create feature branches**: It's important to be concise with your commits, so don't ask us to pull from your master branch.
- **Add tests if applicable**: Your patch probably won't be accepted if it doesn't have tests (but will depend on the situation).
- **Document any change in behaviour**: Make sure the `README.md`, Postman files and any other relevant documentation are kept up-to-date.
- **One pull request per feature**: If you want to do more than one thing, send multiple pull requests.
- **Send coherent history**: Make sure each individual commit in your pull request is meaningful. If you had to make multiple intermediate commits while developing, please [squash them](http://www.git-scm.com/book/en/v2/Git-Tools-Rewriting-History#Changing-Multiple-Commit-Messages) before submitting.

We will review your Pull Request as soon as possible!

## Style guides

### Commit messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard. Here is a brief summary:

Format:

`type(component): message (github issue number with #)`

Message types:

- **feat** is used when new feature is provided;
- **wip** is used when making regular commit and changes don't match any other types;
- **fix** is used when you fix a bug;
- **chore** is used when changes are about organization, not about logic;
- **docs** is used when you add/change documentation.

Component is a decomposition unit your commit affected. Write the message in present simple.

Examples:

```
feat(logger): add rotating
chore: remove redundant commas, add copyright
wip: pass models to routers
fix: program exit is prevented when button is pressed (COMP-1, #123)
```
