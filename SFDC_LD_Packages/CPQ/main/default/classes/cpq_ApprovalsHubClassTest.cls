/**
 * @author Tristan Moser
 * @date 3/30/2022
 *
 * @description Test class for cpq_ApprovalsHubClass class
 *
 */
@isTest
public class cpq_ApprovalsHubClassTest {

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
    }

    /**
     * @description Test to verify Account query is successful
     **/
    @isTest
    public static void testQueryApprovals() {

        User testUser = [
            SELECT Id
            FROM User
            LIMIT 1
        ];

        Test.startTest();

        cpq_ApprovalsHubClass.queryApprovals('Submitted by', 'Submitted', testUser.Id);

        Test.stopTest();

    }

    /**
     * @description Test to verify AccountObj query is successful
     **/
    @isTest
    public static void testUpdate() {

        List<Account> testAccounts = [
            SELECT Id
            FROM Account
        ];

        Test.startTest();

        cpq_ApprovalsHubClass.updateRecords(testAccounts);

        Test.stopTest();
    }

}
