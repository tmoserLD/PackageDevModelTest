/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approver__c object Trigger
*
* Tested by CPQ_Approval_Automation_Test
*/
trigger CPQ_Quote_Approver_Trigger on CPQ_Quote_Approver__c (before update, after update) {
    
    // BEFORE context
    if (Trigger.isBefore) {
        // UPDATE
        if (Trigger.isUpdate) {
            CPQ_Quote_Approver_TriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    // AFTER context
    else if (Trigger.isAfter) {
        // UPDATE
        if (Trigger.isUpdate) {
            CPQ_Quote_Approver_TriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}