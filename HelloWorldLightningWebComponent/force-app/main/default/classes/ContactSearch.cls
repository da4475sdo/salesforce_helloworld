public inherited sharing class ContactSearch {
    public ContactSearch() {

    }
    public static List<Contact> searchForContacts(String lastName,String postalCode){
        List<Contact> contactList = [SELECT ID,Name FROM Contact WHERE LastName = :lastName AND MailingPostalCode = :postalCode];
        return contactList;    
    }
}