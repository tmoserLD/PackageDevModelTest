/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description Opportunity object - Contract automation Trigger
*
* Tested by OppContractTest
*/
trigger OppContractTrigger on Opportunity (after update, after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OppContractTriggerHandler.afterInsert(Trigger.new);
        }

        else if (Trigger.isUpdate) {
            OppContractTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}