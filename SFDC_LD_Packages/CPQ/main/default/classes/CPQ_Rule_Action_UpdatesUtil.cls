/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Rule_Action__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Rule_Action_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook_Rule_Action__c updates that should run on Before Insert AND Before Update
    * @param actions CPQ_Playbook_Rule_Action__c records with updated/inserted values in trigger context
    * @param oldActionsMap Map - CPQ_Playbook_Rule_Action__c Id to Old version of CPQ_Playbook_Rule_Action__c
    */ 
    public static void sameActionBeforeUpdates(
        List<CPQ_Playbook_Rule_Action__c> actions,
        Map<Id, CPQ_Playbook_Rule_Action__c> oldActionsMap
    ) {

        // Evaluate each CPQ_Playbook_Rule_Action__c
        for (CPQ_Playbook_Rule_Action__c action : actions) {

            CPQ_Playbook_Rule_Action__c oldAction = new CPQ_Playbook_Rule_Action__c();
            // Not in Insert context
            if (action.Id != null) {
                oldAction = oldActionsMap.get(action.Id);
            }

            // Check for changes in fields that need validation

            // Product Adjustment Field field change
            if (
                action.Product_Adjustment_Field__c != oldAction.Product_Adjustment_Field__c &&
                action.Product_Adjustment_Field__c != null
            ) {

                // Validate Product Field field
                CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                    new List<String>{action.Product_Adjustment_Field__c},
                    new List<String>{
                        'Start_Date',
                        'End_Date',
                        'Quantity',
                        'Discount',
                        'Unit_Price',
                        'List_Price',
                        'Quantity_Editable',
                        'Dates_Editable',
                        'Discountable',
                        'List_Price_Editable',
                        'Manually_Addible',
                        'Removable'
                    },
                    'QuoteLineItem',
                    'Product Adjustment Field'
                );
                if (results.result == false) {
                    action.addError(results.errorMessage);
                }
            }
        }
    }
}
