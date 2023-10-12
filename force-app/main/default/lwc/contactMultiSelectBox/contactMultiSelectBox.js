import { LightningElement, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/MultiSelectContactController.getContacts';

export default class ContactMultiSelectBox extends LightningElement {
  @track searchTerm = '';
  @track selectedContacts = [];
  @track autocompleteResults = [];
  @track hasSelectedContacts = false; // New variable to track if there are selected contacts

  // Wire method to fetch contacts based on searchTerm
  @wire(getContacts, { searchKey: '$searchTerm' })
  wiredContacts({ data, error }) {
    if (data) {
      this.autocompleteResults = data.map((contact) => ({
        Id: contact.Id,
        Name: contact.Name,
      }));
    } else if (error) {
      // Handle the error, e.g., show an error message
      this.autocompleteResults = [];
    }
  }

  showAutocomplete = false;

  handleSearch(event) {
    this.searchTerm = event.target.value;
    // Set showAutocomplete to true when there is a search term, otherwise, set it to false
    this.showAutocomplete = this.searchTerm.length > 0;
  }

  selectContact(event) {
    const contactId = event.currentTarget.getAttribute('data-contact-id');
    const selectedContact = this.autocompleteResults.find((contact) => contact.Id === contactId);
    // dispatch the custom event to notify the parent
    this.dispatchEvent(new CustomEvent('contactadded', { detail: selectedContact }));
    this.selectedContacts = [...this.selectedContacts, selectedContact];
    this.searchTerm = '';
    this.autocompleteResults = [];
    this.showAutocomplete = false; // Hide suggestions after selecting a contact
    this.hasSelectedContacts = true; // Set to true when there are selected contacts
  }

  removeContact(event) {
    const contactIdToRemove = event.currentTarget.getAttribute('data-contact-id');
    // Dispatch the custom event to notify the parent
    this.dispatchEvent(new CustomEvent('contactremoved', { detail: contactIdToRemove }));
    this.selectedContacts = this.selectedContacts.filter((contact) => contact.Id !== contactIdToRemove);
    if (this.selectedContacts.length === 0) {
      this.hasSelectedContacts = false; // Set to false when there are no selected contacts
    }
  }

  // Add blur event handler to hide suggestions when the field loses focus
  handleBlur() {
    this.showAutocomplete = false;
  }
}


