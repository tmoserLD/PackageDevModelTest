/**
 * @author Tristan Moser
 * @date 1/12/2022
 *
 * @description Test class for cpq_ProposalPDF_Controller class
 *
 */
@isTest
public class cpq_ProposalPDF_ControllerTest {

    /**
     * @description setup test data for use in test cases.
     **/
    @testSetup
    public static void setup() {

        // Products
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
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
        update testPricebooks;


        // Pricebook Entries
        List<PricebookEntry> testEntries = new List<PricebookEntry>();
        for (Integer i = 0; i < 5; i++) {
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
                Entitlement_Summary_Columns__c = 'Quantity__c;End_Date__c;Discount__c;List_Price__c;Product_Name__c',
                IsActive__c = true,
                Label__c = 'Playbook 1',
                Name = 'Playbook 1',
                Price_Book__c = testPricebooks[0].Id,
                Product_Summary_Columns__c = 'Quantity__c;End_Date__c;Discount__c;List_Price__c;Product_Name__c',
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
        // Boolean
        testQuestions.add(
            new CPQ_Playbook_Question__c(
                Answer_Type__c = 'Boolean',
                CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                Default_Field_Value__c = null,
                Default_Value_Boolean__c = false,
                Default_Value_Currency__c = null,
                Default_Value_Date__c = null,
                Default_Value_Decimal__c = null,
                Default_Value_Integer__c = null,
                Default_Value_Text__c = null,
                Display_Order__c = 1,
                Help_Text__c = 'Help Text',
                IsActive__c = true,
                IsHidden__c = false,
                IsReadOnly__c = false,
                IsRequired__c = false,
                Label__c = 'Question 1',
                Maximum_Value__c = null,
                Minimum_Value__c = null,
                Name = 'Question 1',
                Picklist_Answers__c = null,
                Proposal_Label__c = 'Question 1',
                Quote_Save_Field__c = null,
                Step_Value__c = null,
                Variable_Name__c = 'Question 1'
            )
        );
        // Currency
        testQuestions.add(
            new CPQ_Playbook_Question__c(
                Answer_Type__c = 'Currency',
                CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                Default_Field_Value__c = null,
                Default_Value_Boolean__c = false,
                Default_Value_Currency__c = null,
                Default_Value_Date__c = null,
                Default_Value_Decimal__c = null,
                Default_Value_Integer__c = null,
                Default_Value_Text__c = null,
                Display_Order__c = 2,
                Help_Text__c = 'Help Text',
                IsActive__c = true,
                IsHidden__c = false,
                IsReadOnly__c = false,
                IsRequired__c = false,
                Label__c = 'Question 2',
                Maximum_Value__c = null,
                Minimum_Value__c = null,
                Name = 'Question 2',
                Picklist_Answers__c = null,
                Proposal_Label__c = 'Question 2',
                Quote_Save_Field__c = null,
                Step_Value__c = null,
                Variable_Name__c = 'Question 2'
            )
        );
        // Date
        testQuestions.add(
            new CPQ_Playbook_Question__c(
                Answer_Type__c = 'Date',
                CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                Default_Field_Value__c = null,
                Default_Value_Boolean__c = false,
                Default_Value_Currency__c = null,
                Default_Value_Date__c = null,
                Default_Value_Decimal__c = null,
                Default_Value_Integer__c = null,
                Default_Value_Text__c = null,
                Display_Order__c = 3,
                Help_Text__c = 'Help Text',
                IsActive__c = true,
                IsHidden__c = false,
                IsReadOnly__c = false,
                IsRequired__c = false,
                Label__c = 'Question 3',
                Maximum_Value__c = null,
                Minimum_Value__c = null,
                Name = 'Question 3',
                Picklist_Answers__c = null,
                Proposal_Label__c = 'Question 3',
                Quote_Save_Field__c = null,
                Step_Value__c = null,
                Variable_Name__c = 'Question 3'
            )
        );
        // Decimal
        testQuestions.add(
            new CPQ_Playbook_Question__c(
                Answer_Type__c = 'Decimal',
                CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                Default_Field_Value__c = null,
                Default_Value_Boolean__c = false,
                Default_Value_Currency__c = null,
                Default_Value_Date__c = null,
                Default_Value_Decimal__c = null,
                Default_Value_Integer__c = null,
                Default_Value_Text__c = null,
                Display_Order__c = 4,
                Help_Text__c = 'Help Text',
                IsActive__c = true,
                IsHidden__c = false,
                IsReadOnly__c = false,
                IsRequired__c = false,
                Label__c = 'Question 4',
                Maximum_Value__c = null,
                Minimum_Value__c = null,
                Name = 'Question 4',
                Picklist_Answers__c = null,
                Proposal_Label__c = 'Question 4',
                Quote_Save_Field__c = null,
                Step_Value__c = null,
                Variable_Name__c = 'Question 4'
            )
        );
        // Integer
        testQuestions.add(
            new CPQ_Playbook_Question__c(
                Answer_Type__c = 'Integer',
                CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                Default_Field_Value__c = null,
                Default_Value_Boolean__c = false,
                Default_Value_Currency__c = null,
                Default_Value_Date__c = null,
                Default_Value_Decimal__c = null,
                Default_Value_Integer__c = null,
                Default_Value_Text__c = null,
                Display_Order__c = 5,
                Help_Text__c = 'Help Text',
                IsActive__c = true,
                IsHidden__c = false,
                IsReadOnly__c = false,
                IsRequired__c = false,
                Label__c = 'Question 5',
                Maximum_Value__c = null,
                Minimum_Value__c = null,
                Name = 'Question 5',
                Picklist_Answers__c = null,
                Proposal_Label__c = 'Question 5',
                Quote_Save_Field__c = null,
                Step_Value__c = null,
                Variable_Name__c = 'Question 5'
            )
        );
        // Text Area
        testQuestions.add(
            new CPQ_Playbook_Question__c(
                Answer_Type__c = 'Text Area',
                CPQ_Playbook_Question_Group__c = testQuestionGroups[0].Id,
                Default_Field_Value__c = null,
                Default_Value_Boolean__c = false,
                Default_Value_Currency__c = null,
                Default_Value_Date__c = null,
                Default_Value_Decimal__c = null,
                Default_Value_Integer__c = null,
                Default_Value_Text__c = null,
                Display_Order__c = 6,
                Help_Text__c = 'Help Text',
                IsActive__c = true,
                IsHidden__c = false,
                IsReadOnly__c = false,
                IsRequired__c = false,
                Label__c = 'Question 6',
                Maximum_Value__c = null,
                Minimum_Value__c = null,
                Name = 'Question 6',
                Picklist_Answers__c = null,
                Proposal_Label__c = 'Question 6',
                Quote_Save_Field__c = null,
                Step_Value__c = null,
                Variable_Name__c = 'Question 6'
            )
        );
        insert testQuestions;


        // Proposal Sections
        List<CPQ_Playbook_Proposal_Section__c> testProposalSections = new List<CPQ_Playbook_Proposal_Section__c>();
        // Text - 3 columns
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = null,
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 1,
                Entitlement_Table_Fields__c = null,
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = null,
                Inputs_Column_2__c = null,
                Inputs_Column_3__c = null,
                Inputs_Font_Color__c = null,
                Inputs_Font_Size__c = null,
                IsActive__c = true,
                Name = 'Section 1',
                Product_Table_QLI_Fields__c = null,
                Record_Table_Order_By_Clause__c = null,
                Record_Table_Where_Clause__c = null,
                Section_Type__c = 'Text - 3 columns',
                Table_Entries_Font_Color__c = null,
                Table_Entries_Font_Size__c = null,
                Table_Headers_Font_Color__c = null,
                Table_Headers_Font_Size__c = null
            )
        );
        // Image and Text - 2 columns (1:3)
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = null,
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 2,
                Entitlement_Table_Fields__c = null,
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = null,
                Inputs_Column_2__c = null,
                Inputs_Column_3__c = null,
                Inputs_Font_Color__c = null,
                Inputs_Font_Size__c = null,
                IsActive__c = true,
                Name = 'Section 2',
                Product_Table_QLI_Fields__c = null,
                Record_Table_Order_By_Clause__c = null,
                Record_Table_Where_Clause__c = null,
                Section_Type__c = 'Image and Text - 2 columns (1:3)',
                Table_Entries_Font_Color__c = null,
                Table_Entries_Font_Size__c = null,
                Table_Headers_Font_Color__c = null,
                Table_Headers_Font_Size__c = null
            )
        );
        // Product Table
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = null,
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 3,
                Entitlement_Table_Fields__c = null,
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = null,
                Inputs_Column_2__c = null,
                Inputs_Column_3__c = null,
                Inputs_Font_Color__c = null,
                Inputs_Font_Size__c = null,
                IsActive__c = true,
                Name = 'Section 3',
                Product_Table_QLI_Fields__c = 'Quantity__c;End_Date__c;Discount__c;List_Price__c;Product_Name__c',
                Record_Table_Order_By_Clause__c = 'Product_Name__c',
                Record_Table_Where_Clause__c = 'Quantity__c > 0',
                Section_Type__c = 'Product Table',
                Table_Entries_Font_Color__c = 'blue',
                Table_Entries_Font_Size__c = '12px',
                Table_Headers_Font_Color__c = 'green',
                Table_Headers_Font_Size__c = '11px'
            )
        );
        // Entitlement Table
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = null,
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 4,
                Entitlement_Table_Fields__c = 'Quantity__c;End_Date__c;Discount__c;List_Price__c;Product_Name__c',
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = null,
                Inputs_Column_2__c = null,
                Inputs_Column_3__c = null,
                Inputs_Font_Color__c = null,
                Inputs_Font_Size__c = null,
                IsActive__c = true,
                Name = 'Section 4',
                Product_Table_QLI_Fields__c = null,
                Record_Table_Order_By_Clause__c = 'Product_Name__c',
                Record_Table_Where_Clause__c = 'Quantity__c > 0',
                Section_Type__c = 'Entitlement Table',
                Table_Entries_Font_Color__c = 'blue',
                Table_Entries_Font_Size__c = '12px',
                Table_Headers_Font_Color__c = 'green',
                Table_Headers_Font_Size__c = '11px'
            )
        );
        // Answer Table - 2 columns
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = 'Question 1;Question 2;Question 3;Question 4;Question 5;Question 6',
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 5,
                Entitlement_Table_Fields__c = null,
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = null,
                Inputs_Column_2__c = null,
                Inputs_Column_3__c = null,
                Inputs_Font_Color__c = null,
                Inputs_Font_Size__c = null,
                IsActive__c = true,
                Name = 'Section 5',
                Product_Table_QLI_Fields__c = null,
                Record_Table_Order_By_Clause__c = null,
                Record_Table_Where_Clause__c = null,
                Section_Type__c = 'Answer Table - 2 columns',
                Table_Entries_Font_Color__c = 'blue',
                Table_Entries_Font_Size__c = '12px',
                Table_Headers_Font_Color__c = 'green',
                Table_Headers_Font_Size__c = '11px'
            )
        );
        // User Input - 3 columns
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = null,
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 6,
                Entitlement_Table_Fields__c = null,
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = 'Name;Signature',
                Inputs_Column_2__c = 'Name;Signature',
                Inputs_Column_3__c = 'Name;Signature',
                Inputs_Font_Color__c = 'blue',
                Inputs_Font_Size__c = '12px',
                IsActive__c = true,
                Name = 'Section 6',
                Product_Table_QLI_Fields__c = null,
                Record_Table_Order_By_Clause__c = null,
                Record_Table_Where_Clause__c = null,
                Section_Type__c = 'User Input - 3 columns',
                Table_Entries_Font_Color__c = null,
                Table_Entries_Font_Size__c = null,
                Table_Headers_Font_Color__c = null,
                Table_Headers_Font_Size__c = null
            )
        );
        // User Input - 3 columns empty columns
        testProposalSections.add(
            new CPQ_Playbook_Proposal_Section__c(
                Allow_Mid_Section_Page_Break__c = false,
                Answer_Table_Questions__c = null,
                Body_Text_Block_1__c = 'Block 1 Text',
                Body_Text_Block_2__c = 'Block 2 Text',
                Body_Text_Block_3__c = 'Block 3 Text',
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Display_Order__c = 7,
                Entitlement_Table_Fields__c = null,
                Force_Page_Break_After__c = false,
                Force_Page_Break_Before__c = false,
                Inputs_Column_1__c = null,
                Inputs_Column_2__c = null,
                Inputs_Column_3__c = null,
                Inputs_Font_Color__c = 'blue',
                Inputs_Font_Size__c = '12px',
                IsActive__c = true,
                Name = 'Section 7',
                Product_Table_QLI_Fields__c = null,
                Record_Table_Order_By_Clause__c = null,
                Record_Table_Where_Clause__c = null,
                Section_Type__c = 'User Input - 3 columns',
                Table_Entries_Font_Color__c = null,
                Table_Entries_Font_Size__c = null,
                Table_Headers_Font_Color__c = null,
                Table_Headers_Font_Size__c = null
            )
        );
        insert testProposalSections;


        // Proposal Criteria Groups
        List<CPQ_Playbook_Proposal_Criteria_Group__c> testProposalCriteriaGroups = new List<CPQ_Playbook_Proposal_Criteria_Group__c>();
        // Text - 3 columns -- 2 required groups
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[0].Id,
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Group 1'
            )
        );
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[0].Id,
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Group 2'
            )
        );
        // Image and Text - 2 columns (1:3) -- only 1 of 2 groups
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[1].Id,
                Evaluation_Logic__c = 'One of N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Group 1'
            )
        );
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[1].Id,
                Evaluation_Logic__c = 'One of N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Group 2'
            )
        );
        // Product Table-- at least 1 of 2 groups
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[2].Id,
                Evaluation_Logic__c = 'One of at least N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Group 1'
            )
        );
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[2].Id,
                Evaluation_Logic__c = 'One of at least N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Group 2'
            )
        );
        // Entitlement Table-- at most 2 of 3 groups
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[3].Id,
                Evaluation_Logic__c = 'One of at most N required',
                IsActive__c = true,
                N__c = 2,
                Name = 'Group 1'
            )
        );
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[3].Id,
                Evaluation_Logic__c = 'One of at most N required',
                IsActive__c = true,
                N__c = 2,
                Name = 'Group 2'
            )
        );
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[3].Id,
                Evaluation_Logic__c = 'One of at most N required',
                IsActive__c = true,
                N__c = 2,
                Name = 'Group 3'
            )
        );
        // Answer Table - 2 columns -- 1 required group
        testProposalCriteriaGroups.add(
            new CPQ_Playbook_Proposal_Criteria_Group__c(
                CPQ_Playbook_Proposal_Section__c = testProposalSections[4].Id,
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Group 1'
            )
        );
        insert testProposalCriteriaGroups;


        // Proposal Criteria
        List<CPQ_Playbook_Proposal_Criterion__c> testProposalCriteria = new List<CPQ_Playbook_Proposal_Criterion__c>();
        // Text - 3 columns -- 1st group -- 1 required (Boolean Question)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = testQuestions[0].Id,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[0].Id,
                Criterion_Source__c = 'Question',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = null,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = null,
                Target_Manual_Addition_Only__c = false
            )
        );
        // Text - 3 columns -- 2nd group -- only 1 of 2 criteria (Currency Question)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = false,
                Comparison_Value_Currency__c = 0,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = testQuestions[1].Id,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[1].Id,
                Criterion_Source__c = 'Question',
                Evaluation_Logic__c = 'One of N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 1',
                Product__c = null,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = null,
                Target_Manual_Addition_Only__c = false
            )
        );
        // Text - 3 columns -- 2nd group -- only 1 of 2 criteria (Date Question)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Greater than or equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = testQuestions[2].Id,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[1].Id,
                Criterion_Source__c = 'Question',
                Evaluation_Logic__c = 'One of N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 2',
                Product__c = null,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = null,
                Target_Manual_Addition_Only__c = false
            )
        );
        // Image and Text - 2 columns (1:3) -- 1st group -- at least 1 of 2 criteria (Decimal Question)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Less than or equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = 10,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = testQuestions[3].Id,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[2].Id,
                Criterion_Source__c = 'Question',
                Evaluation_Logic__c = 'One of at least N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 1',
                Product__c = null,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = null,
                Target_Manual_Addition_Only__c = false
            )
        );

        // Image and Text - 2 columns (1:3) -- 1st group -- at least 1 of 2 criteria (Integer Question)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Is not empty',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = testQuestions[4].Id,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[2].Id,
                Criterion_Source__c = 'Question',
                Evaluation_Logic__c = 'One of at least N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 2',
                Product__c = null,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = null,
                Target_Manual_Addition_Only__c = false
            )
        );

        // Image and Text - 2 columns (1:3) -- 2nd group -- at most 1 of 3 criteria (Text Area Question)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Contains',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = 'Text',
                CPQ_Playbook_Question__c = testQuestions[5].Id,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[3].Id,
                Criterion_Source__c = 'Question',
                Evaluation_Logic__c = 'One of at most N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 1',
                Product__c = null,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = null,
                Target_Manual_Addition_Only__c = false
            )
        );

        // Image and Text - 2 columns (1:3) -- 2nd group -- at most 1 of 3 criteria (Product 0)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = 45,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[3].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'One of at most N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 2',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Quantity',
                Target_Manual_Addition_Only__c = true
            )
        );

        // Image and Text - 2 columns (1:3) -- 2nd group -- at most 1 of 3 criteria (Product 1)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = 10,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[3].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'One of at most N required',
                IsActive__c = true,
                N__c = 1,
                Name = 'Criterion 3',
                Product__c = testProducts[1].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Discount',
                Target_Manual_Addition_Only__c = true
            )
        );
        // Product Table-- 1st group -- required (Product 2)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 10,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[4].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = testProducts[2].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Unit Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        // Product Table-- 2nd group -- required (Product 3)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 10,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[5].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = testProducts[3].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'List Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        // Entitlement Table-- 1st group -- required (Product 0)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 100,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[6].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Total Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        // Entitlement Table-- 2nd group -- required (Product 0)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[7].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Start Date',
                Target_Manual_Addition_Only__c = true
            )
        );
        // Entitlement Table-- 3rd group -- required (Product 0)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Equals',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[8].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'End Date',
                Target_Manual_Addition_Only__c = true
            )
        );
        // Answer Table - 2 columns -- 1st group -- required (Product 0)
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = 45,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Quantity',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = 10,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 2',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Discount',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 10,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 3',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Unit Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 10,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 4',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'List Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 100,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 5',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Total Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 6',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Start Date',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 7',
                Product__c = testProducts[0].Id,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'End Date',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = 45,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 1e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Quantity',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = 10,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 2e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Discount',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 10,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 3e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Unit Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 10,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 4e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'List Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = 100,
                Comparison_Value_Date__c = null,
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 5e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Total Price',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 6e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'Start Date',
                Target_Manual_Addition_Only__c = true
            )
        );
        testProposalCriteria.add(
            new CPQ_Playbook_Proposal_Criterion__c(
                Comparison_Operator__c = 'Does not equal',
                Comparison_Value_Boolean__c = true,
                Comparison_Value_Currency__c = null,
                Comparison_Value_Date__c = Date.today(),
                Comparison_Value_Decimal__c = null,
                Comparison_Value_Integer__c = null,
                Comparison_Value_Text__c = null,
                CPQ_Playbook_Question__c = null,
                CPQ_Playbook_Proposal_Criteria_Group__c = testProposalCriteriaGroups[9].Id,
                Criterion_Source__c = 'Product',
                Evaluation_Logic__c = 'Required',
                IsActive__c = true,
                N__c = null,
                Name = 'Criterion 7e',
                Product__c = testProducts[0].Id,
                Product_Is_Entitlement__c = true,
                Product_Criterion_Target_Rule_Action__c = null,
                Product_Field__c = 'End Date',
                Target_Manual_Addition_Only__c = true
            )
        );

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

        // Quote
        Quote testQuote  = new Quote(
            OpportunityId = testOpportunity.Id,
            Pricebook2Id = testPricebooks[0].Id,
            Name = 'Test Quote',
            Adjustment_of_Contract__c = testContract.Id,
            Adjustment_Type__c = 'On Renewal',
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
                    End_Date__c = Date.today(),
                    List_Price__c = 0,
                    Product2Id = testProducts[index].Id,
                    PricebookEntryId = testEntries[index].Id,
                    Quantity__c = 1,
                    Quantity = 1,
                    Start_Date__c = Date.today(),
                    Quoted_Price__c = 0,
                    UnitPrice = 0,
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
                    Discount__c = 0,
                    End_Date__c = Date.today(),
                    List_Price__c = 0,
                    Product__c = testProducts[index].Id,
                    Quantity__c = 1,
                    Start_Date__c = Date.today(),
                    Unit_Price__c = 0,
                    Contract__c = testContract.Id
                )
            );
        }
        insert testEntitlements;
    }

    /**
     * @description Test to verify proposal with empty quote
     **/
    @isTest
    public static void testEmptyQuote() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        List<CPQ_Playbook_Answer__c> testAnswers = [
            SELECT Id
            FROM CPQ_Playbook_Answer__c
        ];
        delete testAnswers;

        List<QuoteLineItem> testQLIs = [
            SELECT Id
            FROM QuoteLineItem
        ];
        delete testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        Test.stopTest();
    }


    // Text - 3 columns TEST CASES 

    /**
     * @description Test to verify proposal with passing text section
     **/
    @isTest
    public static void testQuoteTextPass() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Text - 3 columns'
        ];

        List<CPQ_Playbook_Answer__c> testAnswers = [
            SELECT Id,
                CPQ_Playbook_Question__r.Answer_Type__c,
                Value_Boolean__c,
                Value_Currency__c,
                Value_Date__c
            FROM CPQ_Playbook_Answer__c
            WHERE CPQ_Playbook_Question__r.Answer_Type__c IN ('Boolean','Currency','Date')
        ];

        for (CPQ_Playbook_Answer__c answer : testAnswers) {
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean') {
                answer.Value_Boolean__c = true;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency') {
                answer.Value_Currency__c = 0;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date') {
                answer.Value_Date__c = Date.today();
            }
        }
        update testAnswers;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    /**
     * @description Test to verify proposal with failing text section
     **/
    @isTest
    public static void testQuoteTextFail() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Text - 3 columns'
        ];

        List<CPQ_Playbook_Answer__c> testAnswers = [
            SELECT Id,
                CPQ_Playbook_Question__r.Answer_Type__c,
                Value_Boolean__c,
                Value_Currency__c,
                Value_Date__c
            FROM CPQ_Playbook_Answer__c
            WHERE CPQ_Playbook_Question__r.Answer_Type__c IN ('Boolean','Currency','Date')
        ];

        for (CPQ_Playbook_Answer__c answer : testAnswers) {
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean') {
                answer.Value_Boolean__c = true;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency') {
                answer.Value_Currency__c = 25;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date') {
                answer.Value_Date__c = Date.today();
            }
        }
        update testAnswers;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(!contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    // Image and Text - 2 columns (1:3) TEST CASES

    /**
     * @description Test to verify proposal with passing image section
     **/
    @isTest
    public static void testQuoteImagePass() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Image and Text - 2 columns (1:3)'
        ];

        List<CPQ_Playbook_Answer__c> testAnswers = [
            SELECT Id,
                CPQ_Playbook_Question__r.Answer_Type__c,
                Value_Decimal__c,
                Value_Integer__c,
                Value_Text__c
            FROM CPQ_Playbook_Answer__c
            WHERE CPQ_Playbook_Question__r.Answer_Type__c IN ('Decimal','Integer','Text Area')
        ];
        for (CPQ_Playbook_Answer__c answer : testAnswers) {
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal') {
                answer.Value_Decimal__c = 11;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer') {
                answer.Value_Integer__c = null;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area') {
                answer.Value_Text__c = 'Text is a word in this string';
            }
        }
        update testAnswers;

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Quantity__c,
                Discount__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 0') {
                qli.Quantity__c = 1;
            }
            if (qli.Product2.Name == 'Product 1') {
                qli.Discount__c = 0;
            }
        }
        update testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    /**
     * @description Test to verify proposal with failing image section
     **/
    @isTest
    public static void testQuoteImageFail() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Image and Text - 2 columns (1:3)'
        ];

        List<CPQ_Playbook_Answer__c> testAnswers = [
            SELECT Id,
                CPQ_Playbook_Question__r.Answer_Type__c,
                Value_Decimal__c,
                Value_Integer__c,
                Value_Text__c
            FROM CPQ_Playbook_Answer__c
            WHERE CPQ_Playbook_Question__r.Answer_Type__c IN ('Decimal','Integer','Text Area')
        ];
        for (CPQ_Playbook_Answer__c answer : testAnswers) {
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal') {
                answer.Value_Decimal__c = 1;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer') {
                answer.Value_Integer__c = 14;
            }
            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area') {
                answer.Value_Text__c = 'Text is not a word in this string';
            }
        }
        update testAnswers;

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Quantity__c,
                Discount__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 0') {
                qli.Quantity__c = 44;
            }
            if (qli.Product2.Name == 'Product 1') {
                qli.Discount__c = 9;
            }
        }
        update testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(!contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    // Product Table TEST CASES

    /**
     * @description Test to verify proposal with passing product table section
     **/
    @isTest
    public static void testQuoteProductTablePass() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Product Table'
        ];

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Quoted_Price__c,
                List_Price__c,
                QuoteId
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 2') {
                qli.Quoted_Price__c = 10;
            }
            if (qli.Product2.Name == 'Product 3') {
                qli.List_Price__c = 10;
            }
        }
        update testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    /**
     * @description Test to verify proposal with failing product table section
     **/
    @isTest
    public static void testQuoteProductTableFail() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Product Table'
        ];

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Quoted_Price__c,
                List_Price__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 2') {
                qli.Quoted_Price__c = 0;
            }
            if (qli.Product2.Name == 'Product 3') {
                qli.List_Price__c = 0;
            }
        }
        update testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(!contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }


    // Entitlement Table TEST CASES

    /**
     * @description Test to verify proposal with passing entitlement table section
     **/
    @isTest
    public static void testQuoteEntitlementTablePass() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Entitlement Table'
        ];

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Quoted_Price__c,
                Start_Date__c,
                End_Date__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 0') {
                qli.Quoted_Price__c = 1;
                qli.Quantity__c = 1;
                qli.Start_Date__c = Date.today() - 1;
                qli.End_Date__c = Date.today() + 1;
            }
        }
        update testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    /**
     * @description Test to verify proposal with failing entitlement table section
     **/
    @isTest
    public static void testQuoteEntitlementTableFail() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Entitlement Table'
        ];

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Quoted_Price__c,
                Start_Date__c,
                End_Date__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 0') {
                qli.Quoted_Price__c = 100;
                qli.Quantity__c = 1;
                qli.Start_Date__c = Date.today();
                qli.End_Date__c = Date.today();
            }
        }
        update testQLIs;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(!contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }


    // Answer Table - 2 columns TEST CASES

    /**
     * @description Test to verify proposal with passing answer table section
     **/
    @isTest
    public static void testQuoteAnswerTablePass() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Answer Table - 2 columns'
        ];

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Discount__c,
                List_Price__c,
                Quoted_Price__c,
                Quantity__c,
                Start_Date__c,
                Total_Price__c,
                End_Date__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 0') {
                qli.Discount__c = 1; // 10
                qli.List_Price__c = 20; // 10
                qli.Quoted_Price__c = 18; // 10
                // qli.Total_Price__c = 18; // 100
                qli.Quantity__c = 1; // 45
                qli.Start_Date__c = Date.today() - 1; // Today
                qli.End_Date__c = Date.today() + 1; // Today
            }
        }
        update testQLIs;

        List<Contract_Entitlement__c> testEntitlements = [
            SELECT Id,
                Product__r.Name,
                Discount__c,
                List_Price__c,
                Unit_Price__c,
                Quantity__c,
                Start_Date__c,
                Total_Price__c,
                End_Date__c
            FROM Contract_Entitlement__c
        ];
        for (Contract_Entitlement__c ent : testEntitlements) {
            if (ent.Product__r.Name == 'Product 0') {
                ent.Discount__c = 1; // 10
                ent.List_Price__c = 20; // 10
                ent.Unit_Price__c = 18; // 10
                // ent.Total_Price__c = 18; // 100
                ent.Quantity__c = 1; // 45
                ent.Start_Date__c = Date.today() - 1; // Today
                ent.End_Date__c = Date.today() + 1; // Today
            }
        }
        update testEntitlements;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }

    /**
     * @description Test to verify proposal with failing answer table section
     **/
    @isTest
    public static void testQuoteAnswerTableFail() {

        Quote testQuote = [
            SELECT Id
            FROM Quote
            LIMIT 1
        ];

        CPQ_Playbook_Proposal_Section__c testSection = [
            SELECT Id
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE Section_Type__c = 'Answer Table - 2 columns'
        ];

        List<QuoteLineItem> testQLIs = [
            SELECT Id,
                Product2.Name,
                Discount__c,
                List_Price__c,
                Quoted_Price__c,
                Quantity__c,
                Start_Date__c,
                Total_Price__c,
                End_Date__c
            FROM QuoteLineItem
        ];
        for (QuoteLineItem qli : testQLIs) {
            if (qli.Product2.Name == 'Product 0') {
                qli.Discount__c = 10; // 10
                qli.List_Price__c = 10; // 10
                qli.Quoted_Price__c = 10; // 10
                // qli.Total_Price__c = 100; // 100
                qli.Quantity__c = 10; // 45
                qli.Start_Date__c = Date.today(); // Today
                qli.End_Date__c = Date.today(); // Today
            }
        }
        update testQLIs;

        List<Contract_Entitlement__c> testEntitlements = [
            SELECT Id,
                Product__r.Name,
                Discount__c,
                List_Price__c,
                Unit_Price__c,
                Quantity__c,
                Start_Date__c,
                Total_Price__c,
                End_Date__c
            FROM Contract_Entitlement__c
        ];
        for (Contract_Entitlement__c ent : testEntitlements) {
            if (ent.Product__r.Name == 'Product 0') {
                ent.Discount__c = 10; // 10
                ent.List_Price__c = 10; // 10
                ent.Unit_Price__c = 10; // 10
                // ent.Total_Price__c = 100; // 100
                ent.Quantity__c = 10; // 45
                ent.Start_Date__c = Date.today(); // Today
                ent.End_Date__c = Date.today(); // Today
            }
        }
        update testEntitlements;

        Test.startTest();

        Pagereference pg = Page.cpq_ProposalVF;
        Test.setCurrentPage(pg);
        pg.getParameters().put('quoteId', testQuote.Id);
        cpq_ProposalPDF_Controller cont = new cpq_ProposalPDF_Controller();

        // Verify sections
        String contSectionsPassed = cont.sectionsPassed;
        System.assert(!contSectionsPassed.split(';').contains(testSection.Id));

        Test.stopTest();
    }
}
