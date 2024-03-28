public with sharing class UpdateContactsFuture {
    
    @future
    public static void updateContacts(String contactsToUpdateJSON) 
    {   
        List<Contact> contacts = (List<Contact>) JSON.deserialize(contactsToUpdateJSON, List<Contact>.class);
        Database.update(contacts, false);
    }
}