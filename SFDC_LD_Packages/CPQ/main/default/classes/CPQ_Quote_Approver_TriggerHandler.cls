/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ_Quote_Approver__c object Trigger Handler class
*
* Tested by CPQ_Approval_Automation_Test
*/
public with sharing class CPQ_Quote_Approver_TriggerHandler {

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param approvers records in trigger execution
    * @param oldApproversMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Quote_Approver__c> approvers, Map<Id, CPQ_Quote_Approver__c> oldApproversMap) {
        CPQ_Quote_Approver_UpdatesUtil.sameApproverBeforeUpdates(
            approvers,
            oldApproversMap
        );
    }
    
    /**
    * @description Process to be run in the AFTER UPDATE trigger context
    * @param approvers records in trigger execution
    * @param oldApproversMap (Map) Record Id => Old version of record before updates
    */
    public static void afterUpdate(List<CPQ_Quote_Approver__c> approvers, Map<Id, CPQ_Quote_Approver__c> oldApproversMap) { 
        CPQ_Quote_Approver_UpdatesUtil.relatedObjectAfterUpdates(
            approvers,
            oldApproversMap
        );   
    }

}
