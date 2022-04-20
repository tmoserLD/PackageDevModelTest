/**
* @author Tristan Moser
* @date 4/19/2022
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

        AccountObj acctObj = new AccountObj();

        Boolean multiCurrency = System.UserInfo.isMultiCurrencyOrganization();

        User currentUser = [
            SELECT Id,
                (
                    SELECT Id
                    FROM PermissionSetAssignments
                    WHERE PermissionSet.Name = 'CPQ_Contract_Admin'
                )
            FROM User
            WHERE Id=:System.UserInfo.getUserId()
        ];
        acctObj.isContractAdmin = currentUser.PermissionSetAssignments.size() > 0;

        // System Settings
        CPQ_System_Settings__c SystemSettings = [
            SELECT Id,
                Contract_Table_Actions__c,
                Contract_Table_Columns__c
            FROM CPQ_System_Settings__c
            LIMIT 1
        ];
        acctObj.SystemSettings = SystemSettings;

        acctObj.acctInfo = [
            SELECT Id,
                Name,
                Owner.Name
            FROM Account
            WHERE Id =:acctId
        ];

        // Contract Fields
        Set<String> contractFields = new Set<String>{
            'Id',
            'Adjusted_by_Contract__c',
            'Adjusted_by_Contract__r.ContractNumber',
            'Adjustment_of_Contract__c',
            'Adjustment_of_Contract__r.ContractNumber',
            'Adjustment_Type__c',
            'Contract_End_Date__c',
            'ContractNumber',
            'Contract_Start_Date__c',
            'Contract_Status__c',
            'Contract_Total__c',
            'CPQ_Playbook__c',
            'CPQ_Playbook__r.Default_Term_in_Months__c',
            'CPQ_Playbook__r.Label__c',
            'CPQ_Playbook__r.Pricebook__c',
            'Opportunity__c',
            'Opportunity__r.Name',
            'Quote__c'
        };

        if (multiCurrency == true) {
            contractFields.add('CurrencyIsoCode');
        }

        // Get fields from system settings
        for (String field : SystemSettings.Contract_Table_Columns__c.split(';')) {
            contractFields.add(field);
        }

        // Convert Set to String
        String contractFieldsString = '';
        for (String field : contractFields) {
            contractFieldsString += field + ',';
        }

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
            + 'SELECT '
                + contractFieldsString
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
            + 'ORDER BY Contract_End_Date__c DESC, '
                + 'Contract_Start_Date__c DESC, '
                + 'ContractNumber DESC';
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

        // Describe Contract object
        SObjectType contractType = ((SObject)(Type.forName('Schema.Contract').newInstance())).getSObjectType();
        DescribeSObjectResult contractObject = contractType.getDescribe();

        // Evaluate Quote Table Columns
        acctObj.ContractTableColumns = new List<ProductColumn>();
        for (String field : SystemSettings.Contract_Table_Columns__c.split(';')) {
            
            // Valid Contract field
            if (contractObject.fields
                .getMap()
                .containsKey(field)
            ) {
                ProductColumn newCol = new ProductColumn();
                newCol.label = contractObject.fields
                    .getMap()
                    .get(field)
                    .getDescribe()
                    .getLabel();
                newCol.field = field;
                Schema.DisplayType fieldType = contractObject.fields
                    .getMap()
                    .get(field)
                    .getDescribe()
                    .getType();

                if (fieldType == Schema.DisplayType.Boolean) {
                    newCol.type = 'Boolean';
                }
                else if (fieldType == Schema.DisplayType.Currency) {
                    newCol.type = 'Currency';
                }
                else if (fieldType == Schema.DisplayType.Date ||
                    fieldType == Schema.DisplayType.DateTime
                ) {
                    newCol.type = 'Date';
                }
                else if (fieldType == Schema.DisplayType.Double ||
                    fieldType == Schema.DisplayType.Integer ||
                    fieldType == Schema.DisplayType.Long
                ) {
                    newCol.type = 'Number';
                }
                else if (fieldType == Schema.DisplayType.Percent) {
                    newCol.type = 'Percent';
                }
                else {
                    newCol.type = 'Text';
                }

                acctObj.ContractTableColumns.add(newCol);
            }
        }

        return acctObj;
    }

    public class AccountObj {
        @AuraEnabled public Account acctInfo;
        @AuraEnabled public List<Contract> Contracts;
        @AuraEnabled public String defaultCurrency;
        @AuraEnabled public CPQ_System_Settings__c SystemSettings;
        @AuraEnabled public List<ProductColumn> ContractTableColumns;
        @AuraEnabled public Boolean isContractAdmin;
    }

    public class ProductColumn {
        @AuraEnabled public String label;
        @AuraEnabled public String field;
        @AuraEnabled public String type;
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
