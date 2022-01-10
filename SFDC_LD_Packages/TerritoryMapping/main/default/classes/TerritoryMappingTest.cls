/**
 * @author tmoser@launchdarkly.com
 * @date 1/6/2022
 *
 * @description Test class for TerritoryMapping class
 *
 */
@isTest
public class TerritoryMappingTest {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        // Generate test Account
        Account testAccount = new Account(
            Name = 'Acct-#1',
            BillingCountry = 'India'
        );

        // Insert generated test Account
        insert testAccount;


        // Territory Mappings
        List<Territory_Mapping__c> mappings = new List<Territory_Mapping__c>();

        // Account Mapping (Active)
        mappings.add(
            new Territory_Mapping__c(
                Object__c = 'Account',
                Is_Active__c = true,
                Mapping_Name__c = 'Account Name: Active',
                Target_Field__c = 'Name',
                Evaluation_Order__c = 1
            )
        );

        // Account Mapping (Inactive)
        mappings.add(
            new Territory_Mapping__c(
                Object__c = 'Account',
                Is_Active__c = false,
                Mapping_Name__c = 'Account Name: Inactive',
                Target_Field__c = 'Name',
                Evaluation_Order__c = 1
            )
        );

        // Client Mapping (Active)
        mappings.add(
            new Territory_Mapping__c(
                Object__c = 'Client',
                Is_Active__c = true,
                Mapping_Name__c = 'Client Name: Active',
                Target_Field__c = 'Name',
                Evaluation_Order__c = 1
            )
        );

        insert mappings;


        // Condition Sets
        List<Territory_Mapping_Condition_Set__c> conditionSets = new List<Territory_Mapping_Condition_Set__c>();

        // Account Mapping (Active) Test 1 (Active)
        conditionSets.add(
            new Territory_Mapping_Condition_Set__c(
                Evaluation_Order__c = 1,
                Is_Active__c = true,
                Target_Value__c = 'Test 1',
                Territory_Mapping__c = mappings[0].Id
            )
        );

        // Account Mapping (Active) Test 2 (Inactive)
        conditionSets.add(
            new Territory_Mapping_Condition_Set__c(
                Evaluation_Order__c = 2,
                Is_Active__c = false,
                Target_Value__c = 'Test 2',
                Territory_Mapping__c = mappings[0].Id
            )
        );

        // Account Mapping (Active) Test 3 (Active)
        conditionSets.add(
            new Territory_Mapping_Condition_Set__c(
                Evaluation_Order__c = 3,
                Is_Active__c = true,
                Target_Value__c = 'Test 3',
                Territory_Mapping__c = mappings[0].Id
            )
        );

        // Account Mapping (Inactive) Test 4 (Active)
        conditionSets.add(
            new Territory_Mapping_Condition_Set__c(
                Evaluation_Order__c = 1,
                Is_Active__c = true,
                Target_Value__c = 'Test 4',
                Territory_Mapping__c = mappings[1].Id
            )
        );

        // Client Mapping (Active) Test 5 (Active)
        conditionSets.add(
            new Territory_Mapping_Condition_Set__c(
                Evaluation_Order__c = 1,
                Is_Active__c = true,
                Target_Value__c = 'Test 5',
                Territory_Mapping__c = mappings[2].Id
            )
        );

        insert conditionSets;


        // Conditions
        List<Territory_Mapping_Condition__c> conditions = new List<Territory_Mapping_Condition__c>();

