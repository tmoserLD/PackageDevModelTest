/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Playbook_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param playbooks records in trigger execution
    */
    public static void beforeInsert(List<CPQ_Playbook__c> playbooks) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_Playbook_UpdatesUtil.samePlaybookBeforeUpdates(
                playbooks,
                new Map<Id, CPQ_Playbook__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param playbooks records in trigger execution
    * @param oldPlaybooksMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Playbook__c> playbooks, Map<Id, CPQ_Playbook__c> oldPlaybooksMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Playbook_UpdatesUtil.samePlaybookBeforeUpdates(
                playbooks,
                oldPlaybooksMap
            );
        }        
    }

}