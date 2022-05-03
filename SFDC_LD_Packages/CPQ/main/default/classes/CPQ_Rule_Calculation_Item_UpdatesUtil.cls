/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ_Playbook_Rule_Calculation_Item__c object Updates class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Rule_Calculation_Item_UpdatesUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same CPQ_Playbook_Rule_Calculation_Item__c updates that should run on Before Insert AND Before Update
    * @param items CPQ_Playbook_Rule_Calculation_Item__c records with updated/inserted values in trigger context
    * @param oldItemsMap Map - CPQ_Playbook_Rule_Calculation_Item__c Id to Old version of CPQ_Playbook_Rule_Calculation_Item__c
    */ 
    public static void sameItemBeforeUpdates(
        List<CPQ_Playbook_Rule_Calculation_Item__c> items,
        Map<Id, CPQ_Playbook_Rule_Calculation_Item__c> oldItemsMap
    ) {

        // Related records to query
        RelatedQueryRecords queriedRecords = new RelatedQueryRecords();

        // Gather Question IDs
        Set<Id> questionIDs = new Set<Id>();
        for (CPQ_Playbook_Rule_Calculation_Item__c item : items) {
            questionIDs.add(item.CPQ_Playbook_Question__c);
        }
        

        // Evaluate each CPQ_Playbook_Rule_Calculation_Item__c
        for (CPQ_Playbook_Rule_Calculation_Item__c item : items) {

            CPQ_Playbook_Rule_Calculation_Item__c oldItem = new CPQ_Playbook_Rule_Calculation_Item__c();
            // Not in Insert context
            if (item.Id != null) {
                oldItem = oldItemsMap.get(item.Id);
            }

            // Check for changes in fields that need validation

            // Product Calculation Field field change
            if (
                item.Product_Calculation_Field__c != oldItem.Product_Calculation_Field__c &&
                item.Product_Calculation_Field__c != null
            ) {

                // QLI Field
                if (item.Product_Calculation_Field__c.split('\\.').size() == 1) {

                    // Validate Product Calculation Field field
                    CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                        new List<String>{item.Product_Calculation_Field__c},
                        new List<String>{
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
                        'Product Calculation Field'
                    );
                    if (results.result == false) {
                        item.addError(results.errorMessage);
                    }
                }

                // PricebookEntry/Product2 Field
                else {

                    // Validate Product Calculation Field field
                    CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyObjectFieldPair(
                        item.Product_Calculation_Field__c,
                        new Map<String, String>{
                            'PricebookEntry' => 'PricebookEntry',
                            'Product2' => 'Product2'
                        },
                        'Product Calculation Field'
                    );
                    if (results.result == false) {
                        item.addError(results.errorMessage);
                    }
                }
            }

            // Entitlement Calculation Field field change
            if (
                item.Entitlement_Calculation_Field__c != oldItem.Entitlement_Calculation_Field__c &&
                item.Entitlement_Calculation_Field__c != null
            ) {

                // Contract_Entitlement__c Field
                if (item.Entitlement_Calculation_Field__c.split('\\.').size() == 1) {

                    // Validate Entitlement Calcluation Field field
                    CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                        new List<String>{item.Entitlement_Calculation_Field__c},
                        new List<String>(),
                        'Contract_Entitlement__c',
                        'Entitlement Calculation Field'
                    );
                    if (results.result == false) {
                        item.addError(results.errorMessage);
                    }
                }

                // Product2 Field
                else {

                    // Validate Product Field field
                    CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyObjectFieldPair(
                        item.Entitlement_Calculation_Field__c,
                        new Map<String, String>{
                            'Product__r' => 'Product2'
                        },
                        'Entitlement Calculation Field'
                    );
                    if (results.result == false) {
                        item.addError(results.errorMessage);
                    }
                }
            }

            // Record Lookup Field field change
            if (item.Record_Lookup_Field__c != oldItem.Record_Lookup_Field__c &&
                item.Record_Lookup_Field__c != null
            ) {

                // Find related question
                CPQ_Playbook_Question__c question = getLookupQuestion(
                    item.CPQ_Playbook_Question__c,
                    questionIDs,
                    queriedRecords
                );

                if (question?.Query_String__c != null) {

                    String objectName = question.Query_String__c.toLowerCase().split('from')[1].split(' ')[1];
                    
                    // Validate Default Field Value field
                    CPQ_Record_Validation.ResultClass results = CPQ_Record_Validation.verifyFields(
                        new List<String>{item.Record_Lookup_Field__c},
                        new List<String>(),
                        objectName,
                        'Record Lookup Field'
                    );
                    if (results.result == false) {
                        item.addError(results.errorMessage);
                    }
                }
            }
        }
    }

    /****************
     * QUERY HELPER METHODS
     ****************/

    /**
    * @description Get Question housing record lookup value
    * @param questionId Id of question record
    * @param allQuestionIDs All question IDs for all item records in trigger context
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return CPQ_Playbook_Question__c
    */
    private static CPQ_Playbook_Question__c getLookupQuestion(
        Id questionId,
        Set<Id> allQuestionIDs,
        RelatedQueryRecords queriedRecords
    ) {

        // Query question records ONLY if not already queried in this transaction
        if (queriedRecords.lookupQuestions == null) {
            // Define questions map
            queriedRecords.lookupQuestions = new Map<Id, CPQ_Playbook_Question__c>();

            // Query questions
            for (CPQ_Playbook_Question__c q : [
                SELECT Id,
                    Query_String__c
                FROM CPQ_Playbook_Question__c
                WHERE Id IN:allQuestionIDs AND
                    Answer_Type__c = 'Record Lookup'
            ]) {
                queriedRecords.lookupQuestions.put(q.Id, q);
            }
        }

        return queriedRecords.lookupQuestions.get(questionId);
    }

    /**
	* @description Helper object to help store related records to query
	*/ 
    public class RelatedQueryRecords {
        public Map<Id, CPQ_Playbook_Question__c> lookupQuestions;
    }
}
