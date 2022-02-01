/**
 * @author Tristan Moser
 * @date 1/12/2022
 *
 * @description Test class for:
 *  - OppContractTrigger
 *  - OppContractTriggerHandler
 *  - OppContractUtil
 *
 */
@isTest
public class OppContractTest {
    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        Integer testSize = 5;

        // Products
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 0; i < testSize; i++) {
            testProducts.add(
                new Product2(
                    Description = 'Product ' + i,
                    Family = 'Family',
                    IsActive = true,
                    Name = 'Product ' + i,
                    ProductCode = 'Product Code ' + i,
                    Do_Not_Create_Entitlement__c = (i < 2 ? true : false)
                )
            ); 
        }
        insert testProducts;


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


        // Pricebook Entries
        List<PricebookEntry> testEntries = new List<PricebookEntry>();
        for (Integer i = 0; i < testSize; i++) {
            testEntries.add(
                new PricebookEntry(
                    IsActive = true,
                    Dates_Editable__c = true,
                    Discountable__c = true,
                    UnitPrice = 1,
                    List_Price_Editable__c = true,
                    Manually_Addible__c = true,
                    Pricebook2Id = testPricebooks[0].Id,
                    Product2Id = testProducts[i].Id,
                    Quantity__c = 1,
                    Quantity_Editable__c = true,
                    Removable__c = true
                )
            ); 
        }
        insert testEntries;


        // Playbooks
        List<CPQ_Playbook__c> testPlaybooks = new List<CPQ_Playbook__c>();
        testPlaybooks.add(
            new CPQ_Playbook__c(
                Default_Term_in_Months__c = 12,
                Entitlement_Summary_Columns__c = 'Quantity;End_Date',
                IsActive__c = true,
                Label__c = 'Playbook 1',
                Name = 'Playbook 1',
                Pricebook__c = testPricebooks[0].Id,
                Product_Summary_Columns__c = 'Quantity;End_Date',
                Proposal_Header__c = 'Header Text',
                Proposal_Header_Type__c = 'Text',
                Proposal_Footer__c = 'Footer Text'
            )
        );
        insert testPlaybooks;


        // Question Groups
        List<CPQ_Playbook_Question_Group__c> testQuestionGroups = new List<CPQ_Playbook_Question_Group__c>();
        testQuestionGroups.add(
            new CPQ_Playbook_Question_Group__c(
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 1,
                IsActive__c = true,
                IsHidden__c = false,
                Label__c = 'Group 1',
                Name = 'Group 1'
            )
        );
        insert testQuestionGroups;


        // Questions
        List<CPQ_Playbook_Question__c> testQuestions = new List<CPQ_Playbook_Question__c>();
        for (Integer i = 0; i < testSize; i++) {
            testQuestions.add(
                new CPQ_Playbook_Question__c(
                    Answer_Type__c = 'Text',
                    CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                    Default_Field_Value__c = 'Account.Name',
                    Default_Value_Boolean__c = false,
                    Default_Value_Currency__c = 0,
                    Default_Value_Date__c = Date.today(),
                    Default_Value_Decimal__c = 0,
                    Default_Value_Integer__c = 0,
                    Default_Value_Text__c = 'Account Name',
                    Display_Order__c = i,
                    Help_Text__c = 'Help Text',
                    IsActive__c = true,
                    IsHidden__c = false,
                    IsReadOnly__c = false,
                    IsRequired__c = false,
                    Label__c = 'Question ' + i,
                    Maximum_Value__c = null,
                    Minimum_Value__c = null,
                    Name = 'Question ' + i,
                    Picklist_Answers__c = null,
                    Proposal_Label__c = null,
                    Quote_Save_Field__c = null,
                    Step_Value__c = null,
                    Variable_Name__c = 'Question ' + i
                )
            );
        }
        insert testQuestions;

        // Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Contract
        Contract testContract = new Contract(
            AccountId = testAccount.Id
        );
        insert testContract;

        // Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Qualification', 
            CloseDate = Date.today()
        );
        insert testOpportunity;

        // Quote
        Quote testQuote  = new Quote(
            OpportunityId = testOpportunity.Id,
            Pricebook2Id = testPricebooks[0].Id,
            Name = 'Test Quote',
            Adjustment_of_Contract__c = testContract.Id,
            Adjustment_Type__c = 'Replacement',
            CPQ_Playbook__c = testPlaybooks[0].Id,
            IsClone__c = false,
            Playbook_Status__c = 'Complete'
        );
        insert testQuote;

        // Answers
        List<CPQ_Playbook_Answer__c> testAnswers = new List<CPQ_Playbook_Answer__c>();
        for (CPQ_Playbook_Question__c question : testQuestions) {
            testAnswers.add(
                new CPQ_Playbook_Answer__c(
                    CPQ_Playbook_Question__c = question.Id,
                    HasBeenTouched__c = true,
                    Quote__c = testQuote.Id,
                    Value_Boolean__c = false,
                    Value_Currency__c = null,
                    Value_Date__c = null,
                    Value_Decimal__c = null,
                    Value_Integer__c = null,
                    Value_Text__c = null
                )
            );
        }
        insert testAnswers;

        // Quote Line Items
        List<QuoteLineItem> testQLIs = new List<QuoteLineItem>();
        for (Integer index = 0; index < testProducts.size(); index++) {
            testQLIs.add(
                new QuoteLineItem(
                    Discount__c = 0,
                    End_Date__c = (Date.today() + index),
                    List_Price__c = 0,
                    Product2Id = testProducts[index].Id,
                    PricebookEntryId = testEntries[index].Id,
                    Quantity__c = 1,
                    Quantity = 1,
                    Start_Date__c = (Date.today() - index),
                    Unit_Price__c = 0,
                    UnitPrice = 0,
                    QuoteId = testQuote.Id
                )
            );
        }
        insert testQLIs;

    }

    /**
     * @description Test to verify replacement contract creation
     **/
    @isTest
    public static void testCreateContractReplacement() {

        Contract existingContract = [
            SELECT Id
            FROM Contract
        ];

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];

        Quote testQuote = [
            SELECT Id,
                Adjustment_of_Contract__c,
                CPQ_Playbook__c,
                (
                    SELECT Id,
                        CPQ_Playbook_Rule_Action__c,
                        Discount__c,
                        End_Date__c,
                        List_Price__c,
                        Product2Id,
                        Product2.Do_Not_Create_Entitlement__c,
                        Quantity__c,
                        Unit_Price__c,
                        Start_Date__c,
                        TotalPrice
                    FROM QuoteLineItems
                    WHERE Product2.Do_Not_Create_Entitlement__c != true
                    ORDER BY Product2Id
                ),
                (
                    SELECT Id,
                        CPQ_Playbook_Question__c,
                        Name,
                        Value_Boolean__c,
                        Value_Currency__c,
                        Value_Date__c,
                        Value_Decimal__c,
                        Value_Integer__c,
                        Value_Text__c
                    FROM CPQ_Playbook_Answers__r
                )
            FROM Quote
        ];

        testOpp.Create_Contract__c = true;
        testOpp.SyncedQuoteId = testQuote.Id;

        Test.startTest();

        update testOpp;

        Test.stopTest();

        // Verify updates
        Contract newContract = [
            SELECT Id,
                AccountId,
                Adjustment_of_Contract__c,
                Opportunity__c,
                Quote__c,
                CPQ_Playbook__c,
                (
                    SELECT Id,
                        Discount__c,
                        End_Date__c,
                        List_Price__c,
                        Product__c,
                        Quantity__c,
                        Quote_Line_Item__c,
                        Start_Date__c,
                        Unit_Price__c,
                        CPQ_Playbook_Rule_Action__c
                    FROM Contract_Entitlements__r
                    ORDER BY Product__c
                ),
                (
                    SELECT Id,
                        CPQ_Playbook_Question__c,
                        Name,
                        Value_Boolean__c,
                        Value_Currency__c,
                        Value_Date__c,
                        Value_Decimal__c,
                        Value_Integer__c,
                        Value_Text__c
                    FROM Contract_Playbook_Answers__r
                    ORDER BY CPQ_Playbook_Question__c
                )
            FROM Contract
            WHERE Opportunity__c=:testOpp.Id
        ];

        System.assertEquals(testQuote.Adjustment_of_Contract__c, newContract.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Id, newContract.Quote__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, newContract.CPQ_Playbook__c);

        System.assertEquals(testQuote.QuoteLineItems.size(), newContract.Contract_Entitlements__r.size());
        for (Integer index = 0; index < newContract.Contract_Entitlements__r.size(); index++) {
            System.assertEquals(testQuote.QuoteLineItems[index].Id, newContract.Contract_Entitlements__r[index].Quote_Line_Item__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Discount__c, newContract.Contract_Entitlements__r[index].Discount__c);
            System.assertEquals(testQuote.QuoteLineItems[index].End_Date__c, newContract.Contract_Entitlements__r[index].End_Date__c);
            System.assertEquals(testQuote.QuoteLineItems[index].List_Price__c, newContract.Contract_Entitlements__r[index].List_Price__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Product2Id, newContract.Contract_Entitlements__r[index].Product__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Quantity__c, newContract.Contract_Entitlements__r[index].Quantity__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Start_Date__c, newContract.Contract_Entitlements__r[index].Start_Date__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Unit_Price__c, newContract.Contract_Entitlements__r[index].Unit_Price__c);
            System.assertEquals(testQuote.QuoteLineItems[index].CPQ_Playbook_Rule_Action__c, newContract.Contract_Entitlements__r[index].CPQ_Playbook_Rule_Action__c);
        }

        System.assertEquals(testQuote.CPQ_Playbook_Answers__r.size(), newContract.Contract_Playbook_Answers__r.size());
        for (Integer index = 0; index < newContract.Contract_Playbook_Answers__r.size(); index++) {
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].CPQ_Playbook_Question__c, newContract.Contract_Playbook_Answers__r[index].CPQ_Playbook_Question__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Name, newContract.Contract_Playbook_Answers__r[index].Name);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Boolean__c, newContract.Contract_Playbook_Answers__r[index].Value_Boolean__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Currency__c, newContract.Contract_Playbook_Answers__r[index].Value_Currency__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Date__c, newContract.Contract_Playbook_Answers__r[index].Value_Date__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Decimal__c, newContract.Contract_Playbook_Answers__r[index].Value_Decimal__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Integer__c, newContract.Contract_Playbook_Answers__r[index].Value_Integer__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Text__c, newContract.Contract_Playbook_Answers__r[index].Value_Text__c);
        }

        Contract updatedContract = [
            SELECT Id,
                Adjusted_by_Contract__c,
                IsReplaced__c
            FROM Contract
            WHERE Id=:existingContract.Id
        ];
        System.assertEquals(newContract.Id, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals(true, updatedContract.IsReplaced__c);

    }

    /**
     * @description Test to verify on renewal contract creation
     **/
    @isTest
    public static void testCreateContractOnRenewal() {

        Contract existingContract = [
            SELECT Id
            FROM Contract
        ];

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];

        Quote testQuote = [
            SELECT Id,
                Adjustment_of_Contract__c,
                CPQ_Playbook__c,
                (
                    SELECT Id,
                        CPQ_Playbook_Rule_Action__c,
                        Discount__c,
                        End_Date__c,
                        List_Price__c,
                        Product2Id,
                        Product2.Do_Not_Create_Entitlement__c,
                        Quantity__c,
                        Unit_Price__c,
                        Start_Date__c,
                        TotalPrice
                    FROM QuoteLineItems
                    WHERE Product2.Do_Not_Create_Entitlement__c != true
                    ORDER BY Product2Id
                ),
                (
                    SELECT Id,
                        CPQ_Playbook_Question__c,
                        Name,
                        Value_Boolean__c,
                        Value_Currency__c,
                        Value_Date__c,
                        Value_Decimal__c,
                        Value_Integer__c,
                        Value_Text__c
                    FROM CPQ_Playbook_Answers__r
                )
            FROM Quote
        ];
        testQuote.Adjustment_Type__c = 'On Renewal';
        update testQuote;

        testOpp.Create_Contract__c = true;
        testOpp.SyncedQuoteId = testQuote.Id;

        Test.startTest();

        update testOpp;

        Test.stopTest();

        // Verify updates
        Contract newContract = [
            SELECT Id,
                AccountId,
                Adjustment_of_Contract__c,
                Opportunity__c,
                Quote__c,
                CPQ_Playbook__c,
                (
                    SELECT Id,
                        Discount__c,
                        End_Date__c,
                        List_Price__c,
                        Product__c,
                        Quantity__c,
                        Quote_Line_Item__c,
                        Start_Date__c,
                        Unit_Price__c,
                        CPQ_Playbook_Rule_Action__c
                    FROM Contract_Entitlements__r
                    ORDER BY Product__c
                ),
                (
                    SELECT Id,
                        CPQ_Playbook_Question__c,
                        Name,
                        Value_Boolean__c,
                        Value_Currency__c,
                        Value_Date__c,
                        Value_Decimal__c,
                        Value_Integer__c,
                        Value_Text__c
                    FROM Contract_Playbook_Answers__r
                    ORDER BY CPQ_Playbook_Question__c
                )
            FROM Contract
            WHERE Opportunity__c=:testOpp.Id
        ];

        System.assertEquals(testQuote.Adjustment_of_Contract__c, newContract.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Id, newContract.Quote__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, newContract.CPQ_Playbook__c);

        System.assertEquals(testQuote.QuoteLineItems.size(), newContract.Contract_Entitlements__r.size());
        for (Integer index = 0; index < newContract.Contract_Entitlements__r.size(); index++) {
            System.assertEquals(testQuote.QuoteLineItems[index].Id, newContract.Contract_Entitlements__r[index].Quote_Line_Item__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Discount__c, newContract.Contract_Entitlements__r[index].Discount__c);
            System.assertEquals(testQuote.QuoteLineItems[index].End_Date__c, newContract.Contract_Entitlements__r[index].End_Date__c);
            System.assertEquals(testQuote.QuoteLineItems[index].List_Price__c, newContract.Contract_Entitlements__r[index].List_Price__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Product2Id, newContract.Contract_Entitlements__r[index].Product__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Quantity__c, newContract.Contract_Entitlements__r[index].Quantity__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Start_Date__c, newContract.Contract_Entitlements__r[index].Start_Date__c);
            System.assertEquals(testQuote.QuoteLineItems[index].Unit_Price__c, newContract.Contract_Entitlements__r[index].Unit_Price__c);
            System.assertEquals(testQuote.QuoteLineItems[index].CPQ_Playbook_Rule_Action__c, newContract.Contract_Entitlements__r[index].CPQ_Playbook_Rule_Action__c);
        }

        System.assertEquals(testQuote.CPQ_Playbook_Answers__r.size(), newContract.Contract_Playbook_Answers__r.size());
        for (Integer index = 0; index < newContract.Contract_Playbook_Answers__r.size(); index++) {
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].CPQ_Playbook_Question__c, newContract.Contract_Playbook_Answers__r[index].CPQ_Playbook_Question__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Name, newContract.Contract_Playbook_Answers__r[index].Name);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Boolean__c, newContract.Contract_Playbook_Answers__r[index].Value_Boolean__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Currency__c, newContract.Contract_Playbook_Answers__r[index].Value_Currency__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Date__c, newContract.Contract_Playbook_Answers__r[index].Value_Date__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Decimal__c, newContract.Contract_Playbook_Answers__r[index].Value_Decimal__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Integer__c, newContract.Contract_Playbook_Answers__r[index].Value_Integer__c);
            System.assertEquals(testQuote.CPQ_Playbook_Answers__r[index].Value_Text__c, newContract.Contract_Playbook_Answers__r[index].Value_Text__c);
        }

        Contract updatedContract = [
            SELECT Id,
                Adjusted_by_Contract__c,
                IsReplaced__c
            FROM Contract
            WHERE Id=:existingContract.Id
        ];
        System.assertEquals(newContract.Id, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals(false, updatedContract.IsReplaced__c);

    }

    /**
     * @description Test to verify on contract creation tripped without any synced quote
     **/
    @isTest
    public static void testCreateContractNoSyncedQuote() {

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];

        testOpp.Create_Contract__c = true;

        Test.startTest();

        update testOpp;

        Test.stopTest();

        // Verify updates
        List<Contract> emptyContractList = new List<Contract>();
        emptyContractList = [
            SELECT Id,
                AccountId,
                Adjustment_of_Contract__c,
                Opportunity__c,
                Quote__c,
                CPQ_Playbook__c,
                (
                    SELECT Id,
                        Discount__c,
                        End_Date__c,
                        List_Price__c,
                        Product__c,
                        Quantity__c,
                        Quote_Line_Item__c,
                        Start_Date__c,
                        Unit_Price__c,
                        CPQ_Playbook_Rule_Action__c
                    FROM Contract_Entitlements__r
                    ORDER BY Product__c
                ),
                (
                    SELECT Id,
                        CPQ_Playbook_Question__c,
                        Name,
                        Value_Boolean__c,
                        Value_Currency__c,
                        Value_Date__c,
                        Value_Decimal__c,
                        Value_Integer__c,
                        Value_Text__c
                    FROM Contract_Playbook_Answers__r
                    ORDER BY CPQ_Playbook_Question__c
                )
            FROM Contract
            WHERE Opportunity__c=:testOpp.Id
        ];

        System.assertEquals(0, emptyContractList.size());

        Contract updatedContract = [
            SELECT Id,
                Adjusted_by_Contract__c,
                IsReplaced__c
            FROM Contract
        ];
        System.assertEquals(null, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals(false, updatedContract.IsReplaced__c);

    }
}
