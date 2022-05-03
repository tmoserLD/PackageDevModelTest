/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Proposal_Criterion__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Proposal_Criterion_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook_Proposal_Criterion__c updates that should run on Before Insert AND Before Update
    * @param criteria CPQ_Playbook_Proposal_Criterion__c records with updated/inserted values in trigger context
    * @param oldCriteriaMap Map - CPQ_Playbook_Proposal_Criterion__c Id to Old version of CPQ_Playbook_Proposal_Criterion__c
    */ 
    public static void sameCriterionBeforeUpdates(
        List<CPQ_Playbook_Proposal_Criterion__c> criteria,
        Map<Id, CPQ_Playbook_Proposal_Criterion__c> oldCriteriaMap
    ) {

        // Evaluate each CPQ_Playbook_Proposal_Criterion__c
        for (CPQ_Playbook_Proposal_Criterion__c criterion : criteria) {

            CPQ_Playbook_Proposal_Criterion__c oldCriterion = new CPQ_Playbook_Proposal_Criterion__c();
            // Not in Insert context
            if (criterion.Id != null) {
                oldCriterion = oldCriteriaMap.get(criterion.Id);
            }

            // Check for changes in fields that need validation

            // Product Field field or Product Is Entitlement field change
            if (
                (
                    criterion.Product_Field__c != oldCriterion.Product_Field__c ||
                    criterion.Product_Is_Entitlement__c != oldCriterion.Product_Is_Entitlement__c
                ) &&
                criterion.Product_Field__c != null
            ) {

                // QLI/Entitlement distinctions
                String objectName = 'Contract_Entitlement__c';
                if (criterion.Product_Is_Entitlement__c == false) {
                    objectName = 'QuoteLineItem';
                }

                // Validate Product Field field
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    new List<String>{criterion.Product_Field__c},
                    new List<String>(),
                    objectName,
                    'Product Field'
                );
                if (results.result == false) {
                    criterion.addError(results.errorMessage);
                }
            }
        }
    }
}
