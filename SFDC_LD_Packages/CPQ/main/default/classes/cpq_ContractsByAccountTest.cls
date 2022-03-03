/**
 * @author Tristan Moser
 * @date 2/25/2022
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