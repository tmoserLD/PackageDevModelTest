/**
 * @author Tristan Moser
 * @date 4/19/2022
 *
 * @description Test class for CPQ_Record_Validation class
 *
 */
@isTest
public class CPQ_Record_Validation_Test {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        Integer testSize = 2;

        // System Settings
        CPQ_System_Settings__c systemSettings = new CPQ_System_Settings__c(
            Contract_Table_Actions__c = 'View',
            Contract_Table_Columns__c = 'ContractNumber;Contract_Start_Date__c;Contract_Total__c;ContractTerm;isVoid__c',
            Default_Playbook__c = null,
            Quote_Table_Actions__c = 'View',
            Quote_Table_Columns__c = 'Name;Shell_Quote__c;Total_Price__c;End_Date__c;Discount'
        );
        insert systemSettings;

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
                    Entitlement_Summary_Columns__c = 'Quantity__c;End_Date__c',
                    IsActive__c = true,
                    Label__c = 'Playbook ' + i,
                    Name = 'Playbook ' + i,
                    Pricebook__c = testPricebooks[i].Id,
                    Product_Summary_Columns__c = 'Quantity;End_Date',
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
                    Answer_Type__c = 'Record Lookup',
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
                    Variable_Name__c = 'Question ' + i,
                    Query_String__c = 'SELECT Id,Default_Value_Boolean__c,Default_Value_Decimal__c,Default_Value_Date__c,Default_Value_Currency__c,Default_Value_Text__c FROM CPQ_Playbook_Question__c'
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
        for (Integer i = 0; i < testSize; i++) {
            testRuleCalculationItems.add(
                new CPQ_Playbook_Rule_Calculation_Item__c(
                    Calculation_Source__c = 'Question',
                    CPQ_Playbook_Question__c = testQuestions[i].Id,
                    CPQ_Playbook_Rule_Action__c = testRuleActions[i].Id,
                    Entitlement_Calculation_Field__c = null,
                    Execution_Order__c = i,
                    IsActive__c = true,
                    Name = 'Entitlement ' + i,
                    Product__c = null,
                    Product_Calculation_Field__c = null,
                    Product_Calculation_Target_Rule_Action__c = null,
                    Product_Is_Entitlement__c = false,
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
                    Force_Page_Break_After__c = false,
                    Force_Page_Break_Before__c = false,
                    Inputs_Column_1__c = null,
                    Inputs_Column_2__c = null,
                    Inputs_Column_3__c = null,
                    Inputs_Font_Color__c = null,
                    Inputs_Font_Size__c = null,
                    IsActive__c = true,
                    Name = 'Section ' + i,
                    Record_Table_Query__c = null,
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
    }

    /**
     * @description Test to verify approval criterion updates
     **/
    @isTest
    public static void testApprovalCriterionEntitlementPass() {

        CPQ_Playbook_Approval_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Approval_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Quantity__c';
        criterion.Product_Is_Entitlement__c = true;
        criterion.Record_Lookup_Field__c = 'Default_Value_Boolean__c';

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify approval criterion updates
     **/
    @isTest
    public static void testApprovalCriterionProductPass() {

        CPQ_Playbook_Approval_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Approval_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Quantity__c';
        criterion.Product_Is_Entitlement__c = false;
        criterion.Record_Lookup_Field__c = 'Default_Value_Boolean__c';

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify approval criterion updates
     **/
    @isTest
    public static void testApprovalCriterionFail() {

        CPQ_Playbook_Approval_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Approval_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Nonsense';
        criterion.Product_Is_Entitlement__c = false;
        criterion.Record_Lookup_Field__c = 'Nonsense';

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify question updates
     **/
    @isTest
    public static void testQuestionPass() {

        CPQ_Playbook_Question__c question = [
            SELECT Id
            FROM CPQ_Playbook_Question__c
            LIMIT 1
        ];

        question.Record_Display_Fields__c = 'Name';
        question.Query_String__c = 'SELECT Id,Name FROM Quote';
        question.Quote_Save_Field__c = 'Playbook_Status__c';
        question.Default_Field_Value__c = 'Profile.Name';


        Test.startTest();

        Boolean failed = false;

        try {
            update question;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify question updates
     **/
    @isTest
    public static void testQuestionFail() {

        CPQ_Playbook_Question__c question = [
            SELECT Id
            FROM CPQ_Playbook_Question__c
            LIMIT 1
        ];

        question.Record_Display_Fields__c = 'Nonsense';
        question.Query_String__c = 'SELECT Id,Default_Value_Boolean__c,Nonsense FROM Nonsense';
        question.Quote_Save_Field__c = 'Nonsense';
        question.Default_Field_Value__c = 'Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update question;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify question updates
     **/
    @isTest
    public static void testQuestionFail2() {

        CPQ_Playbook_Question__c question = [
            SELECT Id
            FROM CPQ_Playbook_Question__c
            LIMIT 1
        ];

        question.Record_Display_Fields__c = 'Nonsense';
        question.Query_String__c = 'SELECT Id,Name FROM Quote';
        question.Quote_Save_Field__c = 'Nonsense';
        question.Default_Field_Value__c = 'Contract.Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update question;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify question updates
     **/
    @isTest
    public static void testQuestionFail3() {

        CPQ_Playbook_Question__c question = [
            SELECT Id
            FROM CPQ_Playbook_Question__c
            LIMIT 1
        ];

        question.Record_Display_Fields__c = 'Nonsense';
        question.Query_String__c = 'SELECT Id,Name FROM Quote';
        question.Quote_Save_Field__c = 'Nonsense';
        question.Default_Field_Value__c = 'Nonsense.Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update question;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify playbook updates
     **/
    @isTest
    public static void testPlaybookPass() {

        CPQ_Playbook__c playbook = [
            SELECT Id
            FROM CPQ_Playbook__c
            LIMIT 1
        ];

        playbook.Product_Summary_Columns__c = 'Product_Name';
        playbook.Entitlement_Summary_Columns__c = 'Start_Date__c;End_Date__c';
        playbook.Quote_View_Display_Fields__c = 'Name;Start_Date__c';
        playbook.Contract_View_Display_Fields__c = 'Contract_Status__c;ContractNumber';


        Test.startTest();

        Boolean failed = false;

        try {
            update playbook;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify playbook updates
     **/
    @isTest
    public static void testPlaybookFail() {

        CPQ_Playbook__c playbook = [
            SELECT Id
            FROM CPQ_Playbook__c
            LIMIT 1
        ];

        playbook.Product_Summary_Columns__c = 'Nonsense';
        playbook.Entitlement_Summary_Columns__c = 'Start_Date__c;Nonsense';
        playbook.Quote_View_Display_Fields__c = 'Name;Nonsense';
        playbook.Contract_View_Display_Fields__c = 'Contract_Status__c;Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update playbook;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify proposal criterion updates
     **/
    @isTest
    public static void testProposalCriterionEntitlementPass() {

        CPQ_Playbook_Proposal_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Quantity__c';
        criterion.Product_Is_Entitlement__c = true;

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify proposal criterion updates
     **/
    @isTest
    public static void testProposalCriterionProductPass() {

        CPQ_Playbook_Proposal_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Quantity__c';
        criterion.Product_Is_Entitlement__c = false;

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify proposal criterion updates
     **/
    @isTest
    public static void testProposalCriterionFail() {

        CPQ_Playbook_Proposal_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Nonsense';
        criterion.Product_Is_Entitlement__c = false;

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify proposal section updates
     **/
    @isTest
    public static void testProposalSectionPass() {

        CPQ_Playbook_Proposal_Section__c section = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            LIMIT 1
        ];

        section.Record_Table_Query__c = 'SELECT Id FROM QuoteLineItem WHERE quoteId=:quoteRecordId';


        Test.startTest();

        Boolean failed = false;

        try {
            update section;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify proposal section updates
     **/
    @isTest
    public static void testProposalSectionFail() {

        CPQ_Playbook_Proposal_Section__c section = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            LIMIT 1
        ];

        section.Record_Table_Query__c = 'Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update section;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify rule action updates
     **/
    @isTest
    public static void testRuleActionPass() {

        CPQ_Playbook_Rule_Action__c action = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Action__c
            LIMIT 1
        ];

        action.Product_Adjustment_Field__c = 'Discount';


        Test.startTest();

        Boolean failed = false;

        try {
            update action;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify rule action updates
     **/
    @isTest
    public static void testRuleActionFail() {

        CPQ_Playbook_Rule_Action__c action = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Action__c
            LIMIT 1
        ];

        action.Product_Adjustment_Field__c = 'Nonsense times 2';


        Test.startTest();

        Boolean failed = false;

        try {
            update action;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify rule calculation item updates
     **/
    @isTest
    public static void testRuleCalculationItemPass() {

        CPQ_Playbook_Rule_Calculation_Item__c item = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Calculation_Item__c
            LIMIT 1
        ];

        item.Product_Calculation_Field__c = 'Description';
        item.Entitlement_Calculation_Field__c = 'Contract__c';
        item.Record_Lookup_Field__c = 'Name';


        Test.startTest();

        Boolean failed = false;

        try {
            update item;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify rule calculation item updates
     **/
    @isTest
    public static void testRuleCalculationItemPass2() {

        CPQ_Playbook_Rule_Calculation_Item__c item = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Calculation_Item__c
            LIMIT 1
        ];

        item.Product_Calculation_Field__c = 'PricebookEntry.Product2Id';
        item.Entitlement_Calculation_Field__c = 'Product__r.Name';
        item.Record_Lookup_Field__c = 'Name';


        Test.startTest();

        Boolean failed = false;

        try {
            update item;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify rule calculation item updates
     **/
    @isTest
    public static void testRuleCalculationItemFail() {

        CPQ_Playbook_Rule_Calculation_Item__c item = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Calculation_Item__c
            LIMIT 1
        ];

        item.Product_Calculation_Field__c = 'PricebookEntry.Nonsense';
        item.Entitlement_Calculation_Field__c = 'Nonsense.Name';
        item.Record_Lookup_Field__c = 'Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update item;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify rule calculation item updates
     **/
    @isTest
    public static void testRuleCalculationItemFail2() {

        CPQ_Playbook_Rule_Calculation_Item__c item = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Calculation_Item__c
            LIMIT 1
        ];

        item.Product_Calculation_Field__c = 'Nonsense';
        item.Entitlement_Calculation_Field__c = 'Nonsense';
        item.Record_Lookup_Field__c = 'Nonsense';


        Test.startTest();

        Boolean failed = false;

        try {
            update item;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify rule criterion updates
     **/
    @isTest
    public static void testRuleCriterionEntitlementPass() {

        CPQ_Playbook_Rule_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Quantity__c';
        criterion.Product_Is_Entitlement__c = true;
        criterion.Record_Lookup_Field__c = 'Default_Value_Boolean__c';

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify rule criterion updates
     **/
    @isTest
    public static void testRuleCriterionProductPass() {

        CPQ_Playbook_Rule_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Quantity__c';
        criterion.Product_Is_Entitlement__c = false;
        criterion.Record_Lookup_Field__c = 'Default_Value_Boolean__c';

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify rule criterion updates
     **/
    @isTest
    public static void testRuleCriterionFail() {

        CPQ_Playbook_Rule_Criterion__c criterion = [
            SELECT Id
            FROM CPQ_Playbook_Rule_Criterion__c
            LIMIT 1
        ];

        criterion.Product_Field__c = 'Nonsense';
        criterion.Product_Is_Entitlement__c = false;
        criterion.Record_Lookup_Field__c = 'Nonsense';

        Test.startTest();

        Boolean failed = false;

        try {
            update criterion;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }

    /**
     * @description Test to verify system settings updates
     **/
    @isTest
    public static void testSystemSettingsPass() {

        CPQ_System_Settings__c systemSettings = [
            SELECT Id
            FROM CPQ_System_Settings__c
            LIMIT 1
        ];

        systemSettings.Quote_Table_Columns__c = 'Name;Playbook_Status__c';
        systemSettings.Contract_Table_Columns__c = 'ContractNumber;Contract_Status__c';

        Test.startTest();

        Boolean failed = false;

        try {
            update systemSettings;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(false, failed);
    }

    /**
     * @description Test to verify system settings updates
     **/
    @isTest
    public static void testSystemSettingsFail() {

        CPQ_System_Settings__c systemSettings = [
            SELECT Id
            FROM CPQ_System_Settings__c
            LIMIT 1
        ];

        systemSettings.Quote_Table_Columns__c = 'Name;Nonsense';
        systemSettings.Contract_Table_Columns__c = 'ContractNumber;Nonsense';

        Test.startTest();

        Boolean failed = false;

        try {
            update systemSettings;
        } catch (Exception e) {
            failed = true;
        }

        Test.stopTest();

        System.assertEquals(true, failed);
    }
}