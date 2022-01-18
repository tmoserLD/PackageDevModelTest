/**
 * @author Tristan Moser
 * @date 1/12/2022
 *
 * @description Test class for cpq_AdminContainerClass class
 *
 */
@isTest
public class cpq_AdminContainerClassTest {

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
                    Entitlement_Summary_Columns__c = 'Quantity;End_Date',
                    IsActive__c = true,
                    Label__c = 'Playbook ' + i,
                    Name = 'Playbook ' + i,
                    Price_Book__c = testPricebooks[i].Id,
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
    }

    /**
     * @description Test to verify Playbooks query successfully
     **/
    @isTest
    public static void testQueryPlaybooks() {

        List<cpq_AdminContainerClass.PlaybookInfo> playbooks = new List<cpq_AdminContainerClass.PlaybookInfo>();

        Test.startTest();

        playbooks = cpq_AdminContainerClass.getPlaybooks();

        Test.stopTest();
    }

    /**
     * @description Test to verify Pricebooks query successfully
     **/
    @isTest
    public static void testQueryPricebooks() {

        List<Pricebook2> pricebooks = new List<Pricebook2>();

        Test.startTest();

        pricebooks = cpq_AdminContainerClass.getPricebooks();

        Test.stopTest();
    }

    /**
     * @description Test to verify Products query successfully
     **/
    @isTest
    public static void testQueryProducts() {

        List<Product2> products = new List<Product2>();

        Test.startTest();

        products = cpq_AdminContainerClass.getProducts();

        Test.stopTest();
    }

    /**
     * @description Test to verify Answer/Question Type retrieval
     **/
    @isTest
    public static void testQuestionType() {

        Test.startTest();

        for (CPQ_Playbook_Question__c question : [
            SELECT Id,
                Answer_Type__c
            FROM CPQ_Playbook_Question__c
        ]) {
            System.assertEquals(question.Answer_Type__c, cpq_AdminContainerClass.getQuestionType(question.Id));
        }

        Test.stopTest();
    }

    /**
     * @description Test to delete Playbooks
     **/
    @isTest
    public static void testDeletePlaybooks() {

        List<CPQ_Playbook__c> testPlaybooks = [
            SELECT Id
            FROM CPQ_Playbook__c
        ];

        Test.startTest();

        cpq_AdminContainerClass.deleteRecords(testPlaybooks);
        
        Test.stopTest();

        List<CPQ_Playbook__c> emptyPlaybookList = new List<CPQ_Playbook__c>();
        emptyPlaybookList = [
            SELECT Id
            FROM CPQ_Playbook__c
        ];

        System.assertEquals(0, emptyPlaybookList.size());
    }

    /**
     * @description Test to clone Question
     **/
    @isTest
    public static void testCloneQuestion() {

        CPQ_Playbook_Question__c testQuestion = [
            SELECT Id,
                Answer_Type__c,
                CPQ_Playbook_Question_Group__c,
                Default_Field_Value__c,
                Default_Value_Boolean__c,
                Default_Value_Currency__c,
                Default_Value_Date__c,
                Default_Value_Decimal__c,
                Default_Value_Integer__c,
                Default_Value_Text__c,
                Display_Order__c,
                Help_Text__c,
                IsActive__c,
                IsHidden__c,
                IsReadOnly__c,
                IsRequired__c,
                Label__c,
                Maximum_Value__c,
                Minimum_Value__c,
                Name,
                Picklist_Answers__c,
                Proposal_Label__c,
                Quote_Save_Field__c,
                Step_Value__c,
                Variable_Name__c
            FROM CPQ_Playbook_Question__c
            LIMIT 1
        ];

        Test.startTest();

        CPQ_Playbook_Question__c clonedQuestion = (CPQ_Playbook_Question__c) cpq_AdminContainerClass.cloneRecord(testQuestion.Id, 'CPQ_Playbook_Question__c');
        
        Test.stopTest();

        List<String> questionFields = new List<String>{
            'Answer_Type__c',
            'CPQ_Playbook_Question_Group__c',
            'Default_Field_Value__c',
            'Default_Value_Boolean__c',
            'Default_Value_Currency__c',
            'Default_Value_Date__c',
            'Default_Value_Decimal__c',
            'Default_Value_Integer__c',
            'Default_Value_Text__c',
            'Display_Order__c',
            'Help_Text__c',
            'IsActive__c',
            'IsHidden__c',
            'IsReadOnly__c',
            'IsRequired__c',
            'Label__c',
            'Maximum_Value__c',
            'Minimum_Value__c',
            'Picklist_Answers__c',
            'Proposal_Label__c',
            'Quote_Save_Field__c',
            'Step_Value__c'
        };

        // Verify cloned fields
        for (String field : questionFields) {
            System.assertEquals(testQuestion.get(field), clonedQuestion.get(field));
        }

        // Verify adjusted fields
        System.assertEquals('CLONE: ' + testQuestion.Name.left(73), clonedQuestion.Name);
        System.assertEquals('*' + testQuestion.Variable_Name__c, clonedQuestion.Variable_Name__c);
    }

}
