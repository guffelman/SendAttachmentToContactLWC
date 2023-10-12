public with sharing class MultiSelectContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String searchKey) {
        // Define a query to retrieve contacts based on searchKey
        String searchQuery = '%' + searchKey + '%';

        // Query for contacts based on the search term
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Name LIKE :searchQuery LIMIT 10];

        return contacts;
    }
}