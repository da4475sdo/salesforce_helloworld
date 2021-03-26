public inherited sharing class AccountHandler {
    public AccountHandler() {

    }
    public static Account insertNewAccount(String accountName){
        try{
            Account a=new Account(name=accountName);
            insert a;
            return a;
        }catch(DmlException ex){
            System.debug(ex.getMessage());
            return null;
        }
    }
}