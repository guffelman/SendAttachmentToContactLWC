import { LightningElement, wire, api, track } from 'lwc';
import getAttachmentsForRecord from '@salesforce/apex/SendAttachmentToContactController.getAttachmentsForRecord';
import sendEmailWithAttachment from '@salesforce/apex/SendAttachmentToContactController.sendEmailWithAttachment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SendAttachmentToContact extends LightningElement{
    @api recordId; // Pass the record Id from the Quick Action
    @track attachments = [];
    selectedAttachment = '';
    @track attachmentOptions = [];
    @track selectedContacts = []; // Array to keep track of selected contact records
    

    @wire(getAttachmentsForRecord, { recordId: '$recordId' })
    wiredAttachments({ error, data }) {
        if (data) {
            // Update attachments
            this.attachments = data;
            // Generate attachment options when attachments are available
            this.generateAttachmentOptions();
        } else if (error) {
            // Handle error appropriately
            console.error('Error fetching attachments:', error);
        }
    }

    generateAttachmentOptions() {
        this.attachmentOptions = this.attachments.map(attachment => ({
            label: attachment.Title,
            value: attachment.Id
        }));
    }

    handleAttachmentChange(event) {
        this.selectedAttachment = event.detail.value;
    }

    handleContactAdded(event) {
        this.selectedContacts.push(event.detail);
        console.log('selectedContacts:', this.selectedContacts);
        console.log('event.detail:', event.detail);
    }

    handleContactRemoved(event) {
        // Update the selectedContacts property in the parent component
        this.selectedContacts = this.selectedContacts.filter(contact => contact.Id !== event.detail);
        console.log('selectedContacts:', this.selectedContacts);
        console.log('event.detail:', event.detail);
    }

    

    handleSendEmail() {
        const selectedAttachment = this.selectedAttachment;
        const recordId = this.recordId;

        if (this.selectedContacts.length > 0) {
            if (selectedAttachment) {

                const contactIds = this.selectedContacts.map(contact => contact.Id);

                sendEmailWithAttachment({ contactIds, selectedAttachmentId: selectedAttachment, recordId })
                    .then(() => {
                        // Display toast message to indicate email sent
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Email sent',
                                variant: 'success'
                            })
                        );
                        // Close the action panel
                       // this.closeActionPanel();
                       console.log('Email sent ',  this.selectedContacts, selectedAttachment, recordId)
                    })
                    .catch(error => {
                        // Handle error appropriately
                        console.error('Error sending email:', error);
                    });
            } else {
                // Display toast message to indicate no attachment selected
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No attachment selected',
                        variant: 'error'
                    })
                );
            }
        } else {
            // Display toast message to indicate no contacts selected
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No contacts selected',
                    variant: 'error'
                })
            );
        }
    }
}

// close action panel function
