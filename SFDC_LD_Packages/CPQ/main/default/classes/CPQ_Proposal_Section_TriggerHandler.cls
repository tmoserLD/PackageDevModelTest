/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Proposal_Section__c object Trigger Handler class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Proposal_Section_TriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    
    /**
    * @description Process to be run in the BEFORE INSERT trigger context
    * @param sections records in trigger execution
    */
    public static void beforeInsert(List<CPQ_Playbook_Proposal_Section__c> sections) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            CPQ_Proposal_Section_UpdatesUtil.sameSectionBeforeUpdates(
                sections,
                new Map<Id, CPQ_Playbook_Proposal_Section__c>()
            );
        }        
    }

    /**
    * @description Process to be run in the BEFORE UPDATE trigger context
    * @param sections records in trigger execution
    * @param oldSectionsMap (Map) Record Id => Old version of record before updates
    */
    public static void beforeUpdate(List<CPQ_Playbook_Proposal_Section__c> sections, Map<Id, CPQ_Playbook_Proposal_Section__c> oldSectionsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            CPQ_Proposal_Section_UpdatesUtil.sameSectionBeforeUpdates(
                sections,
                oldSectionsMap
            );
        }        
    }

}