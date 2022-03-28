/**
* @author Tristan Moser
* @date 2/25/2022
*
* @description Contracts by Account controller class
*
* Tested by cpq_ContractsByAccountClassTest
*/
public with sharing class cpq_ContractsByAccountClass {

    /**
    * @description Query Account so that is appears under recently viewed
    * @param acctId Id of Account record
    */
    @AuraEnabled
    public static void queryAccount(Id acctId) {
        Account acct = [
            SELECT Id
            FROM Account
            WHERE Id=:acctId
            FOR VIEW
        ];
    }

    /**
    * @description Query recently viewed account records
    * @return List of recently viewed account records
    */
    @AuraEnabled
    public static List<Account> getRecentlyViewed() {
        Set<Id> recentlyViewedAcctIDs = new Set<Id>();
        for (RecentlyViewed rv : [
            SELECT Id
            FROM RecentlyViewed
            WHERE Type='Account'
        ]) {
            recentlyViewedAcctIDs.add(rv.Id);
        }

        List<Account> accounts = new List<Account>();
        accounts = [
            SELECT Id,
                Name,
                Owner.Name,
                LastViewedDate
            FROM Account
            WHERE Id IN:recentlyViewedAcctIDs
            ORDER BY LastViewedDate DESC
        ];

        return accounts;
    }

    /**
    * @description Query account with related contracts
    * @param acctId Id of Account record
    * @return AccountObj for given account
    */
    @AuraEnabled
    public static AccountObj queryAccountWithContracts(Id acctId) {

        Boolean multiCurrency = System.UserInfo.isMultiCurrencyOrganization();

        AccountObj acctObj = new AccountObj();

        acctObj.acctInfo = [
            SELECT Id,
                Name,
                Owner.Name
            FROM Account
            WHERE Id =:acctId
        ];

        // Contract Entitlement Fields
        Set<String> entitlementFields = new Set<String>{
            'Id',
            'CPQ_Playbook_Rule_Action__c',
            'Discount__c',
            'End_Date__c',
            'List_Price__c',
            'Product__c',
            'Product_Name__c',
            'Quantity__c',
            'Start_Date__c',
            'Total_Price__c',
            'Unit_Price__c'
        };
        // Query all active playbooks
        for (CPQ_Playbook__c playbook : [
            SELECT Id,
                Entitlement_Summary_Columns__c
            FROM CPQ_Playbook__c
            WHERE IsActive__c=true AND
                Entitlement_Summary_Columns__c != null
        ]) {
            // Extract each field
            for (String field : playbook.Entitlement_Summary_Columns__c.split(';')) {

                entitlementFields.add(field);
            }
        }
        // Convert Set to String
        String entitlementFieldsString = '';
        for (String field : entitlementFields) {
            entitlementFieldsString += field + ',';
        }
        entitlementFieldsString = entitlementFieldsString.removeEnd(',');

        // Query Contracts
        acctObj.Contracts = new List<Contract>();
        String contractQuery = ''
            + 'SELECT Id, '
                + 'Adjusted_by_Contract__c, '
                + 'Adjusted_by_Contract__r.ContractNumber, '
                + 'Adjustment_of_Contract__c, '
                + 'Adjustment_of_Contract__r.ContractNumber, '
                + 'Adjustment_Type__c, '
                + 'Contract_End_Date__c, '
                + 'ContractNumber, '
                + 'Contract_Start_Date__c, '
                + 'Contract_Status__c, '
                + 'Contract_Total__c, '
                + 'CPQ_Playbook__c, '
                + 'CPQ_Playbook__r.Default_Term_in_Months__c, '
                + 'CPQ_Playbook__r.Label__c, '
                + 'CPQ_Playbook__r.Pricebook__c, '
                + 'Opportunity__c, '
                + 'Opportunity__r.Name, '
                + 'Quote__c, '
                + (multiCurrency == true ? 'CurrencyIsoCode, ' : '')
                + '( '
                    + 'SELECT '
                        + entitlementFieldsString
                    + ' FROM Contract_Entitlements__r '
                + '), '
                + '( '
                    + 'SELECT Id, '
                        + 'CPQ_Playbook_Question__c, '
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c, '
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__r.CPQ_Playbook__c, '
                        + 'Value_Boolean__c, '
                        + 'Value_Currency__c, '
                        + 'Value_Date__c, '
                        + 'Value_Decimal__c, '
                        + 'Value_Integer__c, '
                        + 'Value_Text__c'
                    + ' FROM Contract_Playbook_Answers__r'
                + ') '
            + 'FROM Contract '
            + 'WHERE AccountId =:acctId '
            + 'ORDER BY Contract_Start_Date__c DESC, '
                + 'Contract_End_Date__c DESC, '
                + 'ContractNumber ';
        acctObj.Contracts = Database.query(contractQuery);

        if (multiCurrency == true) {
            List<sObject> currencies = new List<sObject>();
            currencies = Database.query('SELECT Id, ConversionRate, IsoCode FROM CurrencyType WHERE IsActive = TRUE AND IsCorporate = TRUE');
            if (currencies.size() > 0) {
                acctObj.defaultCurrency = (String) currencies[0].get('IsoCode');
            }   
        }
        
        if (acctObj.defaultCurrency == null) {
            acctObj.defaultCurrency = System.UserInfo.getDefaultCurrency();
        }

        return acctObj;
    }

    public class AccountObj {
        @AuraEnabled public Account acctInfo;
        @AuraEnabled public List<Contract> Contracts;
        @AuraEnabled public String defaultCurrency;
    }

    /**
    * @description Generic method to update a list of sObject records
    * @param records List of sObject records
    */
    @AuraEnabled
    public static void updateRecords(List<sObject> records) {
        update records;
    }
}
