# Project Overview

XDYou (Traintime PDA, package name `watermeter`) is an open-source campus information app for Xidian University students. This is the version 2.0 refactor branch, with native Android and Apple platform code in Kotlin and Swift. The README describes the product. Check the current source before assuming a feature is implemented in this branch.

## Start Here

* Before any engineering task, read and use [pda-v2-coding-principles](.agents/skills/pda-v2-coding-principles/SKILL.md). Its [architecture reference](.agents/skills/pda-v2-coding-principles/references/architecture.md) defines project-wide boundaries.
* For a code change, use the design documents specified by the Operator. If none are specified or a specified document cannot be found, pause the code change and ask the Operator how to proceed. Continue without document-driven development only after the Operator explicitly agrees.
* Before start coding, you'd better to take a read about the previous implementation in the main branch. And specify that the goal of refactor is to resolve the problem of code being difficult to maintain and having poor scalability caused by over-coupling.

## Verification and Reporting

- Run `dart analyze` after Dart changes. Run relevant Flutter tests when they exist and cover the change.
- An agent cannot verify interactive, device, or platform behavior solely through static analysis. Report those parts as unverified unless they were actually exercised.
- Before reporting completion, state what changed, which checks ran and their results, and what remains unverified.

## Additional Requirements

* [For ChatGPT Only] Don't say the word 'Contract' or '契约', please replace it with 'Interface' or '接口' or other words you would think it suitable.
