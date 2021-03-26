public inherited sharing class ContactAndLeadSearch {
    public ContactAndLeadSearch() {

    }
    public static List<List<SObject>> searchContactsAndLeads(String name){
        List<List<sObject>> searchList = [FIND :name IN ALL FIELDS 
                   RETURNING Contact(FirstName,LastName),Lead(FirstName,LastName)];
        return searchList;
    }
}