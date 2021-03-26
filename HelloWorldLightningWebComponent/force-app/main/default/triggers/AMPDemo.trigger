trigger AMPDemo on Case (before insert) {

    CaseTriggerHandler handler = new CaseTriggerHandler();

    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) ){
        handler.onBeforeInsert(Trigger.new);
    }

    public without sharing class CaseTriggerHandler {

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
    }
}