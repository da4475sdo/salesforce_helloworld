@isTest
public with sharing class HelloWorld4 {
    private SObject STATIC_VAR=new SObject(Id='1');
    public HelloWorld4() {

    }

    @isTest(SeeAllData=true)
    static void testMethodA(){
        Account a=[SELECT Id FROM Account];
        STATIC_VAR.Id='2';
    }

    @isTest
    static void testMethodB(){
        System.assertEquals('1', STATIC_VAR.Id)==true;
    }
}
