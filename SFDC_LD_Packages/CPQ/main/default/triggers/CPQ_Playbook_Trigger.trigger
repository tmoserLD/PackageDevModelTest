/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook__c object Trigger
*
* Tested by CPQ_Record_Validation_Test
*/
trigger CPQ_Playbook_Trigger on CPQ_Playbook__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CPQ_Playbook_TriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            CPQ_Playbook_TriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}