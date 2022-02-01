/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approval_Step__c object Trigger Handler class
*
* Tested by CPQ_Approval_Automation_Test
*/
public with sharing class CPQ_Quote_Approval_Step_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the AFTER UPDATE trigger context
    * @param steps records in trigger execution
    * @param oldStepsMap (Map) Record Id => Old version of record before updates
    */
    public static void afterUpdate(List<CPQ_Quote_Approval_Step__c> steps, Map<Id, CPQ_Quote_Approval_Step__c> oldStepsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Quote_Approval_Step_UpdatesUtil.processAfterUpdate(steps, oldStepsMap);
        }        
    }

}
    