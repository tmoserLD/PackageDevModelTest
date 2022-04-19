/**
 * @author Tristan Moser
 * @date 4/19/2022
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


        // Rules
        List<CPQ_Playbook_Rule__c> testRules = new List<CPQ_Playbook_Rule__c>();
        testRules.add(
            new CPQ_Playbook_Rule__c(
                CPQ_Playbook__c = testPlaybooks[0].Id,
                Execution_Order__c = 0,
                Evaluate_When__c = 'Always',
                IsActive__c = true,
                Name = 'Rule ' + 0
            )
        );
        insert testRules;


        // Rule Actions
        List<CPQ_Playbook_Rule_Action__c> testRuleActions = new List<CPQ_Playbook_Rule_Action__c>();
        testRuleActions.add(
            new CPQ_Playbook_Rule_Action__c(
                Action_Type__c = 'Adjust product field',
                CPQ_Playbook_Rule__c = testRules[0].Id,
                Execution_Order__c = 0,
                IsActive__c = true,
                Name = 'Action ' + 0,
                Product_Adjustment_Field__c = 'Description',
                Product_Adjustment_Field_Type__c = 'Text',
                Value_Source_Type__c = 'Static'
            )
        );
        insert testRuleActions;


        // Approvals
        List<CPQ_Playbook_Approval__c> testApprovals = new List<CPQ_Playbook_Approval__c>();
        testApprovals.add(
            new CPQ_Playbook_Approval__c(
                CPQ_Playbook__c = testPlaybooks[0].Id,
                IsActive__c = true,
                Label__c = 'Approval 1',
                Name = 'Approval 1',
                Reason__c = 'Approval Reason'
            )
        );
        insert testApprovals;


        // Approver Groups
        List<CPQ_Playbook_Approver_Group__c> testApproverGroups = new List<CPQ_Playbook_Approver_Group__c>();
        testApproverGroups.add(
            new CPQ_Playbook_Approver_Group__c(
                Approval_Order__c = 1,
                Approvers_Required__c = 1,
                CPQ_Playbook_Approval__c = testApprovals[0].Id,
                IsActive__c = true,
                Name = 'Group 1'
            )
        );
        testApproverGroups.add(
            new CPQ_Playbook_Approver_Group__c(
                Approval_Order__c = 2,
                Approvers_Required__c = 2,
                CPQ_Playbook_Approval__c = testApprovals[0].Id,
                IsActive__c = true,
                Name = 'Group 2'
            )
        );
        insert testApproverGroups;


        // Approvers
        List<CPQ_Playbook_Approver__c> testApprovers = new List<CPQ_Playbook_Approver__c>();
        testApprovers.add(
            new CPQ_Playbook_Approver__c(
                Approver__c = System.UserInfo.getUserId(),
                CPQ_Playbook_Approver_Group__c = testApproverGroups[0].Id,
                IsActive__c = true,
                Manager_Approver__c = false,
                Name = 'Approver 1'
            )
        );
        testApprovers.add(
            new CPQ_Playbook_Approver__c(
                Approver__c = System.UserInfo.getUserId(),
                CPQ_Playbook_Approver_Group__c = testApproverGroups[0].Id,
                IsActive__c = true,
                Manager_Approver__c = false,
                Name = 'Approver 2'
            )
        );
        testApprovers.add(
            new CPQ_Playbook_Approver__c(
                Approver__c = System.UserInfo.getUserId(),
                CPQ_Playbook_Approver_Group__c = testApproverGroups[1].Id,
                IsActive__c = true,
                Manager_Approver__c = false,
                Name = 'Approver 1'
            )
        );
        testApprovers.add(
            new CPQ_Playbook_Approver__c(
                Approver__c = System.UserInfo.getUserId(),
                CPQ_Playbook_Approver_Group__c = testApproverGroups[1].Id,
                IsActive__c = true,
                Manager_Approver__c = false,
                Name = 'Approver 2'
            )
        );
        insert testApprovers;


        // Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;


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
            Adjustment_of_Contract__c = null,
            Adjustment_Type__c = null,
            CPQ_Playbook__c = testPlaybooks[0].Id,
            IsClone__c = false,
            Playbook_Status__c = 'Complete'
        );
        insert testQuote;


        // Quote Approval
        CPQ_Quote_Approval__c testQuoteApproval = new CPQ_Quote_Approval__c(
            CPQ_Playbook_Approval__c = testApprovals[0].Id,
            Status__c = 'Pending',
            Quote__c = testQuote.Id
        );
        insert testQuoteApproval;


        // Quote Approval Steps
        List<CPQ_Quote_Approval_Step__c> testQuoteApprovalSteps = new List<CPQ_Quote_Approval_Step__c>();
        testQuoteApprovalSteps.add(
            new CPQ_Quote_Approval_Step__c(
                CPQ_Playbook_Approver_Group__c = testApproverGroups[0].Id,
                Status__c = 'Pending',
                CPQ_Quote_Approval__c = testQuoteApproval.Id
            )
        );
        testQuoteApprovalSteps.add(
            new CPQ_Quote_Approval_Step__c(
                CPQ_Playbook_Approver_Group__c = testApproverGroups[1].Id,
                Status__c = 'Pending',
                CPQ_Quote_Approval__c = testQuoteApproval.Id
            )
        );
        insert testQuoteApprovalSteps;


        // Quote Approvers
        List<CPQ_Quote_Approver__c> testQuoteApprovers = new List<CPQ_Quote_Approver__c>();
        testQuoteApprovers.add(
            new CPQ_Quote_Approver__c(
                CPQ_Quote_Approval_Step__c = testQuoteApprovalSteps[0].Id,
                CPQ_Playbook_Approver__c = testApprovers[0].Id,
                Status__c = 'Pending',
                Approver__c = testApprovers[0].Approver__c
            )
        );
        testQuoteApprovers.add(
            new CPQ_Quote_Approver__c(
                CPQ_Quote_Approval_Step__c = testQuoteApprovalSteps[0].Id,
                CPQ_Playbook_Approver__c = testApprovers[1].Id,
                Status__c = 'Pending',
                Approver__c = testApprovers[1].Approver__c
            )
        );
        testQuoteApprovers.add(
            new CPQ_Quote_Approver__c(
                CPQ_Quote_Approval_Step__c = testQuoteApprovalSteps[1].Id,
                CPQ_Playbook_Approver__c = testApprovers[2].Id,
                Status__c = 'Pending',
                Approver__c = testApprovers[2].Approver__c
            )
        );
        testQuoteApprovers.add(
            new CPQ_Quote_Approver__c(
                CPQ_Quote_Approval_Step__c = testQuoteApprovalSteps[1].Id,
                CPQ_Playbook_Approver__c = testApprovers[3].Id,
                Status__c = 'Pending',
                Approver__c = testApprovers[3].Approver__c
            )
        );
        insert testQuoteApprovers;

    }

    /**
     * @description Test to verify Approvals query is successful for submitted when all are pending
     **/
    @isTest
    public static void testQueryApprovalsPending() {

        Test.startTest();

        cpq_ApprovalsHubClass.returnData data = cpq_ApprovalsHubClass.queryApprovals(
            'Submitted by',
            'Submitted',
            System.UserInfo.getUserId(), 
            Date.today()
        );

        Test.stopTest();

        System.assertEquals(0, data.opportunities.size());

    }

    /**
     * @description Test to verify Approvals query is successful for submitted when they exist
     **/
    @isTest
    public static void testQueryApprovalsSubmitted() {

        List<CPQ_Quote_Approver__c> approversToSubmit = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Playbook_Approver__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
        ];
        for (CPQ_Quote_Approver__c approver : approversToSubmit) {
            approver.Status__c = 'Submitted';
        }
        update approversToSubmit;

        Test.startTest();

        cpq_ApprovalsHubClass.returnData data = cpq_ApprovalsHubClass.queryApprovals(
            'Submitted by',
            'Submitted',
            System.UserInfo.getUserId(), 
            Date.today()
        );

        Test.stopTest();

        System.assertEquals(1, data.opportunities.size());

    }

    /**
     * @description Test to verify Approvals query is successful for submitted when they exist but since date is in future
     **/
    @isTest
    public static void testQueryApprovalsSubmittedFuture() {

        List<CPQ_Quote_Approver__c> approversToSubmit = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Playbook_Approver__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
        ];
        for (CPQ_Quote_Approver__c approver : approversToSubmit) {
            approver.Status__c = 'Submitted';
        }
        update approversToSubmit;

        Test.startTest();

        cpq_ApprovalsHubClass.returnData data = cpq_ApprovalsHubClass.queryApprovals(
            'Submitted by',
            'Submitted',
            System.UserInfo.getUserId(), 
            Date.today() + 5
        );

        Test.stopTest();

        System.assertEquals(0, data.opportunities.size());

    }

    /**
     * @description Test to verify Approvals query is successful for approved when they exist and null user provided
     **/
    @isTest
    public static void testQueryApprovalsApprovedNullUser() {

        List<CPQ_Quote_Approver__c> approversToApprove = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Playbook_Approver__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
        ];
        for (CPQ_Quote_Approver__c approver : approversToApprove) {
            approver.Status__c = 'Approved';
        }
        update approversToApprove;

        Test.startTest();

        cpq_ApprovalsHubClass.returnData data = cpq_ApprovalsHubClass.queryApprovals(
            'Submitted by',
            'Approved',
            null, 
            Date.today()
        );

        Test.stopTest();

        System.assertEquals(1, data.opportunities.size());

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
