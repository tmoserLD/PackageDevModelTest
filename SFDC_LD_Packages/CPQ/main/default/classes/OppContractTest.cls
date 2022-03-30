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
                    List_Price__c = index,
                    Product2Id = testProducts[index].Id,
                    PricebookEntryId = testEntries[index].Id,
                    Quantity__c = index + 1,
                    Quantity = index + 1,
                    Start_Date__c = (Date.today() - index),
                    Unit_Price__c = index,
                    UnitPrice = index,
                    QuoteId = testQuote.Id
                )
            );
        }
        insert testQLIs;

        // Contract Entitlements
        List<Contract_Entitlement__c> testEntitlements = new List<Contract_Entitlement__c>();
        for (Integer index = 0; index < testProducts.size(); index++) {
            testEntitlements.add(
                new Contract_Entitlement__c(
                    End_Date__c = (Date.today() - (1 + index)),
                    List_Price__c = index,
                    Product__c = testProducts[index].Id,
                    Quantity__c = index + 1,
                    Start_Date__c = (Date.today() - (1 + index)),
                    Unit_Price__c = index,
                    Contract__c = testContract.Id
                )
            );
        }
        insert testEntitlements;

        // Sync quote
        testOpportunity.SyncedQuoteId = testQuote.Id;
        update testOpportunity;

        // Update OLIs
        List<OpportunityLineItem> olis = [
            SELECT Id
            FROM OpportunityLineItem
            WHERE OpportunityId=:testOpportunity.Id
        ];
        for (Integer index = 0; index < olis.size(); index++) {
            olis[index].Quantity = testQLIs[index].Quantity__c;
            olis[index].UnitPrice = testQLIs[index].Unit_Price__c;
            olis[index].ServiceDate = (Date.today() + index);
        }
        update olis;
    }

    /**
     * @description Test to verify replacement contract creation
     **/
    @isTest
    public static void testCreateContractReplacement() {

        // Get Entitlement fields needed
        String entFieldsString = '';
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            entFieldsString += fm.Entitlement_Field__c + ',';
        }
        entFieldsString = entFieldsString.removeEnd(',');
        if (entFieldsString == '') {
            entFieldsString = 'Id';
        }

        String contractQuery = ''
            + 'SELECT Id,'
                + '('
                    + 'SELECT '
                    + entFieldsString 
                    + ' FROM Contract_Entitlements__r'
                + ')'
            + ' FROM Contract';
        Contract existingContract = Database.query(contractQuery);

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];
        Id testOppId = testOpp.Id;

        Quote testQuote = [
            SELECT Id,
                Adjustment_of_Contract__c,
                Adjustment_Type__c,
                CPQ_Playbook__c,
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

        // Opp Line Items

        // Get OLI fields needed
        String oliFieldsString = '';
        Set<String> oliFieldsSet = new Set<String>();
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            if (!oliFieldsSet.contains(fm.OpportunityLineItem_Field__c)) {
                oliFieldsSet.add(fm.OpportunityLineItem_Field__c);
                oliFieldsString += fm.OpportunityLineItem_Field__c + ',';
            }
        }
        oliFieldsString = oliFieldsString.removeEnd(',');
        if (oliFieldsString == '') {
            oliFieldsString = 'Id';
        }

        // Set query string
        String oppLinesQuery = ''
            + 'SELECT '
                + oliFieldsString
            + ' FROM OpportunityLineItem'
            + ' WHERE Product2.Do_Not_Create_Entitlement__c != true'
                + ' AND OpportunityId=:testOppId'
            + ' ORDER BY Product2Id';

        List<OpportunityLineItem> olis = Database.query(oppLinesQuery);

        Test.startTest();

        OppContractTriggerHandler.firstRunAfterUpdate = true;
        testOpp.Create_Contract__c = true;
        update testOpp;

        Test.stopTest();

        // Verify updates
        String newContractQuery = ''
            + 'SELECT Id,'
                + 'AccountId,'
                + 'Adjustment_of_Contract__c,'
                + 'Adjustment_Type__c,'
                + 'Opportunity__c,'
                + 'Quote__c,'
                + 'CPQ_Playbook__c,'
                + '('
                    + 'SELECT '
                        + entFieldsString
                        + ' FROM Contract_Entitlements__r'
                        + ' ORDER BY Product__c'
                + '),'
                + '('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'Name,'
                        + 'Value_Boolean__c,'
                        + 'Value_Currency__c,'
                        + 'Value_Date__c,'
                        + 'Value_Decimal__c,'
                        + 'Value_Integer__c,'
                        + 'Value_Text__c'
                    + ' FROM Contract_Playbook_Answers__r'
                    + ' ORDER BY CPQ_Playbook_Question__c'
                + ')'
            + ' FROM Contract'
            + ' WHERE Opportunity__c=:testOppId';

        Contract newContract = Database.query(newContractQuery);

        System.assertEquals(testQuote.Adjustment_of_Contract__c, newContract.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Adjustment_Type__c, newContract.Adjustment_Type__c);
        System.assertEquals(testQuote.Id, newContract.Quote__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, newContract.CPQ_Playbook__c);

        System.assertEquals(olis.size(), newContract.Contract_Entitlements__r.size());
        for (Integer index = 0; index < newContract.Contract_Entitlements__r.size(); index++) {
            for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
                System.assertEquals(olis[index].get(fm.OpportunityLineItem_Field__c), newContract.Contract_Entitlements__r[index].get(fm.Entitlement_Field__c));
            } 
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
                Contract_Status__c
            FROM Contract
            WHERE Id=:existingContract.Id
        ];
        System.assertEquals(newContract.Id, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals('Replaced', updatedContract.Contract_Status__c);

    }

    /**
     * @description Test to verify renewal contract creation
     **/
    @isTest
    public static void testCreateContractRenewal() {

        // Get Entitlement fields needed
        String entFieldsString = '';
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            entFieldsString += fm.Entitlement_Field__c + ',';
        }
        entFieldsString = entFieldsString.removeEnd(',');
        if (entFieldsString == '') {
            entFieldsString = 'Id';
        }

        String contractQuery = ''
            + 'SELECT Id,'
                + '('
                    + 'SELECT '
                    + entFieldsString 
                    + ' FROM Contract_Entitlements__r'
                + ')'
            + ' FROM Contract';
        Contract existingContract = Database.query(contractQuery);

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];
        Id testOppId = testOpp.Id;

        Quote testQuote = [
            SELECT Id,
                Adjustment_of_Contract__c,
                Adjustment_Type__c,
                CPQ_Playbook__c,
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
        testQuote.Adjustment_Type__c = 'Renewal';
        update testQuote;

        // Opp Line Items

        // Get OLI fields needed
        String oliFieldsString = '';
        Set<String> oliFieldsSet = new Set<String>();
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            if (!oliFieldsSet.contains(fm.OpportunityLineItem_Field__c)) {
                oliFieldsSet.add(fm.OpportunityLineItem_Field__c);
                oliFieldsString += fm.OpportunityLineItem_Field__c + ',';
            }
        }
        oliFieldsString = oliFieldsString.removeEnd(',');
        if (oliFieldsString == '') {
            oliFieldsString = 'Id';
        }

        // Set query string
        String oppLinesQuery = ''
            + 'SELECT '
                + oliFieldsString
            + ' FROM OpportunityLineItem'
            + ' WHERE Product2.Do_Not_Create_Entitlement__c != true'
                + ' AND OpportunityId=:testOppId'
            + ' ORDER BY Product2Id';

        List<OpportunityLineItem> olis = Database.query(oppLinesQuery);

        Test.startTest();

        OppContractTriggerHandler.firstRunAfterUpdate = true;
        testOpp.Create_Contract__c = true;
        update testOpp;

        Test.stopTest();

        // Verify updates
        String newContractQuery = ''
            + 'SELECT Id,'
                + 'AccountId,'
                + 'Adjustment_of_Contract__c,'
                + 'Adjustment_Type__c,'
                + 'Opportunity__c,'
                + 'Quote__c,'
                + 'CPQ_Playbook__c,'
                + '('
                    + 'SELECT '
                        + entFieldsString
                        + ' FROM Contract_Entitlements__r'
                        + ' ORDER BY Product__c'
                + '),'
                + '('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'Name,'
                        + 'Value_Boolean__c,'
                        + 'Value_Currency__c,'
                        + 'Value_Date__c,'
                        + 'Value_Decimal__c,'
                        + 'Value_Integer__c,'
                        + 'Value_Text__c'
                    + ' FROM Contract_Playbook_Answers__r'
                    + ' ORDER BY CPQ_Playbook_Question__c'
                + ')'
            + ' FROM Contract'
            + ' WHERE Opportunity__c=:testOppId';

        Contract newContract = Database.query(newContractQuery);

        System.assertEquals(testQuote.Adjustment_of_Contract__c, newContract.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Adjustment_Type__c, newContract.Adjustment_Type__c);
        System.assertEquals(testQuote.Id, newContract.Quote__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, newContract.CPQ_Playbook__c);

        System.assertEquals(olis.size(), newContract.Contract_Entitlements__r.size());
        for (Integer index = 0; index < newContract.Contract_Entitlements__r.size(); index++) {
            for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
                System.assertEquals(olis[index].get(fm.OpportunityLineItem_Field__c), newContract.Contract_Entitlements__r[index].get(fm.Entitlement_Field__c));
            } 
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
                Contract_Status__c
            FROM Contract
            WHERE Id=:existingContract.Id
        ];
        System.assertEquals(newContract.Id, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals('Renewed', updatedContract.Contract_Status__c);

    }

    /**
     * @description Test to verify amendment contract creation
     **/
    @isTest
    public static void testCreateContractAmendment() {

        // Get Entitlement fields needed
        String entFieldsString = '';
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            entFieldsString += fm.Entitlement_Field__c + ',';
        }
        entFieldsString = entFieldsString.removeEnd(',');
        if (entFieldsString == '') {
            entFieldsString = 'Id';
        }

        String contractQuery = ''
            + 'SELECT Id,'
                + '('
                    + 'SELECT '
                    + entFieldsString 
                    + ' FROM Contract_Entitlements__r'
                + ')'
            + ' FROM Contract';
        Contract existingContract = Database.query(contractQuery);

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];
        Id testOppId = testOpp.Id;

        Quote testQuote = [
            SELECT Id,
                Adjustment_of_Contract__c,
                Adjustment_Type__c,
                CPQ_Playbook__c,
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
        testQuote.Adjustment_Type__c = 'Amendment';
        update testQuote;

        // Opp Line Items

        // Get OLI fields needed
        String oliFieldsString = '';
        Set<String> oliFieldsSet = new Set<String>();
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            if (!oliFieldsSet.contains(fm.OpportunityLineItem_Field__c)) {
                oliFieldsSet.add(fm.OpportunityLineItem_Field__c);
                oliFieldsString += fm.OpportunityLineItem_Field__c + ',';
            }
        }
        oliFieldsString = oliFieldsString.removeEnd(',');
        if (oliFieldsString == '') {
            oliFieldsString = 'Id';
        }

        // Set query string
        String oppLinesQuery = ''
            + 'SELECT '
                + oliFieldsString
            + ' FROM OpportunityLineItem'
            + ' WHERE Product2.Do_Not_Create_Entitlement__c != true'
                + ' AND OpportunityId=:testOppId'
            + ' ORDER BY Product2Id';

        List<OpportunityLineItem> olis = Database.query(oppLinesQuery);

        Test.startTest();

        OppContractTriggerHandler.firstRunAfterUpdate = true;
        testOpp.Create_Contract__c = true;
        update testOpp;

        Test.stopTest();

        // Verify updates
        String newContractQuery = ''
            + 'SELECT Id,'
                + 'AccountId,'
                + 'Adjustment_of_Contract__c,'
                + 'Adjustment_Type__c,'
                + 'Opportunity__c,'
                + 'Quote__c,'
                + 'CPQ_Playbook__c,'
                + '('
                    + 'SELECT '
                        + entFieldsString
                        + ' FROM Contract_Entitlements__r'
                        + ' ORDER BY Product__c'
                + '),'
                + '('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'Name,'
                        + 'Value_Boolean__c,'
                        + 'Value_Currency__c,'
                        + 'Value_Date__c,'
                        + 'Value_Decimal__c,'
                        + 'Value_Integer__c,'
                        + 'Value_Text__c'
                    + ' FROM Contract_Playbook_Answers__r'
                    + ' ORDER BY CPQ_Playbook_Question__c'
                + ')'
            + ' FROM Contract'
            + ' WHERE Opportunity__c=:testOppId';

        Contract newContract = Database.query(newContractQuery);

        System.assertEquals(testQuote.Adjustment_of_Contract__c, newContract.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Adjustment_Type__c, newContract.Adjustment_Type__c);
        System.assertEquals(testQuote.Id, newContract.Quote__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, newContract.CPQ_Playbook__c);

        System.assertEquals((olis.size() + existingContract.Contract_Entitlements__r.size()), newContract.Contract_Entitlements__r.size());

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
                Contract_Status__c
            FROM Contract
            WHERE Id=:existingContract.Id
        ];
        System.assertEquals(newContract.Id, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals('Amended', updatedContract.Contract_Status__c);

    }

    /**
     * @description Test to verify on contract creation tripped without any upgrade
     **/
    @isTest
    public static void testCreateContractNoUpgrade() {

        // Get Entitlement fields needed
        String entFieldsString = '';
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            entFieldsString += fm.Entitlement_Field__c + ',';
        }
        entFieldsString = entFieldsString.removeEnd(',');
        if (entFieldsString == '') {
            entFieldsString = 'Id';
        }

        Opportunity testOpp = [
            SELECT Id,
                AccountId
            FROM Opportunity
        ];
        Id testOppId = testOpp.Id;

        Quote testQuote = [
            SELECT Id,
                Adjustment_of_Contract__c,
                Adjustment_Type__c,
                CPQ_Playbook__c,
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

        testQuote.Adjustment_of_Contract__c = null;
        update testQuote;

        // Opp Line Items

        // Get OLI fields needed
        String oliFieldsString = '';
        Set<String> oliFieldsSet = new Set<String>();
        for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
            if (!oliFieldsSet.contains(fm.OpportunityLineItem_Field__c)) {
                oliFieldsSet.add(fm.OpportunityLineItem_Field__c);
                oliFieldsString += fm.OpportunityLineItem_Field__c + ',';
            }
        }
        oliFieldsString = oliFieldsString.removeEnd(',');
        if (oliFieldsString == '') {
            oliFieldsString = 'Id';
        }

        // Set query string
        String oppLinesQuery = ''
            + 'SELECT '
                + oliFieldsString
            + ' FROM OpportunityLineItem'
            + ' WHERE Product2.Do_Not_Create_Entitlement__c != true'
                + ' AND OpportunityId=:testOppId'
            + ' ORDER BY Product2Id';

        List<OpportunityLineItem> olis = Database.query(oppLinesQuery);

        Test.startTest();

        OppContractTriggerHandler.firstRunAfterUpdate = true;
        testOpp.Create_Contract__c = true;
        update testOpp;

        Test.stopTest();

        // Verify updates
        String newContractQuery = ''
            + 'SELECT Id,'
                + 'AccountId,'
                + 'Adjustment_of_Contract__c,'
                + 'Adjustment_Type__c,'
                + 'Opportunity__c,'
                + 'Quote__c,'
                + 'CPQ_Playbook__c,'
                + '('
                    + 'SELECT '
                        + entFieldsString
                        + ' FROM Contract_Entitlements__r'
                        + ' ORDER BY Product__c'
                + '),'
                + '('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'Name,'
                        + 'Value_Boolean__c,'
                        + 'Value_Currency__c,'
                        + 'Value_Date__c,'
                        + 'Value_Decimal__c,'
                        + 'Value_Integer__c,'
                        + 'Value_Text__c'
                    + ' FROM Contract_Playbook_Answers__r'
                    + ' ORDER BY CPQ_Playbook_Question__c'
                + ')'
            + ' FROM Contract'
            + ' WHERE Opportunity__c=:testOppId';

        Contract newContract = Database.query(newContractQuery);

        System.assertEquals(testQuote.Adjustment_of_Contract__c, newContract.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Adjustment_Type__c, newContract.Adjustment_Type__c);
        System.assertEquals(testQuote.Id, newContract.Quote__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, newContract.CPQ_Playbook__c);

        System.assertEquals(olis.size(), newContract.Contract_Entitlements__r.size());
        for (Integer index = 0; index < newContract.Contract_Entitlements__r.size(); index++) {
            for (Entitlement_Field_Mapping__mdt fm : Entitlement_Field_Mapping__mdt.getAll().values()) {
                System.assertEquals(olis[index].get(fm.OpportunityLineItem_Field__c), newContract.Contract_Entitlements__r[index].get(fm.Entitlement_Field__c));
            } 
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
                Contract_Status__c
            FROM Contract
            WHERE Id!=:newContract.Id
        ];
        System.assertEquals(null, updatedContract.Adjusted_by_Contract__c);
        System.assertEquals('Past', updatedContract.Contract_Status__c);

    }
}
