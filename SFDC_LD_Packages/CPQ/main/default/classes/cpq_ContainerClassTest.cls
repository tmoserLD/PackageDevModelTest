/**
 * @author Tristan Moser
 * @date 1/12/2022
 *
 * @description Test class for cpq_ContainerClass class
 *
 */
@isTest
public class cpq_ContainerClassTest {

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
        for (Integer i = 0; i < (testSize + 2); i++) {
            testQuestions.add(
                new CPQ_Playbook_Question__c(
                    Answer_Type__c = 'Text',
                    CPQ_Playbook_Question_Group__c = (i >= testSize ? testQuestionGroups[0].Id : testQuestionGroups[i].Id),
                    Default_Field_Value__c = (i == 0 ? 'User.FirstName' : (i == 1 ? 'Profile.Name' : (i == 2 ? 'UserRole.Name' : 'Account.Name'))),
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
            testApproverGroups.add(
                new CPQ_Playbook_Approver_Group__c(
                    Approval_Order__c = i + 1,
                    Approvers_Required__c = 1,
                    CPQ_Playbook_Approval__c = testApprovals[i].Id,
                    IsActive__c = true,
                    Name = 'Group ' + (i + 1)
                )
            );
        }
        insert testApproverGroups;


        // Approvers
        List<CPQ_Playbook_Approver__c> testApprovers = new List<CPQ_Playbook_Approver__c>();
        for (Integer i = 0; i < testSize; i++) {
            testApprovers.add(
                new CPQ_Playbook_Approver__c(
                    Approver__c = System.UserInfo.getUserId(),
                    CPQ_Playbook_Approver_Group__c = testApproverGroups[i].Id,
                    IsActive__c = true,
                    Manager_Approver__c = false,
                    Name = 'Approver ' + i
                )
            );
        }
        insert testApprovers;


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
     * @description Test to verify CPQ Data queries successfully as an unrelated user
     **/
    @isTest
    public static void testQueryCPQInfoUnrelatedUser() {

        Opportunity testOpportunity = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Profile sysAdminProfile = [
            SELECT Id
            FROM Profile
            WHERE Name='System Administrator'
        ]; 

        User unrelateduser = new User(
            FirstName = 'Unrelated',
            LastName = 'User',
            Alias = 'unre',
            Email='unre@testorg.com',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='unre@testorg.com'
        );
        cpq_ContainerClass.CPQInfo cpqData = new cpq_ContainerClass.CPQInfo();

        Test.startTest();

        System.runAs(unrelateduser) {
            cpqData = cpq_ContainerClass.getCPQInfo(testOpportunity.Id);
        }

        // Verify NO opp Access
        System.assertEquals(false, cpqData.hasOppAccess);
        System.assertEquals(testOpportunity.Id, cpqData.oppInfo.Id);
        System.assertEquals(null, cpqData.contracts);
        System.assertEquals(null, cpqData.quotes);
        System.assertEquals(null, cpqData.approvalSteps);
        System.assertEquals(null, cpqData.userInfo);

        Test.stopTest();
    }

    /**
     * @description Test to verify CPQ Data queries successfully as the opportunity owner
     **/
    @isTest
    public static void testQueryCPQInfoOppOwner() {

        Opportunity testOpportunity = [
            SELECT Id,
                OwnerId
            FROM Opportunity
            LIMIT 1
        ];
        User oppOwner = new User(
            Id = testOpportunity.OwnerId
        );
        cpq_ContainerClass.CPQInfo cpqData = new cpq_ContainerClass.CPQInfo();

        Test.startTest();

        System.runAs(oppOwner) {
            cpqData = cpq_ContainerClass.getCPQInfo(testOpportunity.Id);
        }

        // Verify opp Access
        System.assertEquals(true, cpqData.hasOppAccess);
        System.assertEquals(testOpportunity.Id, cpqData.oppInfo.Id);
        System.assertNotEquals(null, cpqData.contracts);
        System.assertNotEquals(null, cpqData.quotes);
        System.assertNotEquals(null, cpqData.approvalSteps);
        System.assertNotEquals(null, cpqData.userInfo);

        Test.stopTest();
    }

    /**
     * @description Test to verify CPQ Data queries successfully as the opportunity team member
     **/
    @isTest
    public static void testQueryCPQInfoOTM() {

        Opportunity testOpportunity = [
            SELECT Id,
                OwnerId
            FROM Opportunity
            LIMIT 1
        ];

        User otmUser = [
            SELECT Id
            FROM User
            WHERE Id !=:testOpportunity.OwnerId AND
                IsActive = TRUE AND
                UserType = 'Standard'
            LIMIT 1
        ];

        OpportunityTeamMember otm = new OpportunityTeamMember(
            OpportunityId = testOpportunity.Id,
            UserId = otmUser.Id,
            OpportunityAccessLevel = 'Edit',
            TeamMemberRole = 'Account Execuitve'
        );
        insert otm;

        cpq_ContainerClass.CPQInfo cpqData = new cpq_ContainerClass.CPQInfo();

        Test.startTest();

        System.runAs(otmUser) {
            cpqData = cpq_ContainerClass.getCPQInfo(testOpportunity.Id);
        }

        // Verify opp Access
        System.assertEquals(true, cpqData.hasOppAccess);
        System.assertEquals(testOpportunity.Id, cpqData.oppInfo.Id);
        System.assertNotEquals(null, cpqData.contracts);
        System.assertNotEquals(null, cpqData.quotes);
        System.assertNotEquals(null, cpqData.approvalSteps);
        System.assertNotEquals(null, cpqData.userInfo);

        Test.stopTest();
    }

    /**
     * @description Test to verify CPQ Data queries successfully as the CPQ Admin User
     **/
    @isTest
    public static void testQueryCPQInfoCPQAdmin() {

        Opportunity testOpportunity = [
            SELECT Id,
                OwnerId
            FROM Opportunity
            LIMIT 1
        ];

        PermissionSet testPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'CPQ_Admin'
            LIMIT 1
        ];

        User originalOwner = [
            SELECT Id,
                (
                    SELECT Id
                    FROM PermissionSetAssignments
                    WHERE PermissionSetId =:testPermissionSet.Id
                )
            FROM User
            WHERE Id =:testOpportunity.OwnerId
        ];

        User newOwner = [
            SELECT Id
            FROM User
            WHERE Id !=:testOpportunity.OwnerId AND
                IsActive = TRUE AND
                UserType = 'Standard'
            LIMIT 1
        ];

        if (originalOwner.PermissionSetAssignments.size() == 0) {
            PermissionSetAssignment permAssignment = new PermissionSetAssignment(
                PermissionSetId = testPermissionSet.Id,
                AssigneeId = testOpportunity.OwnerId
            );
            insert permAssignment;
        }

        cpq_ContainerClass.CPQInfo cpqData = new cpq_ContainerClass.CPQInfo();

        Test.startTest();

        System.runAs(originalOwner) {

            testOpportunity.OwnerId = newOwner.Id;
            update testOpportunity;

            cpqData = cpq_ContainerClass.getCPQInfo(testOpportunity.Id);
        }

        // Verify opp Access
        System.assertEquals(true, cpqData.hasOppAccess);
        System.assertEquals(testOpportunity.Id, cpqData.oppInfo.Id);
        System.assertNotEquals(null, cpqData.contracts);
        System.assertNotEquals(null, cpqData.quotes);
        System.assertNotEquals(null, cpqData.approvalSteps);
        System.assertNotEquals(null, cpqData.userInfo);

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

        cpq_ContainerClass.deleteRecords(testPlaybooks);
        
        Test.stopTest();

        List<CPQ_Playbook__c> emptyPlaybookList = new List<CPQ_Playbook__c>();
        emptyPlaybookList = [
            SELECT Id
            FROM CPQ_Playbook__c
        ];

        System.assertEquals(0, emptyPlaybookList.size());
    }

    /**
     * @description Test to update Playbooks
     **/
    @isTest
    public static void testUpdatePlaybooks() {

        List<CPQ_Playbook__c> testPlaybooks = [
            SELECT Id,
                Name
            FROM CPQ_Playbook__c
        ];

        for (CPQ_Playbook__c playbook : testPlaybooks) {
            playbook.Name = 'TEST TEST TEST';
        }

        Test.startTest();

        cpq_ContainerClass.updateRecords(testPlaybooks);
        
        Test.stopTest();

        List<CPQ_Playbook__c> emptyPlaybookList = new List<CPQ_Playbook__c>();
        for (CPQ_Playbook__c playbook : [
            SELECT Id,
                Name
            FROM CPQ_Playbook__c
        ]) {
            System.assertEquals('TEST TEST TEST', playbook.Name);
        }
    }

    /**
     * @description Test to submit approvals for a quote
     **/
    @isTest
    public static void testSubmitApprovals() {

        Opportunity testOpportunity = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Pricebook2 testPricebook = [
            SELECT Id
            FROM Pricebook2
            LIMIT 1
        ];

        CPQ_Playbook__c testPlaybook = [
            SELECT Id
            FROM CPQ_Playbook__c
            WHERE Pricebook__c =:testPricebook.Id
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

        CPQ_Playbook_Approver_Group__c testApproverGroup2 = [
            SELECT Id
            FROM CPQ_Playbook_Approver_Group__c
            WHERE CPQ_Playbook_Approval__c=:testApproval.Id AND
                Id !=:testApproverGroup.Id
            LIMIT 1
        ];

        CPQ_Playbook_Approver__c testApprover = [
            SELECT Id
            FROM CPQ_Playbook_Approver__c
            WHERE CPQ_Playbook_Approver_Group__c=:testApproverGroup.Id
            LIMIT 1
        ];

        // New Quote
        Quote testQuote  = new Quote(
            OpportunityId = testOpportunity.Id,
            Pricebook2Id = testPricebook.Id,
            Name = 'Test Quote',
            Adjustment_of_Contract__c = null,
            Adjustment_Type__c = null,
            CPQ_Playbook__c = testPlaybook.Id,
            IsClone__c = false,
            Playbook_Status__c = 'Complete'
        );

        // New Quote Approvals
        List<CPQ_Quote_Approval__c> testApprovals = new List<CPQ_Quote_Approval__c>();
        testApprovals.add(
            new CPQ_Quote_Approval__c(
                CPQ_Playbook_Approval__c = testApproval.Id,
                Status__c = 'Pending'
            )
        );
        testApprovals.add(
            new CPQ_Quote_Approval__c(
                CPQ_Playbook_Approval__c = testApproval.Id,
                Status__c = 'Approved'
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
        testApprovalStepsBase.add(
            new CPQ_Quote_Approval_Step__c(
                CPQ_Playbook_Approver_Group__c = testApproverGroup2.Id,
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
                Status__c = 'Pending',
                Approver__c = System.UserInfo.getUserId()
            )
        );
        testApproversBase.add(
            new CPQ_Quote_Approver__c(
                CPQ_Playbook_Approver__c = testApprover.Id,
                Status__c = 'Pending',
                Approver__c = System.UserInfo.getUserId()
            )
        );
        List<List<CPQ_Quote_Approver__c>> testApproversSubBase = new List<List<CPQ_Quote_Approver__c>>();
        testApproversSubBase.add(testApproversBase);
        List<List<List<CPQ_Quote_Approver__c>>> testApprovers = new List<List<List<CPQ_Quote_Approver__c>>>();
        testApprovers.add(testApproversSubBase);

        // Save initial quote data
        cpq_ConfigQuoteClass.saveQuoteConfiguration(
            testQuote,
            new List<QuoteLineItem>(),
            new List<CPQ_Playbook_Answer__c>(),
            testApprovals,
            testApprovalSteps,
            testApprovers
        );

        Test.startTest();

        cpq_ContainerClass.submitForApproval(testQuote.Id);

        Test.stopTest();

        // Verify updates
        List<CPQ_Quote_Approval__c> submittedApprovals = new List<CPQ_Quote_Approval__c>();
        submittedApprovals = [
            SELECT Id
            FROM CPQ_Quote_Approval__c
            WHERE Status__c = 'Submitted' AND
                Quote__c =:testQuote.Id
        ];
        System.assertEquals(1, submittedApprovals.size());

        List<CPQ_Quote_Approval__c> pendingApprovals = new List<CPQ_Quote_Approval__c>();
        pendingApprovals = [
            SELECT Id
            FROM CPQ_Quote_Approval__c
            WHERE Status__c = 'Pending' AND
                Quote__c =:testQuote.Id
        ];
        System.assertEquals(0, pendingApprovals.size());

        List<CPQ_Quote_Approval_Step__c> submittedApprovalSteps = new List<CPQ_Quote_Approval_Step__c>();
        submittedApprovalSteps = [
            SELECT Id
            FROM CPQ_Quote_Approval_Step__c
            WHERE Status__c = 'Submitted' AND
                CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(1, submittedApprovalSteps.size());

        List<CPQ_Quote_Approval_Step__c> pendingApprovalSteps = new List<CPQ_Quote_Approval_Step__c>();
        pendingApprovalSteps = [
            SELECT Id
            FROM CPQ_Quote_Approval_Step__c
            WHERE Status__c = 'Pending' AND
                CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(1, pendingApprovalSteps.size());

        List<CPQ_Quote_Approver__c> submittedApprovers = new List<CPQ_Quote_Approver__c>();
        submittedApprovers = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE Status__c = 'Submitted' AND
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(2, submittedApprovers.size());

        List<CPQ_Quote_Approver__c> pendingApprovers = new List<CPQ_Quote_Approver__c>();
        pendingApprovers = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE Status__c = 'Pending' AND
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(0, pendingApprovers.size());

    }

    /**
     * @description Test to recall approval for a quote
     **/
    @isTest
    public static void testRecallApproval() {

        Opportunity testOpportunity = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Pricebook2 testPricebook = [
            SELECT Id
            FROM Pricebook2
            LIMIT 1
        ];

        CPQ_Playbook__c testPlaybook = [
            SELECT Id
            FROM CPQ_Playbook__c
            WHERE Pricebook__c =:testPricebook.Id
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

        // New Quote
        Quote testQuote  = new Quote(
            OpportunityId = testOpportunity.Id,
            Pricebook2Id = testPricebook.Id,
            Name = 'Test Quote',
            Adjustment_of_Contract__c = null,
            Adjustment_Type__c = null,
            CPQ_Playbook__c = testPlaybook.Id,
            IsClone__c = false,
            Playbook_Status__c = 'Complete'
        );

        // New Quote Approvals
        List<CPQ_Quote_Approval__c> testApprovals = new List<CPQ_Quote_Approval__c>();
        testApprovals.add(
            new CPQ_Quote_Approval__c(
                CPQ_Playbook_Approval__c = testApproval.Id,
                Status__c = 'Submitted'
            )
        );

        // New Quote Approver Steps
        List<CPQ_Quote_Approval_Step__c> testApprovalStepsBase = new List<CPQ_Quote_Approval_Step__c>();
        testApprovalStepsBase.add(
            new CPQ_Quote_Approval_Step__c(
                CPQ_Playbook_Approver_Group__c = testApproverGroup.Id,
                Status__c = 'Submitted'
            )
        );
        List<List<CPQ_Quote_Approval_Step__c>> testApprovalSteps = new List<List<CPQ_Quote_Approval_Step__c>>();
        testApprovalSteps.add(testApprovalStepsBase);

        // New Quote Approvers
        List<CPQ_Quote_Approver__c> testApproversBase = new List<CPQ_Quote_Approver__c>();
        testApproversBase.add(
            new CPQ_Quote_Approver__c(
                CPQ_Playbook_Approver__c = testApprover.Id,
                Status__c = 'Submitted',
                Approver__c = System.UserInfo.getUserId()
            )
        );
        List<List<CPQ_Quote_Approver__c>> testApproversSubBase = new List<List<CPQ_Quote_Approver__c>>();
        testApproversSubBase.add(testApproversBase);
        List<List<List<CPQ_Quote_Approver__c>>> testApprovers = new List<List<List<CPQ_Quote_Approver__c>>>();
        testApprovers.add(testApproversSubBase);

        // Save initial quote data
        cpq_ConfigQuoteClass.saveQuoteConfiguration(
            testQuote,
            new List<QuoteLineItem>(),
            new List<CPQ_Playbook_Answer__c>(),
            testApprovals,
            testApprovalSteps,
            testApprovers
        );

        Test.startTest();

        CPQ_Quote_Approval_Step_TriggerHandler.firstRunAfterUpdate = true;
        cpq_ContainerClass.recallApproval(testApprovals[0].Id);

        Test.stopTest();

        // Verify updates
        List<CPQ_Quote_Approval__c> submittedApprovals = new List<CPQ_Quote_Approval__c>();
        submittedApprovals = [
            SELECT Id
            FROM CPQ_Quote_Approval__c
            WHERE Status__c = 'Submitted' AND
                Quote__c =:testQuote.Id
        ];
        System.assertEquals(0, submittedApprovals.size());

        List<CPQ_Quote_Approval__c> recalledApprovals = new List<CPQ_Quote_Approval__c>();
        recalledApprovals = [
            SELECT Id
            FROM CPQ_Quote_Approval__c
            WHERE Status__c = 'Recalled' AND
                Quote__c =:testQuote.Id
        ];
        System.assertEquals(1, recalledApprovals.size());

        List<CPQ_Quote_Approval_Step__c> submittedApprovalSteps = new List<CPQ_Quote_Approval_Step__c>();
        submittedApprovalSteps = [
            SELECT Id
            FROM CPQ_Quote_Approval_Step__c
            WHERE Status__c = 'Submitted' AND
                CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(0, submittedApprovalSteps.size());

        List<CPQ_Quote_Approval_Step__c> recalledApprovalSteps = new List<CPQ_Quote_Approval_Step__c>();
        recalledApprovalSteps = [
            SELECT Id
            FROM CPQ_Quote_Approval_Step__c
            WHERE Status__c = 'Recalled' AND
                CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(1, recalledApprovalSteps.size());

        List<CPQ_Quote_Approver__c> submittedApprovers = new List<CPQ_Quote_Approver__c>();
        submittedApprovers = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE Status__c = 'Submitted' AND
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(0, submittedApprovers.size());

        List<CPQ_Quote_Approver__c> recalledApprovers = new List<CPQ_Quote_Approver__c>();
        recalledApprovers = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE Status__c = 'Recalled' AND
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c =:testQuote.Id
        ];
        System.assertEquals(1, recalledApprovers.size());

    }

    /**
     * @description Test to generate PDF for a quote and post it on opportunity
     **/
    @isTest
    public static void testGeneratePDF() {

        Opportunity testOpportunity = [
            SELECT Id,
                Name
            FROM Opportunity
            LIMIT 1
        ];

        Pricebook2 testPricebook = [
            SELECT Id
            FROM Pricebook2
            LIMIT 1
        ];

        CPQ_Playbook__c testPlaybook = [
            SELECT Id
            FROM CPQ_Playbook__c
            WHERE Pricebook__c =:testPricebook.Id
            LIMIT 1
        ];

        // New Quote
        Quote testQuote  = new Quote(
            OpportunityId = testOpportunity.Id,
            Pricebook2Id = testPricebook.Id,
            Name = 'Test Quote',
            Adjustment_of_Contract__c = null,
            Adjustment_Type__c = null,
            CPQ_Playbook__c = testPlaybook.Id,
            IsClone__c = false,
            Playbook_Status__c = 'Complete'
        );
        insert testQuote;

        Test.startTest();

        cpq_ContainerClass.generatePDF(testQuote, testOpportunity);

        test.stopTest();

        // Verify updates
        FeedItem post = [
            SELECT Id,
                Body,
                (
                    SELECT Id
                    FROM FeedAttachments
                    WHERE RecordId != null AND
                        Type = 'CONTENT'
                )
            FROM FeedItem
            WHERE ParentId =:testOpportunity.Id
        ];

        System.assertEquals('Quote Proposal created from: ' + testQuote.Name + ' (' + testQuote.Id + ').', post.Body);
        System.assertEquals(1, post.FeedAttachments.size());
    }

    /**
     * @description Test to Clone Quote
     **/
    @isTest
    public static void testCloneQuote() {

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
            Adjustment_Type__c = 'Renewal',
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
                CPQ_Playbook_Rule_Action__c = null,
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
                Status__c = 'Submitted'
            )
        );

        // New Quote Approver Steps
        List<CPQ_Quote_Approval_Step__c> testApprovalStepsBase = new List<CPQ_Quote_Approval_Step__c>();
        testApprovalStepsBase.add(
            new CPQ_Quote_Approval_Step__c(
                CPQ_Playbook_Approver_Group__c = testApproverGroup.Id,
                Status__c = 'Submitted'
            )
        );
        List<List<CPQ_Quote_Approval_Step__c>> testApprovalSteps = new List<List<CPQ_Quote_Approval_Step__c>>();
        testApprovalSteps.add(testApprovalStepsBase);

        // New Quote Approvers
        List<CPQ_Quote_Approver__c> testApproversBase = new List<CPQ_Quote_Approver__c>();
        testApproversBase.add(
            new CPQ_Quote_Approver__c(
                CPQ_Playbook_Approver__c = testApprover.Id,
                Status__c = 'Submitted',
                Approver__c = System.UserInfo.getUserId()
            )
        );
        List<List<CPQ_Quote_Approver__c>> testApproversSubBase = new List<List<CPQ_Quote_Approver__c>>();
        testApproversSubBase.add(testApproversBase);
        List<List<List<CPQ_Quote_Approver__c>>> testApprovers = new List<List<List<CPQ_Quote_Approver__c>>>();
        testApprovers.add(testApproversSubBase);

        // Save initial quote data
        cpq_ConfigQuoteClass.saveQuoteConfiguration(
            testQuote,
            testQLIs,
            testAnswers,
            testApprovals,
            testApprovalSteps,
            testApprovers
        );

        Test.startTest();

        cpq_ContainerClass.cloneQuoteData(testQuote.Id);

        Test.stopTest();


        // Verify Updates
        Quote clonedQuote = [
            SELECT Id,
                OpportunityId,
                Pricebook2Id,
                Name,
                Adjustment_of_Contract__c ,
                Adjustment_Type__c,
                CPQ_Playbook__c,
                IsClone__c,
                Playbook_Status__c
            FROM Quote
            WHERE Name = 'CLONE: Test Quote'
        ];

        System.assertEquals(testQuote.OpportunityId, clonedQuote.OpportunityId);
        System.assertEquals(testQuote.Pricebook2Id, clonedQuote.Pricebook2Id);
        System.assertEquals(testQuote.Adjustment_of_Contract__c, clonedQuote.Adjustment_of_Contract__c);
        System.assertEquals(testQuote.Adjustment_Type__c, clonedQuote.Adjustment_Type__c);
        System.assertEquals(testQuote.CPQ_Playbook__c, clonedQuote.CPQ_Playbook__c);
        System.assertEquals(true, clonedQuote.IsClone__c);
        System.assertEquals(testQuote.Playbook_Status__c, clonedQuote.Playbook_Status__c);

        QuoteLineItem clonedQLI = [
            SELECT Id,
                Quantity,
                PricebookEntryId,
                CPQ_Playbook_Rule_Action__c,
                Discount__c,
                Start_Date__c,
                End_Date__c,
                List_Price__c,
                Quantity__c,
                Unit_Price__c,
                UnitPrice
            FROM QuoteLineItem
            WHERE QuoteId =:clonedQuote.Id
        ];

        System.assertEquals(testQLIs[0].Quantity, clonedQLI.Quantity);
        System.assertEquals(testQLIs[0].PricebookEntryId, clonedQLI.PricebookEntryId);
        System.assertEquals(testQLIs[0].CPQ_Playbook_Rule_Action__c, clonedQLI.CPQ_Playbook_Rule_Action__c);
        System.assertEquals(testQLIs[0].Discount__c, clonedQLI.Discount__c);
        System.assertEquals(testQLIs[0].Start_Date__c, clonedQLI.Start_Date__c);
        System.assertEquals(testQLIs[0].End_Date__c, clonedQLI.End_Date__c);
        System.assertEquals(testQLIs[0].List_Price__c, clonedQLI.List_Price__c);
        System.assertEquals(testQLIs[0].Quantity__c, clonedQLI.Quantity__c);
        System.assertEquals(testQLIs[0].Unit_Price__c, clonedQLI.Unit_Price__c);
        System.assertEquals(testQLIs[0].UnitPrice, clonedQLI.UnitPrice);

        CPQ_Playbook_Answer__c clonedAnswer = [
            SELECT Id,
                CPQ_Playbook_Question__c,
                HasBeenTouched__c,
                Value_Boolean__c 
            FROM CPQ_Playbook_Answer__c
            WHERE Quote__c =:clonedQuote.Id
        ];

        System.assertEquals(testAnswers[0].CPQ_Playbook_Question__c, clonedAnswer.CPQ_Playbook_Question__c);
        System.assertEquals(testAnswers[0].HasBeenTouched__c, clonedAnswer.HasBeenTouched__c);
        System.assertEquals(testAnswers[0].Value_Boolean__c, clonedAnswer.Value_Boolean__c);

        CPQ_Quote_Approval__c clonedApproval = [
            SELECT Id,
                CPQ_Playbook_Approval__c,
                Status__c
            FROM CPQ_Quote_Approval__c
            WHERE Quote__c =:clonedQuote.Id
        ];

        System.assertEquals(testApprovals[0].CPQ_Playbook_Approval__c, clonedApproval.CPQ_Playbook_Approval__c);
        System.assertEquals(testApprovals[0].Status__c, clonedApproval.Status__c);

        CPQ_Quote_Approval_Step__c clonedApprovalStep = [
            SELECT Id,
                CPQ_Playbook_Approver_Group__c,
                Status__c
            FROM CPQ_Quote_Approval_Step__c
            WHERE CPQ_Quote_Approval__r.Quote__c =:clonedQuote.Id
        ];

        System.assertEquals(testApprovalSteps[0][0].CPQ_Playbook_Approver_Group__c, clonedApprovalStep.CPQ_Playbook_Approver_Group__c);
        System.assertEquals(testApprovalSteps[0][0].Status__c, clonedApprovalStep.Status__c);

        CPQ_Quote_Approver__c clonedApprover = [
            SELECT Id,
                CPQ_Playbook_Approver__c,
                Status__c,
                Approver__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c =:clonedQuote.Id
        ];

        System.assertEquals(testApprovers[0][0][0].CPQ_Playbook_Approver__c, clonedApprover.CPQ_Playbook_Approver__c);
        System.assertEquals(testApprovers[0][0][0].Status__c, clonedApprover.Status__c);
        System.assertEquals(testApprovers[0][0][0].Approver__c, clonedApprover.Approver__c);
    }
}
