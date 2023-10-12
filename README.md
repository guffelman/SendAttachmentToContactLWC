# Send Attachment to Contact Component

This is a Lightning Web Component that allows users to select a contact, then an attachment from a record to send in an email.

## Installation

To use this component in your Salesforce org, you can either:

1. Install the unmanaged package from the AppExchange: [link to package]()

2. Clone the repository and deploy the code to your org using the Salesforce CLI:

```sh
git clone https://github.com/guffelman/send-attachment-to-contact.git
cd send-attachment-to-contact
sfdx force:source:deploy -p force-app/main/default
```

## Usage

To use this component, add it to a Lightning page or record page in your org. The component will display a form with a lookup field to select a contact and a dropdown to select an attachment from the record. Once a contact and attachment are selected, click the "Send Email" button to send an email with the attachment to the selected contact.

## Contributing

If you find a bug or would like to contribute to this component, please open an issue or pull request on the GitHub repository.
