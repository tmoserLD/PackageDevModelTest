/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Proposal_Criterion__c object Trigger
*
* Tested by CPQ_Record_Validation_Test
*/
trigger CPQ_Proposal_Criterion_Trigger on CPQ_Playbook_Proposal_Criterion__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CPQ_Proposal_Criterion_TriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            CPQ_Proposal_Criterion_TriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}