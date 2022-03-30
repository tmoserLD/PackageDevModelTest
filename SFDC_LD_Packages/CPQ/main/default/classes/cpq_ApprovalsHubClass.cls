/**
* @author Tristan Moser
* @date 3/28/2022
*
* @description CPQ Approvals Hub controller class
*
* Tested by cpq_ApprovalsHubClassTest
*/
public with sharing class cpq_ApprovalsHubClass {

    /**
    * @description Query CPQ Quote Approvals
    * @param relationship How User record relates to approvals
    * @param userId Id of User approvals needed for
    */
    @AuraEnabled
    public static ReturnData queryApprovals(String relationship, String status, Id userId) {

        // Return wrapper obj
        ReturnData returnData = new ReturnData();
        // returnData.opportunities = new List<OpportunityData>();

        // // Populate current user if null
        // if (userId == null) {
        //     userId = System.UserInfo.getUserId();
        // }
        // returnData.userObj = [
        //     SELECT Id,
        //         Name
        //     FROM User
        //     WHERE Id=:userId
        // ];

        // // Get default currency
        // Boolean multiCurrency = System.UserInfo.isMultiCurrencyOrganization();
        // if (multiCurrency == true) {
        //     List<sObject> currencies = new List<sObject>();
        //     currencies = Database.query('SELECT Id, ConversionRate, IsoCode FROM CurrencyType WHERE IsActive = TRUE AND IsCorporate = TRUE');
        //     if (currencies.size() > 0) {
        //         returnData.defaultCurrency = (String) currencies[0].get('IsoCode');
        //     }   
        // }
        // if (returnData.defaultCurrency == null) {
        //     returnData.defaultCurrency = System.UserInfo.getDefaultCurrency();
        // }

        // // Determine all relevant IDs
        // Set<Id> approvalIDs = new Set<Id>();
        // Set<Id> quoteIDs = new Set<Id>();
        // Set<Id> oppIDs = new Set<Id>();
        // String approversQuery = ''
        //     + ' SELECT Id, '
        //         + 'CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__c,'
        //         + 'CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c,'
        //         + 'CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.OpportunityId'
        //     + ' FROM CPQ_Quote_Approver__c'
        //     + ' WHERE ' 
        //         + (relationship == 'Assigned to' ? 'Approver__c ' : 'CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.Opportunity.OwnerId ')+ '=:userId AND '
        //         + 'Status__c =:status';
        // for (CPQ_Quote_Approver__c approver : Database.query(approversQuery)) {
        //     approvalIDs.add(approver.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__c);
        //     quoteIDs.add(approver.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c);
        //     oppIDs.add(approver.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.OpportunityId);
        // }

        // // Query Opportunities with Quotes
        // String oppQuery = ''
        //     + 'SELECT Id,'
        //         + 'Name,'
        //         + 'Owner.Name,'
        //         + 'Account.Name,'
        //         + (multiCurrency == true ? 'CurrencyIsocode' : '')
        //         + '('
        //             + 'SELECT Id,'
        //                 + 'Adjustment_of_Contract__c,'
        //                 + 'Adjustment_of_Contract__r.ContractNumber,'
        //                 + 'Adjustment_Type__c,'
        //                 + 'CPQ_Playbook__c,'
        //                 + 'CPQ_Playbook__r.Default_Term_in_Months__c,'
        //                 + 'CPQ_Playbook__r.Label__c,'
        //                 + 'CPQ_Playbook__r.Pricebook__c,'
        //                 + 'End_Date__c,'
        //                 + 'IsSyncing,'
        //                 + 'Name,'
        //                 + 'Playbook_Status__c,'
        //                 + 'Start_Date__c,'
        //                 + 'TotalPrice,'
        //                 + 'Total_Price__c'
        //             + ' FROM Quotes'
        //             + ' WHERE Id IN:quoteIDs'
        //             + ' ORDER BY Name'
        //         + ')'
        //     + ' FROM Opportunity'
        //     + ' WHERE Id IN:oppIDs'
        //     + ' ORDER BY Name';
        // for (Opportunity opp : Database.query(oppQuery)) {

        //     // New OpporunityData object
        //     OpportunityData oppObj = new OpportunityData();
        //     oppObj.oppInfo = opp;
        //     oppObj.quotes = new List<QuoteData>();

        //     // Populate QuoteData objects
        //     for (Quote q : opp.Quotes) {

        //         // New QuoteData object
        //         QuoteData quoteObj = new QuoteData();
        //         quoteObj.quoteInfo = q;
        //         quoteObj.approvals = new List<ApprovalData>();

        //         oppObj.quotes.add(quoteObj);
        //     }

        //     returnData.opportunities.add(oppObj);
        // }

        // // Query Approvals with Steps
        // for (CPQ_Quote_Approval__c approval : [
        //     SELECT Id,
        //         CPQ_Playbook_Approval__c,
        //         CPQ_Playbook_Approval__r.Label__c,
        //         CPQ_Playbook_Approval__r.Reason__c,
        //         Quote__c,
        //         Quote__r.OpportunityId,
        //         Status__c,
        //         (
        //             SELECT Id,
        //                 Approval_Order__c,
        //                 Approvers_Approved__c,
        //                 Approvers_Rejected__c,
        //                 Status__c,
        //                 Total_Approvers__c
        //             FROM CPQ_Quote_Approval_Steps__r
        //             ORDER BY Approval_Order__c ASC
        //         )
        //     FROM CPQ_Quote_Approval__c
        //     WHERE Id=:approvalIDs
        // ]) {

        //     // Associate approvals to quotes
        //     for (OpportunityData oppObj : returnData.opportunities) {
        //         if (oppObj.oppInfo.Id == approval.Quote__r.OpportunityId) {
        //             for (QuoteData quoteObj : oppObj.quotes) {
        //                 if (quoteObj.quoteInfo.Id == approval.Quote__c) {

        //                     // New ApprovalData object
        //                     ApprovalData approvalObj = new ApprovalData();
        //                     approvalObj.approvalInfo = approval;
        //                     approvalObj.steps = new List<StepData>();

        //                     // Populate StepData objects
        //                     for (CPQ_Quote_Approval_Step__c step : approval.CPQ_Quote_Approval_Steps__r) {

        //                         // New StepData object
        //                         StepData stepObj = new StepData();
        //                         stepObj.stepInfo = step;
        //                         stepObj.approvers = new List<ApproverData>();

        //                         approvalObj.steps.add(stepObj);
        //                     }

        //                     quoteObj.approvals.add(approvalObj);
        //                 }
        //             }
        //         }
        //     }
        // }

        // // Query Approvers
        // for (CPQ_Quote_Approver__c approver : [
        //     SELECT Id,
        //         Approver__c,
        //         Approver__r.Name,
        //         Approver__r.DelegatedApproverId,
        //         CPQ_Quote_Approval_Step__c,
        //         CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__c,
        //         CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c,
        //         CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.OpportunityId,
        //         Status__c
        //     FROM CPQ_Quote_Approver__c
        //     WHERE CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__c IN:approvalIDs
        // ]) {

        //     // Associate approvers to steps
        //     for (OpportunityData oppObj : returnData.opportunities) {
        //         if (oppObj.oppInfo.Id == approver.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.OpportunityId) {
        //             for (QuoteData quoteObj : oppObj.quotes) {
        //                 if (quoteObj.quoteInfo.Id == approver.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c) {
        //                     for (ApprovalData approvalObj : quoteObj.approvals) {
        //                         if (approvalObj.approvalInfo.Id == approver.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__c) {
        //                             for (StepData stepObj : approvalObj.steps) {
        //                                 if (stepObj.stepInfo.Id == approver.CPQ_Quote_Approval_Step__c) {

        //                                     // New ApproverData object
        //                                     ApproverData approverObj = new ApproverData();
        //                                     approverObj.approverInfo = approver;

        //                                     stepObj.approvers.add(approverObj);
        //                                 }
        //                             }
        //                         }
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }

        return returnData;
    }

    public class ReturnData {
        @AuraEnabled public User userObj;
        @AuraEnabled public String defaultCurrency;
        // @AuraEnabled public List<OpportunityData> opportunities;
    }

    // public class OpportunityData {
    //     @AuraEnabled public Opportunity oppInfo;
    //     @AuraEnabled public List<QuoteData> quotes;
    // }

    // public class QuoteData {
    //     @AuraEnabled public Quote quoteInfo;
    //     @AuraEnabled public List<ApprovalData> approvals;
    // }

    // public class ApprovalData {
    //     @AuraEnabled public CPQ_Quote_Approval__c approvalInfo;
    //     @AuraEnabled public List<StepData> steps;
    // }

    // public class StepData {
    //     @AuraEnabled public CPQ_Quote_Approval_Step__c stepInfo;
    //     @AuraEnabled public List<ApproverData> approvers;
    // }

    // public class ApproverData {
    //     @AuraEnabled public CPQ_Quote_Approver__c approverInfo;
    // }

    /**
    * @description Generic method to update a list of sObject records
    * @param records List of sObject records
    */
    @AuraEnabled
    public static void updateRecords(List<sObject> records) {
        update records;
    }
}
