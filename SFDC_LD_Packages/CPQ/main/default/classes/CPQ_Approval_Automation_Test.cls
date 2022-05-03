/**
 * @author Tristan Moser
 * @date 4/19/2022
 *
 * @description Test class for:
 *  - CPQ_Quote_Approval_Step_Trigger
 *  - CPQ_Quote_Approval_Step_TriggerHandler
 *  - CPQ_Quote_Approval_Step_UpdatesUtil
 *  - CPQ_Quote_Approver_Trigger
 *  - CPQ_Quote_Approver_TriggerHandler
 *  - CPQ_Quote_Approver_UpdatesUtil
 *
 */
@isTest
public class CPQ_Approval_Automation_Test {

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
                Entitlement_Summary_Columns__c = 'Quantity__c;End_Date__c',
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
     * @description Test to verify submitting approvers
     **/
    @isTest
    public static void testSubmitApprovers() {

        List<CPQ_Quote_Approver__c> testQuoteApprovers = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
        ];

        for (CPQ_Quote_Approver__c approver : testQuoteApprovers) {
            approver.Status__c = 'Submitted';
        }

        Test.startTest();

        update testQuoteApprovers;

        Test.stopTest();

        // Verify updates
        List<ProcessInstanceWorkItem> approvals = [
            SELECT Id,
                ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkItem
        ];

