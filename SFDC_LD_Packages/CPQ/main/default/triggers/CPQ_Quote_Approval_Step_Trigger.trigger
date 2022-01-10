trigger CPQ_Quote_Approval_Step_Trigger on CPQ_Quote_Approval_Step__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            CPQ_Quote_Approval_Step_TriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}