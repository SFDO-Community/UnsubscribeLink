# Unsubscribe Link by Jessie Rymph
Send an email to anyone from inside Salesforce and include an unsubscribe link right in the email! This app will find all contacts and leads with that email address and mark them “Email opt out.” It will also create an Unsubscribe (custom object) object so you can track unsubscribes over time. 

Unsubscribe Link Resources:

- [Installation instructions Updated 9/25/24](https://docs.google.com/document/d/1vevs5MKiTmHEtJXceSsenAm3sViQF38bAfoJ6WdATYA/edit#heading=h.3d7st1pta4ai)

## Unmanaged source deploy

This project is namespaced `UnsubscribeLnk` for the managed package. A source deploy to a developer org, sandbox, or scratch org that does not own that namespace must stay unprefixed.

Create scratch orgs with `--no-namespace`. `sfdx-project.json` will otherwise try to apply `UnsubscribeLnk`, which fails on a Dev Hub that does not own the namespace.

Scratch orgs also need English. Custom objects in this project use `startsWith`, which Salesforce rejects on some other org languages. `config/project-scratch-def.json` and the CumulusCI defs in `orgs/` pin `language` to `en_US`.

```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --no-namespace \
  --duration-days 7
sf project deploy start --source-dir force-app
```

Do not install the managed package into the same org as this source deploy. The object and field names collide.

## Community Sprints 

### [Upcoming] September 2024 Virtual Community Sprint - September 26th and 27th global virtual sprint

#### Team

* [Jessie Rymph](https://www.linkedin.com/in/rymph/)
* [Jon Sayer](https://www.linkedin.com/in/jonsayer/)
* Scott Jacobson
* Eileen K
* Dirk Keaton
* Aïcha Medjahed
* [Hua Ping Tan](https://www.linkedin.com/in/huapingtan/)
* [Igor Androsov](https://www.linkedin.com/in/iandrosov/)

#### Agenda TENTATIVE
* Revise `generateAllRandomStrings` class to generate `Public_Id__c` for Leads as well as Contacts.
* Write a test class for generateAllRandomStrings class.
* Improve upon existing code.
* Figure out a way to turn on and off record-triggered flows in a friendly way that works in a managed package.
* GitHub Collaboration practices, team agreement.
* Development env setup (VSCode, CLI tools versions etc.)
* Development workflow (collaboration, PR, code reviews, commits merges etc.)
* Work item/feature management (issues, projects, assignments, and boards)
* SDLC, (CICD, packaging, scratch orgs, source management)

#### Summary & Accomplishments
#### Recommendations for Future Sprints
