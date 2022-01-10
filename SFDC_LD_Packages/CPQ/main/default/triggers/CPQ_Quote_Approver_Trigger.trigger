trigger CPQ_Quote_Approver_Trigger on CPQ_Quote_Approver__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            CPQ_Quote_Approver_TriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}