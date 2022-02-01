/**
 * @author Tristan Moser
 * @date 1/12/2022
 *
 * @description Test class for cpq_ConfigQuoteClass class
 *
 */
@isTest
public class cpq_ConfigQuoteClassTest {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        Integer testSize = 2;

        // Products
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 0; i < testSize; i++) {
            testProducts.add(
                new Product2(
                    Description = 'Product ' + i,
                    Family = 'Family',
                    IsActive = true,
                    Name = 'Product ' + i,
                    ProductCode = 'Product Code ' + i
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
        for (Integer i = 0; i < (testSize - 1); i++) {
            testPricebooks.add(
                new Pricebook2(
                    Description = 'Pricebook ' + i,
                    IsActive = true,
                    Name = 'Pricebook ' + i
                )
            ); 
        }
        upsert testPricebooks;


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
        for (Integer i = 0; i < testSize; i++) {
            testPlaybooks.add(
                new CPQ_Playbook__c(
                    Default_Term_in_Months__c = 12,
                    Entitlement_Summary_Columns__c = 'Quantity__c;Start_Date__c;End_Date__c;Discount__c;List_Price__c;Product_Name__c',
                    IsActive__c = true,
                    Label__c = 'Playbook ' + i,
                    Name = 'Playbook ' + i,
                    Pricebook__c = testPricebooks[i].Id,
                    Product_Summary_Columns__c = i == 0 ? 'Quantity;Unit_Price' : 'Description;Quantity__c;Start_Date;End_Date__c;Discount__c;List_Price__c;Product_Name__c',
                    Proposal_Header__c = 'Header Text',
                    Proposal_Header_Type__c = 'Text',
                    Proposal_Footer__c = 'Footer Text'
                )
            );
        }
        insert testPlaybooks;


        // Question Groups
        List<CPQ_Playbook_Question_Group__c> testQuestionGroups = new List<CPQ_Playbook_Question_Group__c>();
        for (Integer i = 0; i < testSize; i++) {
            testQuestionGroups.add(
                new CPQ_Playbook_Question_Group__c(
                    CPQ_Playbook__c = testPlaybooks[i].Id,
                    Display_Order__c = i,
                    IsActive__c = true,
                    IsHidden__c = false,
                    Label__c = 'Group ' + i,
                    Name = 'Group ' + i
                )
            );
        }
        insert testQuestionGroups;


        // Questions
        List<CPQ_Playbook_Question__c> testQuestions = new List<CPQ_Playbook_Question__c>();
        for (Integer i = 0; i < testSize; i++) {
            testQuestions.add(
                new CPQ_Playbook_Question__c(
                    Answer_Type__c = 'Text',
                    CPQ_Playbook_Question_Group__c = testQuestionGroups[i].Id,
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


        // Rules
        List<CPQ_Playbook_Rule__c> testRules = new List<CPQ_Playbook_Rule__c>();
        for (Integer i = 0; i < testSize; i++) {
            testRules.add(
                new CPQ_Playbook_Rule__c(
                    CPQ_Playbook__c = testPlaybooks[i].Id,
                    Execution_Order__c = i,
                    Evaluate_When__c = 'Always',
                    IsActive__c = true,
                    Name = 'Rule ' + i
                )
            );
        }
        insert testRules;


        // Rule Criteria Groups
        List<CPQ_Playbook_Rule_Criteria_Group__c> testRuleCriteriaGroups = new List<CPQ_Playbook_Rule_Criteria_Group__c>();
        for (Integer i = 0; i < testSize; i++) {
            testRuleCriteriaGroups.add(
                new CPQ_Playbook_Rule_Criteria_Group__c(
                    CPQ_Playbook_Rule__c = testRules[i].Id,
                    Evaluation_Logic__c = 'Required',
                    IsActive__c = true,
                    N__c = null,
                    Name = 'Group ' + i
                )
            );
        }
        insert testRuleCriteriaGroups;


        // Rule Criteria
        List<CPQ_Playbook_Rule_Criterion__c> testRuleCriteria = new List<CPQ_Playbook_Rule_Criterion__c>();
        for (Integer i = 0; i < testSize; i++) {
            testRuleCriteria.add(
                new CPQ_Playbook_Rule_Criterion__c(
                    Comparison_Operator__c = 'Equals',
                    Comparison_Value_Boolean__c = true,
                    Comparison_Value_Currency__c = 0,
                    Comparison_Value_Date__c = Date.today(),
                    Comparison_Value_Decimal__c = 0,
                    Comparison_Value_Integer__c = 0,
                    Comparison_Value_Text__c = 'Text',
                    CPQ_Playbook_Question__c = testQuestions[i].Id,
                    CPQ_Playbook_Rule_Criteria_Group__c = testRuleCriteriaGroups[i].Id,
                    Criterion_Source__c = 'Question',
                    Evaluation_Logic__c = 'Required',
                    IsActive__c = true,
                    N__c = null,
                    Name = 'Criterion ' + i,
                    Product__c = null,
                    Product_Criterion_Target_Rule_Action__c = null,
                    Product_Field__c = null,
                    Product_Is_Entitlement__c = false,
                    System_Value_Source__c = null,
                    Target_Manual_Addition_Only__c = false
                )
            );
        }
        insert testRuleCriteria;


        // Rule Actions
        List<CPQ_Playbook_Rule_Action__c> testRuleActions = new List<CPQ_Playbook_Rule_Action__c>();
        for (Integer i = 0; i < testSize; i++) {
            testRuleActions.add(
                new CPQ_Playbook_Rule_Action__c(
                    Action_Type__c = 'Adjust Question Field',
                    Calculation_Type__c = 'Add',
                    CPQ_Playbook_Question__c = testQuestions[i].Id,
                    CPQ_Playbook_Question_Group__c = null,
                    CPQ_Playbook_Rule__c = testRules[i].Id,
                    Execution_Order__c = i,
                    IsActive__c = true,
                    Name = 'Action ' + i,
                    Numeric_Math_Operator__c = null,
                    Product__c = null,
                    Product_Adjustment_Field__c = null,
                    Product_Adjustment_Field_Type__c = null,
                    Product_Adjustment_Target_Rule_Action__c = null,
                    Product_Field_Value_Boolean__c = false,
                    Product_Field_Value_Currency__c = null,
                    Product_Field_Value_Date__c = null,
                    Product_Field_Value_Decimal__c = null,
                    Product_Field_Value_Integer__c = null,
                    Product_Field_Value_Text__c = null,
                    Question_Adjustment_Field__c = 'IsHidden__c',
                    Question_Group_Adjustment_Field__c = null,
                    Question_Field_Value_Boolean__c = false,
                    Question_Field_Value_Currency__c = null,
                    Question_Field_Value_Date__c = null,
                    Question_Field_Value_Decimal__c = null,
                    Question_Field_Value_Integer__c = null,
                    Question_Field_Value_Text__c = null,
                    Target_Manual_Addition_Only__c = false,
                    Value_Source_Type__c = 'Dynamic'
                )
            );
        }
        insert testRuleActions;


        // Rule Calculation Items
        List<CPQ_Playbook_Rule_Calculation_Item__c> testRuleCalculationItems = new List<CPQ_Playbook_Rule_Calculation_Item__c>();
        for (Integer i = 0; i < (testSize + 2); i++) {
            testRuleCalculationItems.add(
                new CPQ_Playbook_Rule_Calculation_Item__c(
                    Calculation_Source__c = 'Product',
                    CPQ_Playbook_Question__c = null,
                    CPQ_Playbook_Rule_Action__c = (i > 1 ? testRuleActions[0].Id : testRuleActions[i].Id),
                    Entitlement_Calculation_Field__c = (i == 2 ? 'Product__r.Name' : 'Quantity__c'),
                    Execution_Order__c = i,
                    IsActive__c = true,
                    Name = 'Entitlement ' + i,
                    Product__c = (i > 1 ? testProducts[0].Id : testProducts[i].Id),
                    Product_Calculation_Field__c = (i == 0 ? 'Product2.Name' : 'PricebookEntry.Quantity__c'),
                    Product_Calculation_Target_Rule_Action__c = null,
                    Product_Is_Entitlement__c = (i > 1 ? true : false),
                    Static_Value_Boolean__c = false,
                    Static_Value_Currency__c = null,
                    Static_Value_Date__c = null,
                    Static_Value_Decimal__c = null,
                    Static_Value_Integer__c = null,
                    Static_Value_Text__c = null,
                    Static_Value_Type__c = null
                )
            );
        }
        insert testRuleCalculationItems;


        // Approvals
        List<CPQ_Playbook_Approval__c> testApprovals = new List<CPQ_Playbook_Approval__c>();
        for (Integer i = 0; i < testSize; i++) {
            testApprovals.add(
                new CPQ_Playbook_Approval__c(
                    CPQ_Playbook__c = testPlaybooks[i].Id,
                    IsActive__c = true,
                    Label__c = 'Approval ' + i,
                    Name = 'Approval ' + i,
                    Reason__c = 'Approval Reason'
                )
            );
        }
        insert testApprovals;


        // Approval Criteria Groups
        List<CPQ_Playbook_Approval_Criteria_Group__c> testApprovalCriteriaGroups = new List<CPQ_Playbook_Approval_Criteria_Group__c>();
        for (Integer i = 0; i < testSize; i++) {
            testApprovalCriteriaGroups.add(
                new CPQ_Playbook_Approval_Criteria_Group__c(
                    CPQ_Playbook_Approval__c = testApprovals[i].Id,
                    Evaluation_Logic__c = 'Required',
                    IsActive__c = true,
                    N__c = null,
                    Name = 'Group ' + i
                )
            );
        }
        insert testApprovalCriteriaGroups;


        // Approval Criteria
        List<CPQ_Playbook_Approval_Criterion__c> testApprovalCriteria = new List<CPQ_Playbook_Approval_Criterion__c>();
        for (Integer i = 0; i < testSize; i++) {
            testApprovalCriteria.add(
                new CPQ_Playbook_Approval_Criterion__c(
                    Comparison_Operator__c = 'Equals',
                    Comparison_Value_Boolean__c = true,
                    Comparison_Value_Currency__c = 0,
                    Comparison_Value_Date__c = Date.today(),
                    Comparison_Value_Decimal__c = 0,
                    Comparison_Value_Integer__c = 0,
                    Comparison_Value_Text__c = 'Text',
                    CPQ_Playbook_Question__c = testQuestions[i].Id,
                    CPQ_Playbook_Approval_Criteria_Group__c = testApprovalCriteriaGroups[i].Id,
                    Criterion_Source__c = 'Question',
                    Evaluation_Logic__c = 'Required',
                    IsActive__c = true,
                    N__c = null,
                    Name = 'Criterion ' + i,
                    Product__c = null,
                    Product_Criterion_Target_Rule_Action__c = null,
                    Product_Field__c = null,
                    Product_Is_Entitlement__c = false,
                    System_Value_Source__c = null,
                    Target_Manual_Addition_Only__c = false
                )
            );
        }
        insert testApprovalCriteria;


        // Approver Groups
        List<CPQ_Playbook_Approver_Group__c> testApproverGroups = new List<CPQ_Playbook_Approver_Group__c>();
        for (Integer i = 0; i < testSize; i++) {
            testApproverGroups.add(
                new CPQ_Playbook_Approver_Group__c(
                    Approval_Order__c = i,
                    Approvers_Required__c = 1,
                    CPQ_Playbook_Approval__c = testApprovals[i].Id,
                    IsActive__c = true,
                    Name = 'Group ' + i
                )
            );
        }
        insert testApproverGroups;


        // Approvers
        List<CPQ_Playbook_Approver__c> testApprovers = new List<CPQ_Playbook_Approver__c>();
        for (Integer i = 0; i < testSize; i++) {
            testApprovers.add(
                new CPQ_Playbook_Approver__c(
                    Approver__c = null,
                    CPQ_Playbook_Approver_Group__c = testApproverGroups[i].Id,
                    IsActive__c = true,
                    Manager_Approver__c = true,
                    Name = 'Approver ' + i
                )
            );
        }
        insert testApprovers;


        // Proposal Sections
        List<CPQ_Playbook_Proposal_Section__c> testProposalSections = new List<CPQ_Playbook_Proposal_Section__c>();
        for (Integer i = 0; i < testSize; i++) {
            testProposalSections.add(
                new CPQ_Playbook_Proposal_Section__c(
                    Allow_Mid_Section_Page_Break__c = false,
                    Answer_Table_Questions__c = null,
                    Body_Text_Block_1__c = 'Block 1 Text',
                    Body_Text_Block_2__c = null,
                    Body_Text_Block_3__c = null,
                    CPQ_Playbook__c = testPlaybooks[i].Id,
                    Display_Order__c = i,
                    Entitlement_Table_Fields__c = null,
                    Force_Page_Break_After__c = false,
                    Force_Page_Break_Before__c = false,
                    Inputs_Column_1__c = null,
                    Inputs_Column_2__c = null,
                    Inputs_Column_3__c = null,
                    Inputs_Font_Color__c = null,
                    Inputs_Font_Size__c = null,
                    IsActive__c = true,
                    Name = 'Section ' + i,
                    Product_Table_QLI_Fields__c = null,
                    Record_Table_Order_By_Clause__c = null,
                    Record_Table_Where_Clause__c = null,
                    Section_Type__c = 'Text - 1 column',
                    Table_Entries_Font_Color__c = null,
                    Table_Entries_Font_Size__c = null,
                    Table_Headers_Font_Color__c = null,
                    Table_Headers_Font_Size__c = null
                )
            );
        }
        insert testProposalSections;


        // Proposal Criteria Groups
        List<CPQ_Playbook_Proposal_Criteria_Group__c> testProposalCriteriaGroups = new List<CPQ_Playbook_Proposal_Criteria_Group__c>();
        for (Integer i = 0; i < testSize; i++) {
            testProposalCriteriaGroups.add(
                new CPQ_Playbook_Proposal_Criteria_Group__c(
                    CPQ_Playbook_Proposal_Section__c = testProposalSections[i].Id,
                    Evaluation_Logic__c = 'Required',
                    IsActive__c = true,
                    N__c = null,
                    Name = 'Group ' + i
                )
            );
        }
        insert testProposalCriteriaGroups;


        // Proposal Criteria
        List<CPQ_Playbook_Proposal_Criterion__c> testProposalCriteria = new List<CPQ_Playbook_Proposal_Criterion__c>();
        for (Integer i = 0; i < testSize; i++) {
            testProposalCriteria.add(
                new CPQ_Playbook_Proposal_Criterion__c(
                    Comparison_Operator__c = 'Equals',
                    Comparison_Value_Boolean__c = true,
                    Comparison_Value_Currency__c = null,
                    Comparison_Value_Date__c = null,
                    Comparison_Value_Decimal__c = null,
                    Comparison_Value_Integer__c = null,
                    Comparison_Value_Text__c = null,
                    CPQ_Playbook_Question__c = testQuestions[i].Id,
                    CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[i].Id,
                    Criterion_Source__c = 'Question',
                    Evaluation_Logic__c = 'Required',
                    IsActive__c = true,
                    N__c = null,
                    Name = 'Criterion ' + i,
                    Product__c = null,
                    Product_Criterion_Target_Rule_Action__c = null,
                    Product_Field__c = null,
                    Target_Manual_Addition_Only__c = false
                )
            );
        }
        insert testProposalCriteria;


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

    }

    /**
     * @description Test to verify Quote Configuration Data queries successfully when a contract is provided
     **/
    @isTest
    public static void testQueryQuoteConfigContract() {

        Contract testContract = [
            SELECT Id
            FROM Contract
            LIMIT 1
        ];
        cpq_ConfigQuoteClass.ConfigInfo configData = new cpq_ConfigQuoteClass.ConfigInfo();

        Test.startTest();

        configData = cpq_ConfigQuoteClass.getConfigInfo(testContract.Id);
        List<cpq_ConfigQuoteClass.ProductColumn> emptyProductColumnList = new List<cpq_ConfigQuoteClass.ProductColumn>();
        for (cpq_ConfigQuoteClass.PlaybookInfo playbook : configData.playbooks) {
            System.assert(playbook.entitlementColumns.size() > 0);
        }

        Test.stopTest();
    }

    /**
     * @description Test to verify Quote Configuration Data queries successfully when a contract is NOT provided
     **/
    @isTest
    public static void testQueryQuoteConfigNoContract() {

        cpq_ConfigQuoteClass.ConfigInfo configData = new cpq_ConfigQuoteClass.ConfigInfo();

        Test.startTest();

        configData = cpq_ConfigQuoteClass.getConfigInfo(null);
        List<cpq_ConfigQuoteClass.ProductColumn> emptyProductColumnList = new List<cpq_ConfigQuoteClass.ProductColumn>();
        for (cpq_ConfigQuoteClass.PlaybookInfo playbook : configData.playbooks) {
            System.assertEquals(emptyProductColumnList, playbook.entitlementColumns);
        }

        Test.stopTest();
    }

    /**
     * @description Test to verify Contract Data queries successfully
     **/
    @isTest
    public static void testQueryContract() {

        Contract testContract = [
            SELECT Id
            FROM Contract
            LIMIT 1
        ];
        Contract contractData = new Contract();

        Test.startTest();

        contractData = cpq_ConfigQuoteClass.getContractInfo(testContract.Id, 'Quantity__c,Start_Date__c,End_Date__c,Discount__c,List_Price__c,Product_Name__c');

        Test.stopTest();
    }

    /**
     * @description Test to verify Saving Quote Configuration saves successfully
     **/
    @isTest
    public static void testSaveNewQuote() {

        Opportunity testOpportunity = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Contract testContract = [
            SELECT Id
            FROM Contract
            LIMIT 1
        ];

        CPQ_Playbook__c testPlaybook = [
            SELECT Id
            FROM CPQ_Playbook__c
            LIMIT 1
        ];

        CPQ_Playbook_Rule_Action__c testRuleAction = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Action__c
            LIMIT 1
        ];

        CPQ_Playbook_Question__c testQuestion = [
            SELECT Id
            FROM CPQ_Playbook_Question__c
            LIMIT 1
        ];

        CPQ_Playbook_Approval__c testApproval = [
            SELECT Id
            FROM CPQ_Playbook_Approval__c
            LIMIT 1
        ];

        CPQ_Playbook_Approver_Group__c testApproverGroup = [
            SELECT Id
            FROM CPQ_Playbook_Approver_Group__c
            WHERE CPQ_Playbook_Approval__c=:testApproval.Id
            LIMIT 1
        ];

        CPQ_Playbook_Approver__c testApprover = [
            SELECT Id
            FROM CPQ_Playbook_Approver__c
            WHERE CPQ_Playbook_Approver_Group__c=:testApproverGroup.Id
            LIMIT 1
        ];

        PricebookEntry testPBE = [
            SELECT Id,
                Pricebook2Id
            FROM PricebookEntry
            LIMIT 1
        ];

        // New Quote
        Quote testQuote  = new Quote(
            OpportunityId = testOpportunity.Id,
            Pricebook2Id = testPBE.Pricebook2Id,
            Name = 'Test Quote',
            Adjustment_of_Contract__c = testContract.Id,
            Adjustment_Type__c = 'On Renewal',
            CPQ_Playbook__c = testPlaybook.Id,
            IsClone__c = false,
            Playbook_Status__c = 'Complete'
        );

        // New Quote Line Items
        List<QuoteLineItem> testQLIs = new List<QuoteLineItem>();
        testQLIs.add(
            new QuoteLineItem(
                Quantity = 1,
                PricebookEntryId = testPBE.Id,
                CPQ_Playbook_Rule_Action__c = testRuleAction.Id,
                Discount__c = 0,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today(),
                List_Price__c = 1,
                Quantity__c = 1,
                Unit_Price__c = 1,
                UnitPrice = 1
            )
        );

        // New Playbook Answers
        List<CPQ_Playbook_Answer__c> testAnswers = new List<CPQ_Playbook_Answer__c>();
        testAnswers.add(
            new CPQ_Playbook_Answer__c(
                CPQ_Playbook_Question__c = testQuestion.Id,
                HasBeenTouched__c = true,
                Value_Boolean__c = true
            )
        );

        // New Quote Approvals
        List<CPQ_Quote_Approval__c> testApprovals = new List<CPQ_Quote_Approval__c>();
        testApprovals.add(
            new CPQ_Quote_Approval__c(
                CPQ_Playbook_Approval__c = testApproval.Id,
                Status__c = 'Pending'
            )
        );

        // New Quote Approver Steps
        List<CPQ_Quote_Approval_Step__c> testApprovalStepsBase = new List<CPQ_Quote_Approval_Step__c>();
        testApprovalStepsBase.add(
            new CPQ_Quote_Approval_Step__c(
                CPQ_Playbook_Approver_Group__c = testApproverGroup.Id,
                Status__c = 'Pending'
            )
        );
        List<List<CPQ_Quote_Approval_Step__c>> testApprovalSteps = new List<List<CPQ_Quote_Approval_Step__c>>();
        testApprovalSteps.add(testApprovalStepsBase);

        // New Quote Approvers
        List<CPQ_Quote_Approver__c> testApproversBase = new List<CPQ_Quote_Approver__c>();
        testApproversBase.add(
            new CPQ_Quote_Approver__c(
                CPQ_Playbook_Approver__c = testApprover.Id,
                Status__c = 'Pending'
            )
        );
        List<List<CPQ_Quote_Approver__c>> testApproversSubBase = new List<List<CPQ_Quote_Approver__c>>();
        testApproversSubBase.add(testApproversBase);
        List<List<List<CPQ_Quote_Approver__c>>> testApprovers = new List<List<List<CPQ_Quote_Approver__c>>>();
        testApprovers.add(testApproversSubBase);


        Test.startTest();

        // Save initial quote data
        cpq_ConfigQuoteClass.saveQuoteConfiguration(
            testQuote,
            testQLIs,
            testAnswers,
            testApprovals,
            testApprovalSteps,
            testApprovers
        );

        // Remove Ids from child records
        for (QuoteLineItem qli : testQLIs) {
            qli.Id = null;
            qli.QuoteId = null;
        }
        for (CPQ_Playbook_Answer__c answer : testAnswers) {
            answer.Id = null;
            answer.Quote__c = null;
        }
        for (CPQ_Quote_Approval__c approval : testApprovals) {
            approval.Id = null;
            approval.Quote__c = null;

        }
        for (List<CPQ_Quote_Approval_Step__c> steps : testApprovalSteps) {
            for (CPQ_Quote_Approval_Step__c step : steps) {
                step.Id = null;
                step.CPQ_Quote_Approval__c = null;
            }
        }
        for (List<List<CPQ_Quote_Approver__c>> approverSet : testApprovers) {
            for (List<CPQ_Quote_Approver__c> approvers : approverSet) { 
                for (CPQ_Quote_Approver__c approver : approvers) {
                    approver.Id = null;
                    approver.CPQ_Quote_Approval_Step__c = null;
                }
            }
        }

        // Save quote data again with quote already existing
        cpq_ConfigQuoteClass.saveQuoteConfiguration(
            testQuote,
            testQLIs,
            testAnswers,
            testApprovals,
            testApprovalSteps,
            testApprovers
        );

        Test.stopTest();

        // Ensure records created and associated
        Quote createdQuote = [
            SELECT Id,
                (
                    SELECT Id
                    FROM QuoteLineItems
                ),
                (
                    SELECT Id
                    FROM CPQ_Playbook_Answers__r
                ),
                (
                    SELECT Id
                    FROM CPQ_Quote_Approvals__r
                )
            FROM Quote
        ];

        System.assert(createdQuote.QuoteLineItems.size() == 1);
        System.assert(createdQuote.CPQ_Playbook_Answers__r.size() == 1);
        System.assert(createdQuote.CPQ_Quote_Approvals__r.size() == 1);
    }
}
