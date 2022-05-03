/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_System_Settings__c object Trigger
*
* Tested by CPQ_Record_Validation_Test
*/
trigger CPQ_System_Settings_Trigger on CPQ_System_Settings__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CPQ_System_Settings_TriggerHandler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            CPQ_System_Settings_TriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}