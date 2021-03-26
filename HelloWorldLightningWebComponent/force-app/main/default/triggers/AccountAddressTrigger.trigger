trigger AccountAddressTrigger on Account (before insert) {
	Account insertingAccount=Trigger.new.get(0);
    if(insertingAccount.Match_Billing_Address__c==true
    &&!''.equals(insertingAccount.BillingPostalCode)){
        insertingAccount.ShippingPostalCode=insertingAccount.BillingPostalCode;
    }
}