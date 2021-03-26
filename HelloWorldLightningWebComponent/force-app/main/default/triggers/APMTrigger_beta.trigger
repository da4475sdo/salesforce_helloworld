trigger APMTrigger_beta on Case (before insert) {
    //デフォルト前回繰越工数(非表示)の値
    static final Integer DEFAULT_REST_NUMBER=0;
    //デフォルトAPM契約工数(月)に関わる倍数
    static final Integer DEFAULT_APM_TIME=2;

    AMPTriggerHandler handler=new AMPTriggerHandler(); 
    handler.handle(Trigger.new);

    public without sharing class AMPTriggerHandler {
        public void handle(List<Case> caseList){
            //対象となるケースのリストを処理する
            for(Case item:caseList){
                //このケースレコードの取引先名を取得
                ID accountId=item.AccountId;
                Decimal APM=0;
                Account APMAccount=[
                    SELECT APMContractHours__c  
                    FROM Account
                    WHERE Id=:accountId
                ];
                if(APMAccount!=null){
                    APM=APMAccount.APMContractHours__c;
                }
                //今この取引先レコードに紐づくケースの数を取得
                AggregateResult[] countResults=[
                    SELECT COUNT(Id) existCaseNumber
                    FROM Case 
                    WHERE AccountId=:accountId
                ];
                Integer existCaseNumber=Integer.valueOf(countResults[0].get('existCaseNumber'));
                if(existCaseNumber>0){
                    Decimal createYear=item.CreateYear__c;
                    Decimal createMonth=item.CreateMonth__c;
                    //最後のケースレコードの今月の利用可能工数を取得
                    Decimal lastAvailableWorkTime=0;
                    if(createYear==System.now().year()&&createMonth==System.now().month()){
                        Case lastCase=[
                            SELECT CurMonthHours__c 
                            FROM Case 
                            WHERE AccountId=:accountId AND CurMonthHours__c!=null
                            Order By CaseNumber DESC Limit 1
                        ];
                        if(lastCase!=null){
                            lastAvailableWorkTime=lastCase.CurMonthHours__c;
                        }
                        if(lastAvailableWorkTime<=APM*DEFAULT_APM_TIME){
                            item.CarryForwardHours__c=lastAvailableWorkTime;
                        }else{
                            item.CarryForwardHours__c=APM*DEFAULT_APM_TIME;   
                        }
                    }else if(createYear<System.now().year()||createMonth<System.now().month()){
                        if(lastAvailableWorkTime>APM){
                            item.CarryForwardHours__c=APM;
                        }else{
                            item.CarryForwardHours__c=lastAvailableWorkTime;
                        }
                    }else{
                        item.CarryForwardHours__c=DEFAULT_REST_NUMBER;
                    }
                }
                //ケースの数はゼロの時、このケースレコードの前回繰越工数(非表示)にゼロをセットする
                else{
                    item.CarryForwardHours__c=DEFAULT_REST_NUMBER;
                }
            }
        }
    }
}