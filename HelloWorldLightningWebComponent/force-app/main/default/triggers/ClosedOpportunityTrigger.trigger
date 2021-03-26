trigger ClosedOpportunityTrigger on Opportunity (after insert) {
    List<Opportunity> opList=Trigger.new;
    List<Task> taskList=new List<Task>();
    for(Opportunity op:opList){
        if('Closed Won'.equals(op.StageName)){
            Task newTask=new Task(Subject='Follow Up Test Task',WhatId=op.Id);
            taskList.add(newTask);
        }
    }
    insert taskList;
}