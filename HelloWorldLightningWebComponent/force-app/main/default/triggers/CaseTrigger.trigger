trigger CaseTrigger on Case (before insert) {
    
        /**数据的构造最好 */
    CaseTriggerHandler handler = new CaseTriggerHandler();

    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) ){
        handler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isExecuting&&Trigger.isInsert&&Trigger.isBefore){
        CaseTriggerHandler.onBeforeApmCaseInsert(Trigger.new);
    }
    
}