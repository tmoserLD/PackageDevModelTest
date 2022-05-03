/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Playbook_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook__c updates that should run on Before Insert AND Before Update
    * @param playbooks CPQ_Playbook__c records with updated/inserted values in trigger context
    * @param oldPlaybooksMap Map - CPQ_Playbook__c Id to Old version of CPQ_Playbook__c
    */ 
    public static void samePlaybookBeforeUpdates(
        List<CPQ_Playbook__c> playbooks,
        Map<Id, CPQ_Playbook__c> oldPlaybooksMap
    ) {

        // Evaluate each CPQ_Playbook__c
        for (CPQ_Playbook__c playbook : playbooks) {

            CPQ_Playbook__c oldPlaybook = new CPQ_Playbook__c();
            // Not in Insert context
            if (playbook.Id != null) {
                oldPlaybook = oldPlaybooksMap.get(playbook.Id);
            }

            // Check for changes in fields that need validation

            // Product Summary Columns field change
            if (playbook.Product_Summary_Columns__c != oldPlaybook.Product_Summary_Columns__c &&
                playbook.Product_Summary_Columns__c != null
            ) {

                // Validate Product Summary Columns
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    playbook.Product_Summary_Columns__c.split(';'),
                    new List<String>{
                        'Product_Name',
                        'Start_Date',
                        'End_Date',
                        'Quantity',
                        'Discount',
                        'Unit_Price',
                        'List_Price',
                        'Sub_Total_Price',
                        'Total_Price'
                    },
                    'QuoteLineItem',
                    'Product Summary Columns'
                );
                if (results.result == false) {
                    playbook.addError(results.errorMessage);
                }
            }

            // Entitlement Summary Columns field change
            if (playbook.Entitlement_Summary_Columns__c != oldPlaybook.Entitlement_Summary_Columns__c &&
                playbook.Entitlement_Summary_Columns__c != null
            ) {

                // Validate Entitlement Summary Columns
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    playbook.Entitlement_Summary_Columns__c.split(';'),
                    new List<String>(),
                    'Contract_Entitlement__c',
                    'Contract Table Columns'
                );
                if (results.result == false) {
                    playbook.addError(results.errorMessage);
                }
            }

            // Quote View Display Fields field change
            if (playbook.Quote_View_Display_Fields__c != oldPlaybook.Quote_View_Display_Fields__c &&
                playbook.Quote_View_Display_Fields__c != null
            ) {

                // Validate Quote View Display Fields
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    playbook.Quote_View_Display_Fields__c.split(';'),
                    new List<String>(),
                    'Quote',
                    'Quote View Display Fields'
                );
                if (results.result == false) {
                    playbook.addError(results.errorMessage);
                }
            }

            // Contract View Display Fields field change
            if (playbook.Contract_View_Display_Fields__c != oldPlaybook.Contract_View_Display_Fields__c &&
                playbook.Contract_View_Display_Fields__c != null
            ) {

                // ValidateContract View Display Fields
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    playbook.Contract_View_Display_Fields__c.split(';'),
                    new List<String>(),
                    'Contract',
                    'Contract View Display Fields'
                );
                if (results.result == false) {
                    playbook.addError(results.errorMessage);
                }
            }
        }
    }
}
