trigger ContactTrigger on Contact (after insert) {

    Set<Id> accountIds = new Set<Id>();
    Set<Id> primaryContactsCadidate = new Set<Id>();    
    
    for (Contact contact : Trigger.new) {
        if(contact.AccountId == null) continue;
        if(contact.PrimaryContactPhone__c != null)
        {
            primaryContactsCadidate.add(contact.Id);
        }
        accountIds.add(contact.AccountId);
    }   

    Map<Id, Contact> truePrimaryContactByAccountId = new Map<Id, Contact> ();
    Map<Id, List<Contact>> secondaryContactsByAccountId = new Map<Id, List<Contact>>();

    for (Contact contact : [SELECT Id, AccountId, PrimaryContactPhone__c FROM Contact WHERE AccountId IN: accountIds AND Id NOT IN: primaryContactsCadidate])
    {   
        if(contact.PrimaryContactPhone__c != null)
        {
            truePrimaryContactByAccountId.put(contact.AccountId, contact);
        }
        else {
            if(!secondaryContactsByAccountId.containsKey(contact.AccountId))
            {
                secondaryContactsByAccountId.put(contact.AccountId, new List<Contact>());
            }
            List<Contact> contactsCompany = secondaryContactsByAccountId.get(contact.AccountId);
            contactsCompany.add(contact);
            secondaryContactsByAccountId.put(contact.AccountId, contactsCompany);
        }
    }

    Set<Id> contactsWithError = new Set<Id>();
    
    for (Contact contact : Trigger.new) {        
        if(contact.AccountId != null && contact.PrimaryContactPhone__c != null) 
        {
            Contact primaryContact = truePrimaryContactByAccountId.get(contact.AccountId);            
            if(primaryContact != null && primaryContact.Id != contact.Id && primaryContact.PrimaryContactPhone__c != contact.PrimaryContactPhone__c)
            {                
                contact.addError('A primary contact already exists for this account.');
                contactsWithError.add(contact.Id);                
            }
            else 
            {
                truePrimaryContactByAccountId.put(contact.AccountId, contact);
            }
        }        
    }    

    List<Contact> contactsToUpdate = new List<Contact>();
    
    for (Id accountId : secondaryContactsByAccountId.keySet()) {        
        
        Contact primaryContact = truePrimaryContactByAccountId.get(accountId);
        
        if(primaryContact == null) continue;
        
        for(Contact contact : secondaryContactsByAccountId.get(accountId)) 
        {
            if(contactsWithError.contains(contact.Id) || contact.PrimaryContactPhone__c != null) continue;

            Contact secondaryContactToUpdate = new Contact(
                Id = contact.Id,
                PrimaryContactPhone__c = primaryContact.PrimaryContactPhone__c
            );
            contactsToUpdate.add(secondaryContactToUpdate);
        }
    }

    if(contactsToUpdate.isEmpty()) {
        return;
    }

    String contactsJSON = JSON.serialize(contactsToUpdate);

    UpdateContactsFuture.updateContacts(contactsJSON);    
}