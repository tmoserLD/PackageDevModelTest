/**
 * @author tmoser@launchdarkly.com
 * @date 1/6/2022
 *
 * @description Test class for TerritoryMapping class
 *
 */
@isTest
public class SearchControllerTest {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        // Generate test Accounts
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(
            new Account(
                Name = 'This is my favorite Account',
                BillingCountry = 'United States'
            )
        );
        testAccounts.add(
            new Account(
                Name = 'This is my best Account',
                BillingCountry = 'United States'
            )
        );
        testAccounts.add(
            new Account(
                Name = 'This is my biased Account',
                BillingCountry = 'Canada'
            )
        );
        testAccounts.add(
            new Account(
                Name = 'This is my beautiful Account',
                BillingCountry = 'Chad'
            )
        );
        testAccounts.add(
            new Account(
                Name = 'This is my united Account',
                BillingCountry = 'India'
            )
        );

        // Insert generated test Accounts
        insert testAccounts;

    }

    /**
     * @description 'Account'
     **/
    @isTest
    public static void testAccount() {

        List<Account> accounts = new List<Account>();

        Test.startTest();

        accounts = SearchController.search(
            'Account',
            new List<String>{'Name','BillingCountry'},
            'Account'
        );

        Test.stopTest();
    }

}
