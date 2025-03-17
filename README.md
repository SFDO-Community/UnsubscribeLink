# Unsubscribe Link by Jessie Rymph
Send an email to anyone from inside Salesforce and include an unsubscribe link right in the email! This app will find all contacts and leads with that email address and mark them “Email opt out.” It will also create an Unsubscribe (custom object) object so you can track unsubscribes over time. 

Unsubscribe Link Resources:

- [Installation instructions Updated 9/25/24](https://docs.google.com/document/d/1vevs5MKiTmHEtJXceSsenAm3sViQF38bAfoJ6WdATYA/edit#heading=h.3d7st1pta4ai)

## Community Sprints

### Working with Unsubscribe Link in a scratch org

Unsubscribe link is set up to use CumulusCI(CCI) for development of the managed package. To work on development of items within the managed package you will need to use CumulusCI to install the unmanaged metadata in a scratch or development org. The following trailhead describes how to install and setup CumulusCI on your computer [CumulusCI Setup](https://trailhead.salesforce.com/content/learn/modules/cumulusci-setup).

Once you have CCI installed and have opened this repository on your computer, run the following commands:
```
cci flow run dev_org --org dev
cci org browser --org dev
```

Optionally, you can run `cci org default dev` to set the 'dev' org definition as your default. If you do this, you can omit the --org dev portion of any CCI command.

To install the packaged version, you can use either
```
cci task run install_managed
cci task run install_managed_beta
```

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
