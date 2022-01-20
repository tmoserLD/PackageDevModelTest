/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approver__c object Trigger
*
* Tested by CPQ_Approval_Automation_Test
*/
trigger CPQ_Quote_Approver_Trigger on CPQ_Quote_Approver__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            CPQ_Quote_Approver_TriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}