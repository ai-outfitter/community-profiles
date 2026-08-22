---
name: environment.repo-auth
description: Repository authentication convention for agents working with Git remotes and forge APIs.
abstract: true
# A higher-precedence layer may replace this profile with the same slug for
# another approved transport, but must keep credentials out of the catalog.
append_system_prompt: [{file: prompts/environment.repo-auth.md}]
---
