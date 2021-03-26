public with sharing class CaseTriggerHandler {
    //デフォルト前回繰越工数(非表示)の値
    private static final Integer DEFAULT_REST_NUMBER=0;
    private static final String AVAILABLE_RECORD_TYPE_NAME='APM';

    public void onBeforeInsert(List<Case> new_case) {

        // 対象となる取引先責任者の一覧を取得
        Set<Id> contIds = new Set<Id>();
        for (Case c : new_case) {
            contIds.add(c.ContactId);
        }
        List<Contact> ContactList = [
            SELECT 
                Id,
                AccountId
            FROM
                Contact
            WHERE
                Id IN:contIds
        ];

        // 取引先責任者と取引先のmapを作成
        Map<Id,Id> contaccmap = new Map<Id,Id>();
        if (ContactList.size() > 0) {
            for(Contact con : ContactList) {
                contaccmap.put(con.Id, con.AccountId);
            }
        }

        Set<Id> acctIds = new Set<Id>();
        // Caseの取引先を取得
        for(Case c : new_case) {
            acctIds.add(contaccmap.get(c.ContactId));
        }
        List <Entitlement> entls = [
            SELECT 
                e.StartDate, 
                e.Id, 
                e.EndDate, 
                e.AccountId
            FROM 
                Entitlement e
            WHERE 
                e.AccountId in :acctIds And e.EndDate >= Today 
                And e.StartDate <= Today];
    
        if(entls.isEmpty()){
            return;
        }
        for(Case c : new_case){
            if(c.EntitlementId == null && c.ContactId != null){
                for(Entitlement e:entls){
                    if(e.AccountId==contaccmap.get(c.ContactId)){
                        c.EntitlementId = e.Id;
                    }
                } 
            }
        }
    }

    // Apexトリガー(工数管理機能)
    public static void onBeforeApmCaseInsert(List<Case> caseList){
        if(caseList!=null&&caseList.size()>0){
            //対象となるケースのリストの第一要素を取得
            Case item=caseList.get(0);
            Schema.DescribeSObjectResult R = Schema.SObjectType.Case;
            Map<Id,Schema.RecordTypeInfo> rtMapById = R.getRecordTypeInfosById();
            Schema.RecordTypeInfo rtById =  rtMapById.get(item.RecordTypeId);
            String recordTypeName=rtById.name;
            //CaseのレコードタイプはAPMのみ、プロセスを続ける
            if(recordTypeName.equals(AVAILABLE_RECORD_TYPE_NAME)){
                //このケースレコードの取引先名を取得
                ID accountId=item.AccountId;
                Decimal APMContractHours=0;
                Account APMAccount=[
                    SELECT APMContractHours__c  
                    FROM Account
                    WHERE Id=:accountId
                ];
                if(APMAccount!=null){
                    APMContractHours=APMAccount.APMContractHours__c;
                }
                //今月の利用可能工数の最小値
                Decimal curMonthHoursMin=-APMContractHours;
                //今この取引先レコードに紐づくケースの数を取得
                List<Case> lastCaseList=[
                        SELECT CurMonthHours__c,CreateYear__c,CreateMonth__c 
                        FROM Case 
                        WHERE AccountId=:accountId AND CurMonthHours__c!=null
                        Order By CaseNumber
                    ];
                if(lastCaseList!=null&&lastCaseList.size()>0){
                    Case lastCase=lastCaseList.get(0);
                    Decimal createYear=lastCase.CreateYear__c;
                    Decimal createMonth=lastCase.CreateMonth__c;
                    Decimal currentYear=item.CreateYear__c;
                    Decimal currentMonth=item.CreateMonth__c;
                    //最後のケースレコードの今月の利用可能工数を取得
                    Decimal lastAvailableWorkTime=0;
                    lastAvailableWorkTime=lastCase.CurMonthHours__c;
                    if(createYear==currentYear&&createMonth==currentMonth){
                        item.CarryForwardHours__c=lastAvailableWorkTime;
                        item.CurMonthHours__c=item.CarryForwardHours__c-item.EstimatedManHour__c;
                    }else if(createYear<currentYear||createMonth<currentMonth){
                        Date startDate=Date.newInstance(Integer.valueOf(createYear),Integer.valueOf(createMonth),1);
                        Date endDate=Date.newInstance(Integer.valueOf(currentYear),Integer.valueOf(currentMonth),1);
                        //今月の利用可能工数はAPM契約工数(月)よりも大きいかどうかを判断する
                        boolean flag=isCurMonthHoursBeyondMax(lastAvailableWorkTime,APMContractHours);
                        //翌月の場合
                        if(DateUtil.monthBetween(startDate, endDate)==1){
                            if(flag){
                                item.CarryForwardHours__c=lastAvailableWorkTime;
                            }else{
                                item.CarryForwardHours__c=APMContractHours;
                            }
                        }
                        //次々月以降の場合
                        else if(DateUtil.monthBetween(startDate, endDate)==2){
                            if(flag){
                                item.CarryForwardHours__c=lastAvailableWorkTime+APMContractHours;
                            }else{
                                item.CarryForwardHours__c=APMContractHours;
                            }
                        }else{
                            item.CarryForwardHours__c=APMContractHours;
                        }
                        item.CurMonthHours__c=(APMContractHours+item.CarryForwardHours__c)-item.EstimatedManHour__c;
                    }else{
                        item.CarryForwardHours__c=DEFAULT_REST_NUMBER;
                        item.CurMonthHours__c=DEFAULT_REST_NUMBER;
                    }
                }
                //ケースの数はゼロの時
                else{
                    //このケースレコードの前回繰越工数(非表示)にゼロをセットする
                    item.CarryForwardHours__c=DEFAULT_REST_NUMBER;
                    //このケースレコードの今月の利用可能工数をセットする
                    item.CurMonthHours__c=APMContractHours-item.EstimatedManHour__c;
                }
                //このケースレコードの「今月の利用可能工数」は最小値の制限を満たすかどうか判断する
                if(item.CurMonthHours__c<curMonthHoursMin){
                    //throw new CaseHandlerDataException('当月はAPM契約工数を超えていますため、これ以上ケースの登録ができません。');
                	item.CurMonthHours__c.addError('当月はAPM契約工数を超えていますため、これ以上ケースの登録ができません。');
                }
            }
        }else{
            throw new CaseHandlerDataException('データ異常が起きた');
        }
    }

    private static boolean isCurMonthHoursBeyondMax(Decimal CurMonthHours,Decimal APMContractHours){
        return CurMonthHours<=APMContractHours;
    }

    private class CaseHandlerDataException extends Exception {}
}