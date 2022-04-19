/**
 * @author Tristan Moser
 * @date 4/19/2022
 *
 * @description Test class for cpq_AnyOppContainerClass class
 *
 */
@isTest
public class cpq_ContractsByAccountTest {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        // System Settings
        CPQ_System_Settings__c systemSettings = new CPQ_System_Settings__c(
            Contract_Table_Actions__c = 'View',
            Contract_Table_Columns__c = 'ContractNumber;Contract_Start_Date__c;Contract_Total__c;ContractTerm;isVoid__c',
            Default_Playbook__c = null,
            Quote_Table_Actions__c = 'View',
            Quote_Table_Columns__c = 'Name;Shell_Quote__c;Total_Price__c;End_Date__c;Discount'
        );
        insert systemSettings;

        // Pricebooks
        List<Pricebook2> testPricebooks = new List<Pricebook2>();
        testPricebooks.add(
            new Pricebook2(
                Id=Test.getStandardPricebookId(),
                Description = 'Standard Pricebook',
                IsActive = true
            )
        );
        update testPricebooks;

        // Playbooks
        List<CPQ_Playbook__c> testPlaybooks = new List<CPQ_Playbook__c>();
        testPlaybooks.add(
            new CPQ_Playbook__c(
                Default_Term_in_Months__c = 12,
                Entitlement_Summary_Columns__c = 'Quantity__c;End_Date__c',
                IsActive__c = true,
                Label__c = 'Playbook ' + 0,
                Name = 'Playbook ' + 0,
                Pricebook__c = testPricebooks[0].Id,
                Product_Summary_Columns__c = 'Quantity;End_Date',
                Proposal_Header__c = 'Header Text',
                Proposal_Header_Type__c = 'Text',
                Proposal_Footer__c = 'Footer Text'
            )
        );
        insert testPlaybooks;

        // Accounts
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(
            new Account(
                Name = 'Test Account'
            )
        );
        testAccounts.add(
            new Account(
                Name = 'Account for testing'
            )
        );
        testAccounts.add(
            new Account(
                Name = 'Something to test'
            )
        );
        insert testAccounts;

        // Contracts
        List<Contract> testContracts = new List<Contract>();
        testContracts.add(
            new Contract(
                AccountId = testAccounts[0].Id
            )
        );
        testContracts.add(
            new Contract(
                AccountId = testAccounts[0].Id
            )
        );
        testContracts.add(
            new Contract(
                AccountId = testAccounts[1].Id
            )
        );
        testContracts.add(
            new Contract(
                AccountId = testAccounts[1].Id
            )
        );
        testContracts.add(
            new Contract(
                AccountId = testAccounts[2].Id
            )
        );
        testContracts.add(
            new Contract(
                AccountId = testAccounts[2].Id
            )
        );
        insert testContracts;
    }

    /**
     * @description Test to verify Account query is successful
     **/
    @isTest
    public static void testQueryAccount() {

        Account testAccount = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        Test.startTest();

        cpq_ContractsByAccountClass.queryAccount(testAccount.Id);

        Test.stopTest();

        // Verify first in recently viewed
        List<Account> recentlyViewed = cpq_ContractsByAccountClass.getRecentlyViewed();
        System.assertEquals(testAccount.Id, recentlyViewed[0].Id);

    }

    /**
     * @description Test to verify AccountObj query is successful
     **/
    @isTest
    public static void testQueryAccountObj() {

        Account testAccount = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        Test.startTest();

        cpq_ContractsByAccountClass.AccountObj acctObj = cpq_ContractsByAccountClass.queryAccountWithContracts(testAccount.Id);

        Test.stopTest();
    }

    /**
     * @description Test to verify sObject update is successful
     **/
    @isTest
    public static void testUpdateAccounts() {

        List<Account> testAccounts = [
            SELECT Id
            FROM Account
        ];
        for (Account acct : testAccounts) {
            acct.Type = 'Prospect';
        }

        Test.startTest();

        cpq_ContractsByAccountClass.updateRecords(testAccounts);

        Test.stopTest();

        // Verify updates
        List<Account> updatedAccounts = [
            SELECT Id,
                Type
            FROM Account
        ];
        for (Account acct : updatedAccounts) {
            System.assertEquals('Prospect', acct.Type);
        }

    }

}