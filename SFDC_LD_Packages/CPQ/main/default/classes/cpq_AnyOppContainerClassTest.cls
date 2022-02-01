/**
 * @author Tristan Moser
 * @date 1/12/2022
 *
 * @description Test class for cpq_AnyOppContainerClass class
 *
 */
@isTest
public class cpq_AnyOppContainerClassTest {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        // Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;


        // Opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        testOpportunities.add(
            new Opportunity(
                Name = 'Test Opportunity 1',
                AccountId = testAccount.Id,
                StageName = 'Qualification', 
                CloseDate = Date.today()
            )
        );
        testOpportunities.add(
            new Opportunity(
                Name = 'Test Opportunity 2',
                AccountId = testAccount.Id,
                StageName = 'Qualification', 
                CloseDate = Date.today()
            )
        );
        testOpportunities.add(
            new Opportunity(
                Name = 'Test Opportunity 3',
                AccountId = testAccount.Id,
                StageName = 'Qualification', 
                CloseDate = Date.today()
            )
        );
        insert testOpportunities;
    }

    /**
     * @description Test to verify Opp query is successful
     **/
    @isTest
    public static void testQueryOpp() {

        Opportunity testOpp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Test.startTest();

        cpq_AnyOppContainerClass.queryOpp(testOpp.Id);

        Test.stopTest();

        // Verify first in recently viewed
        List<Opportunity> recentlyViewed = cpq_AnyOppContainerClass.getRecentlyViewed();
        System.assertEquals(testOpp.Id, recentlyViewed[0].Id);

    }

}