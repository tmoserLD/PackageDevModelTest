/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Rule_Action__c object Trigger
*
* Tested by CPQ_Record_Validation_Test
*/
trigger CPQ_Rule_Action_Trigger on CPQ_Playbook_Rule_Action__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CPQ_Rule_Action_TriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            CPQ_Rule_Action_TriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}