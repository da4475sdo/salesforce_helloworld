trigger testTrigger on Account (before insert,after insert,before delete) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            System.debug('before insert');
        }else if(Trigger.isAfter){
            System.debug('after insert');
        }else{
            System.debug('error');
        }
    }else if(Trigger.isDelete){
        System.debug('delete');
    }else{
        System.debug('do nothing');
    }
}