        // Account Mapping (Active) Test 1 (Active) Condition 1 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = false,
                Eligible_Values__c = 'Panama;Mexico;Honduras',
                Is_Active__c = true,
                Source_Field__c = 'BillingCountry',
                Territory_Mapping_Condition_Set__c = conditionSets[0].Id
            )
        );

        // Account Mapping (Active) Test 1 (Active) Condition 2 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = true,
                Ineligible_Values__c = 'Veracruz',
                Is_Active__c = true,
                Source_Field__c = 'BillingState',
                Territory_Mapping_Condition_Set__c = conditionSets[0].Id
            )
        );

        // Account Mapping (Active) Test 2 (Inactive) Condition 1 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = false,
                Eligible_Values__c = 'Vietnam;Singapore',
                Is_Active__c = true,
                Source_Field__c = 'BillingCountry',
                Territory_Mapping_Condition_Set__c = conditionSets[1].Id
            )
        );

        // Account Mapping (Active) Test 3 (Active) Condition 1 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = true,
                Eligible_Values__c = 'United States;Canada',
                Is_Active__c = true,
                Source_Field__c = 'BillingCountry',
                Territory_Mapping_Condition_Set__c = conditionSets[2].Id
            )
        );

        // Account Mapping (Active) Test 3 (Active) Condition 2 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = true,
                Eligible_Values__c = 'Utah;Nebraska;New York;California;Montana',
                Is_Active__c = true,
                Source_Field__c = 'BillingState',
                Territory_Mapping_Condition_Set__c = conditionSets[2].Id
            )
        );

        // Account Mapping (Active) Test 3 (Active) Condition 3 (Inactive)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = true,
                Eligible_Values__c = 'Waco',
                Is_Active__c = false,
                Source_Field__c = 'BillingCity',
                Territory_Mapping_Condition_Set__c = conditionSets[2].Id
            )
        );

        // Account Mapping (Inactive) Test 4 (Active) Condition 1 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = false,
                Eligible_Values__c = 'Russia;Tibet;China',
                Is_Active__c = true,
                Source_Field__c = 'BillingCountry',
                Territory_Mapping_Condition_Set__c = conditionSets[3].Id
            )
        );

        // Client Mapping (Active) Test 5 (Active) Condition 1 (Active)
        conditions.add(
            new Territory_Mapping_Condition__c(
                Case_Insensitive__c = false,
                Eligible_Values__c = 'Chad;Egypt;Nigeria',
                Is_Active__c = true,
                Source_Field__c = 'BillingCountry',
                Territory_Mapping_Condition_Set__c = conditionSets[4].Id
            )
        );

        insert conditions;

    }

    /**
     * @description Test to verify Account update to Mexico
     **/
    @isTest
    public static void testAccountMexico() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'Mexico';
        testAccount.BillingState = 'Oaxaca';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Test 1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to mexico
     **/
    @isTest
    public static void testAccountMexicoLowerCase() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'mexico';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Acct-#1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to Mexico Veracruz
     **/
    @isTest
    public static void testAccountMexicoVeracruz() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'Mexico';
        testAccount.BillingState = 'Veracruz';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Acct-#1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to Vietnam
     **/
    @isTest
    public static void testAccountVietnam() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'Vietnam';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Acct-#1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to united States california
     **/
    @isTest
    public static void testAccountUnitedStatesUtah() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'united States';
        testAccount.BillingState = 'california';
        testAccount.BillingCity = 'Oakland';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Test 3', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to United States Alabama
     **/
    @isTest
    public static void testAccountUnitedStatesAlabama() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'United States';
        testAccount.BillingState = 'Alabama';
        testAccount.BillingCity = 'Waco';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Acct-#1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to Tibet
     **/
    @isTest
    public static void testAccountTibet() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'Tibet';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Acct-#1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to verify Account update to Nigeria
     **/
    @isTest
    public static void testAccountNigeria() {
        Account testAccount = [
            SELECT Id,
                BillingCountry,
                BillingCity,
                BillingState,
                Name
            FROM Account
            LIMIT 1
        ];
        testAccount.BillingCountry = 'Nigeria';

        Test.startTest();
        TerritoryMapping.evaluateMappings(testAccount, new Account(), 'Account');

        // Verify Updates
        System.assertEquals('Acct-#1', testAccount.Name);

        Test.stopTest();
    }

    /**
     * @description Test to query all mappings
     **/
    @isTest
    public static void testQueryAllMappings() {

        Test.startTest();

        List<TerritoryMapping.TerritoryMappingObj> accountMappings = TerritoryMapping.getAllMappings('Account');
        List<TerritoryMapping.TerritoryMappingObj> clientMappings = TerritoryMapping.getAllMappings('Client');

        Test.stopTest();
    }

    /**
     * @description Test to delete Mapping
     **/
    @isTest
    public static void testDeleteMapping() {

        Territory_Mapping__c testMapping = [
            SELECT Id
            FROM Territory_Mapping__c
            LIMIT 1
        ];
        Id testMappingId = testMapping.Id;

        Test.startTest();

        TerritoryMapping.deleteRecords(new List<Territory_Mapping__c>{testMapping});
        
        Test.stopTest();

        List<Territory_Mapping__c> emptyMappingList = new List<Territory_Mapping__c>();
        emptyMappingList = [
            SELECT Id
            FROM Territory_Mapping__c
            WHERE Id=:testMappingId
        ];

        System.assertEquals(0, emptyMappingList.size());
    }

    /**
     * @description Test to clone Mapping
     **/
    @isTest
    public static void testCloneMapping() {

        Territory_Mapping__c testMapping = [
            SELECT Id,
                Mapping_Name__c
            FROM Territory_Mapping__c
            LIMIT 1
        ];
        String mappingName = '%' + testMapping.Mapping_Name__c + '%';

        Test.startTest();

        TerritoryMapping.cloneRecord(testMapping.Id, 'Territory_Mapping__c');
        
        Test.stopTest();

        List<Territory_Mapping__c> mappingList = new List<Territory_Mapping__c>();
        mappingList = [
            SELECT Id,
                Mapping_Name__c
            FROM Territory_Mapping__c
            WHERE Mapping_Name__c LIKE:mappingName
        ];

        System.assertEquals(2, mappingList.size());
    }
}
