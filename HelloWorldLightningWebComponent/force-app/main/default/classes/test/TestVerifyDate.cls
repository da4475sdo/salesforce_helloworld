@isTest
public inherited sharing class TestVerifyDate {
    @isTest
    static void testStaticResource(){
       VerifyDate.CheckDates(Date.newInstance(2021, 1, 1),Date.newInstance(2021, 1, 21));
        VerifyDate.CheckDates(Date.newInstance(2021, 1, 1),Date.newInstance(2021, 3, 21));
    }
}