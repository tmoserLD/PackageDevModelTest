/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Proposal_Section__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Proposal_Section_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook_Proposal_Section__c updates that should run on Before Insert AND Before Update
    * @param sections CPQ_Playbook_Proposal_Section__c records with updated/inserted values in trigger context
    * @param oldSectionsMap Map - CPQ_Playbook_Proposal_Section__c Id to Old version of CPQ_Playbook_Proposal_Section__c
    */ 
    public static void sameSectionBeforeUpdates(
        List<CPQ_Playbook_Proposal_Section__c> sections,
        Map<Id, CPQ_Playbook_Proposal_Section__c> oldSectionsMap
    ) {

        // Evaluate each CPQ_Playbook_Proposal_Section__c
        for (CPQ_Playbook_Proposal_Section__c section : sections) {

            CPQ_Playbook_Proposal_Section__c oldSection = new CPQ_Playbook_Proposal_Section__c();
            // Not in Insert context
            if (section.Id != null) {
                oldSection = oldSectionsMap.get(section.Id);
            }

            // Check for changes in fields that need validation

            // Record Tabl Query field change
            if (section.Record_Table_Query__c != oldSection.Record_Table_Query__c&&
                section.Record_Table_Query__c != null
            ) {

                // Only allowed binded variable: quoteRecordId
                String queryToValidate = section.Record_Table_Query__c.replace(':quoteRecordId', '\'\'');

                // Validate Query String field
                CPQ_Record_Validation.ResultClass queryResults = CPQ_Record_Validation.verifyQuery(
                    queryToValidate,
                    'Record Table Query'
                );
                if (queryResults.result == false) {
                    section.addError(queryResults.errorMessage);
                }
            }
        }
    }
}
