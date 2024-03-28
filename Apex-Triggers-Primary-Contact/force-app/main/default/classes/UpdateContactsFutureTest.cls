@isTest
private class UpdateContactsFutureTest {

    @isTest
    static void testUpdateContacts() {

        List<Contact> testContacts = new List<Contact>();

        testContacts.add(new Contact(LastName = 'Test Contact 1'));
        testContacts.add(new Contact(LastName = 'Test Contact 2'));
        testContacts.add(new Contact(LastName = 'Test Contact 3'));
        
        insert testContacts;
        
        String contactsToUpdateJSON = JSON.serialize(testContacts);
        
        Test.startTest();
        UpdateContactsFuture.updateContacts(contactsToUpdateJSON);
        Test.stopTest();
        
        List<Contact> updatedContacts = [SELECT Id, LastName FROM Contact WHERE Id IN :testContacts];
        
        System.assertEquals('Test Contact 1', updatedContacts[0].LastName, 'O sobrenome do contato 1 deve ser atualizado corretamente');
        System.assertEquals('Test Contact 2', updatedContacts[1].LastName, 'O sobrenome do contato 2 deve ser atualizado corretamente');
        System.assertEquals('Test Contact 3', updatedContacts[2].LastName, 'O sobrenome do contato 3 deve ser atualizado corretamente');
    }
}
