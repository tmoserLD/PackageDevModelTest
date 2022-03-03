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

        acctObj.Contracts = new List<Contract>();
        String contractQuery = ''
            + 'SELECT Id, '
                + 'Adjusted_by_Contract__c, '
                + 'Adjusted_by_Contract__r.ContractNumber, '
                + 'ContractNumber, '
                + 'Contract_Start_Date__c, '
                + 'Contract_End_Date__c, '
                + 'Contract_Status__c, '
                + 'Contract_Total__c, '
                + 'CPQ_Playbook__c, '
                + 'CPQ_Playbook__r.Label__c, '
                + 'Opportunity__c, '
                + 'Opportunity__r.Name, '
                + 'Quote__c, '
                + 'Quote__r.Name, '
                + (multiCurrency == true ? 'CurrencyIsoCode' : '')
                + '( '
                    + 'SELECT Id, '
                        + 'ContractNumber, '
                        + 'Contract_Status__c, '
                        + 'Contract_Total__c '
                    + 'FROM Source_Contracts__r '
                + '), '
                + '( '
                    + 'SELECT Id, '
                        + 'Discount__c, '
                        + 'End_Date__c, '
                        + 'List_Price__c, '
                        + 'Product__c, '
                        + 'Product_Name__c, '
                        + 'Quantity__c, '
                        + 'Start_Date__c, '
                        + 'SubTotal_Price__c, '
                        + 'Total_Price__c, '
                        + 'Unit_Price__c '
                    + 'FROM Contract_Entitlements__r '
                    + 'ORDER BY Start_Date__c DESC, '
                        + 'End_Date__c DESC, '
                        + 'Product_Name__c '
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
