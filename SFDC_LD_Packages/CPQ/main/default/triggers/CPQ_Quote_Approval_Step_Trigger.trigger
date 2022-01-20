/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approval_Step__c object Trigger
*
* Tested by CPQ_Approval_Automation_Test
*/
trigger CPQ_Quote_Approval_Step_Trigger on CPQ_Quote_Approval_Step__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            CPQ_Quote_Approval_Step_TriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}