        System.assertEquals(2, approvals.size());
    }

    /**
     * @description Test to verify approve approver (enough to approve step)
     **/
    @isTest
    public static void testApproveApprover() {

        CPQ_Quote_Approver__c testQuoteApprover = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
            LIMIT 1
        ];

        testQuoteApprover.Status__c = 'Approved';

        Test.startTest();

        update testQuoteApprover;

        Test.stopTest();

        // Verify updates
        CPQ_Quote_Approval_Step__c testApprovalStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id =:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertEquals('Approved', testApprovalStep.Status__c);

        CPQ_Quote_Approver__c testOtherApproverStep1 = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1 AND
                Id !=:testQuoteApprover.Id
            LIMIT 1
        ];
        System.assertEquals('Recalled', testOtherApproverStep1.Status__c);

        CPQ_Quote_Approval_Step__c testNextStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id !=:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertEquals('Submitted', testNextStep.Status__c);

        List<CPQ_Quote_Approver__c> testNextStepApprovers = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 2
        ];
        for (CPQ_Quote_Approver__c approver : testNextStepApprovers) {
            System.assertEquals('Submitted', approver.Status__c);
        }
    }

    /**
     * @description Test to verify approve approver (NOT enough to approve step)
     **/
    @isTest
    public static void testApproveApprover2() {

        CPQ_Quote_Approver__c testQuoteApprover = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 2
            LIMIT 1
        ];

        testQuoteApprover.Status__c = 'Approved';

        Test.startTest();

        update testQuoteApprover;

        Test.stopTest();

        // Verify updates
        CPQ_Quote_Approval_Step__c testApprovalStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id =:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertNotEquals('Approved', testApprovalStep.Status__c);
    }

    /**
     * @description Test to verify approve approver (enough to approve last step)
     **/
    @isTest
    public static void testApproveApprovers3() {

        List<CPQ_Quote_Approver__c> testQuoteApprovers = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 2
        ];

        for (CPQ_Quote_Approver__c approver : testQuoteApprovers) {
            approver.Status__c = 'Approved';
        }

        Test.startTest();

        update testQuoteApprovers;

        Test.stopTest();

        // Verify updates
        CPQ_Quote_Approval_Step__c testApprovalStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Approval_Order__c = 2
        ];
        System.assertEquals('Approved', testApprovalStep.Status__c);

        CPQ_Quote_Approval__c testApproval = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval__c
        ];
        System.assertEquals('Approved', testApproval.Status__c);
    }

    /**
     * @description Test to verify reject approver (enough to reject step)
     **/
    @isTest
    public static void testRejectApprover() {

        List<CPQ_Quote_Approver__c> testQuoteApprovers = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
        ];
        Id stepId;

        for (CPQ_Quote_Approver__c approver : testQuoteApprovers) {
            approver.Status__c = 'Rejected';
            stepId = approver.CPQ_Quote_Approval_Step__c;
        }

        Test.startTest();

        update testQuoteApprovers;

        Test.stopTest();

        // Verify updates
        CPQ_Quote_Approval_Step__c testApprovalStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id =:stepId
        ];
        System.assertEquals('Rejected', testApprovalStep.Status__c);

        CPQ_Quote_Approval_Step__c testNextStep = [
            SELECT Id,
                Status__c,
                (
                    SELECT Id,
                        Status__c
                    FROM CPQ_Quote_Approvers__r
                )
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id !=:stepId
        ];
        System.assertEquals('Recalled', testNextStep.Status__c);
        for (CPQ_Quote_Approver__c approver : testNextStep.CPQ_Quote_Approvers__r) {
            System.assertEquals('Recalled', approver.Status__c);
        }

        CPQ_Quote_Approval__c testApproval = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval__c
        ];
        System.assertEquals('Rejected', testApproval.Status__c);
    }

    /**
     * @description Test to verify reject approver (NOT enough to reject step)
     **/
    @isTest
    public static void testRejectApprover2() {

        CPQ_Quote_Approver__c testQuoteApprover = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
            LIMIT 1
        ];

        testQuoteApprover.Status__c = 'Rejected';

        Test.startTest();

        update testQuoteApprover;

        Test.stopTest();

        // Verify updates
        CPQ_Quote_Approval_Step__c testApprovalStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id =:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertNotEquals('Rejected', testApprovalStep.Status__c);

        CPQ_Quote_Approval_Step__c testNextStep = [
            SELECT Id,
                Status__c,
                (
                    SELECT Id,
                        Status__c
                    FROM CPQ_Quote_Approvers__r
                )
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id !=:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertNotEquals('Recalled', testNextStep.Status__c);
        for (CPQ_Quote_Approver__c approver : testNextStep.CPQ_Quote_Approvers__r) {
            System.assertNotEquals('Recalled', approver.Status__c);
        }

        CPQ_Quote_Approval__c testApproval = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval__c
        ];
        System.assertNotEquals('Rejected', testApproval.Status__c);
    }

    /**
     * @description Test to verify recall approver
     **/
    @isTest
    public static void testRecallApprover() {

        CPQ_Quote_Approver__c testQuoteApprover = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
            LIMIT 1
        ];

        testQuoteApprover.Status__c = 'Submitted';
        update testQuoteApprover;

        testQuoteApprover.Status__c = 'Recalled';
        CPQ_Quote_Approver_UpdatesUtil.runStepUpdates = true;

        Test.startTest();

        update testQuoteApprover;

        Test.stopTest();

        // Verify updates
        CPQ_Quote_Approval_Step__c testApprovalStep = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id =:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertEquals('Recalled', testApprovalStep.Status__c);

        List<ProcessInstanceWorkItem> approvals = new List<ProcessInstanceWorkItem>();
        approvals = [
            SELECT Id,
                ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkItem
        ];
        System.assertEquals(0, approvals.size());

        CPQ_Quote_Approval_Step__c testNextStep = [
            SELECT Id,
                Status__c,
                (
                    SELECT Id,
                        Status__c
                    FROM CPQ_Quote_Approvers__r
                )
            FROM CPQ_Quote_Approval_Step__c
            WHERE Id !=:testQuoteApprover.CPQ_Quote_Approval_Step__c
        ];
        System.assertEquals('Recalled', testNextStep.Status__c);
        for (CPQ_Quote_Approver__c approver : testNextStep.CPQ_Quote_Approvers__r) {
            System.assertEquals('Recalled', approver.Status__c);
        }

        CPQ_Quote_Approval__c testApproval = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approval__c
        ];
        System.assertEquals('Recalled', testApproval.Status__c);
    }

    /**
     * @description Test to verify approve approver
     **/
    @isTest
    public static void testApproveApproverSubmitted() {

        CPQ_Quote_Approver__c testQuoteApprover = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
            LIMIT 1
        ];

        testQuoteApprover.Status__c = 'Submitted';

        update testQuoteApprover;

        Test.startTest();

        testQuoteApprover.Decision_Reason__c = 'Test text';
        testQuoteApprover.Status__c = 'Approved';
        update testQuoteApprover;

        Test.stopTest();

        // Verify updates
        List<ProcessInstanceWorkItem> approvalWorkItems = [
            SELECT Id
            FROM ProcessInstanceWorkItem
            WHERE ProcessInstance.TargetObjectId =:testQuoteApprover.Id
        ];
        System.assertEquals(0, approvalWorkItems.size());
    }

    /**
     * @description Test to verify reject approver
     **/
    @isTest
    public static void testRejectApproverSubmitted() {

        CPQ_Quote_Approver__c testQuoteApprover = [
            SELECT Id,
                CPQ_Quote_Approval_Step__c,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Playbook_Approver_Group__r.Approval_Order__c = 1
            LIMIT 1
        ];

        testQuoteApprover.Status__c = 'Submitted';

        update testQuoteApprover;

        Test.startTest();

        testQuoteApprover.Decision_Reason__c = 'Test text';
        testQuoteApprover.Status__c = 'Rejected';
        update testQuoteApprover;

        Test.stopTest();

        // Verify updates
        List<ProcessInstanceWorkItem> approvalWorkItems = [
            SELECT Id
            FROM ProcessInstanceWorkItem
            WHERE ProcessInstance.TargetObjectId =:testQuoteApprover.Id
        ];
        System.assertEquals(0, approvalWorkItems.size());
    }
}
