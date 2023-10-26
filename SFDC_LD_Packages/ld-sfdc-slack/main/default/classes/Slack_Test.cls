@isTest
public class Slack_Test {
    private static Slack.App slackApp;
    private static Slack.TestHarness testHarness;
    private static Slack.TestHarness.State slackState;
    private static Slack.TestHarness.UserSession userSession;

    static {
        // setup test harness and user session
        slackApp = Slack.App.Toggle_for_SFDC.get();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        userSession = slackState.createUserSession();
    }

    @testSetup
    public static void setup() {
        // Set Workspace
        // Test environment: T014SESUVJL
        // Production environment: 
        Slack_Workspace__c workspace = Slack_Workspace__c.getOrgDefaults();
        workspace.Name = 'Default';
        workspace.Workspace_Id__c = 'T014SESUVJ';
        upsert workspace;

        Account account = new Account(Name = 'Acc');
        insert account;

        Opportunity opp = new Opportunity(
            AccountId = account.Id,
            name = 'Opp',
            StageName = 'Probable',
            CloseDate = Date.today()
        );
        insert opp;
    }

    @isTest
    public static void testSendSlackMessage() {
        
        Test.startTest();

        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Test.stopTest();

        String error = Slack_Messaging.sendSlackMessage('', '', 'approval_message', new Map<String, Object>{'approvalId' => opp.Id});

        System.assertEquals('Error: Error processing ChatPostMessageRequest.', error);
    }

    @isTest
    public static void testModalDispatch_1() {
        
        Test.startTest();

        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Test.stopTest();

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .build();

        Slack_Modal_Dispatcher.Handler handler = new Slack_Modal_Dispatcher.Handler(
            new Map<String, Object>{
                'viewName' => 'approval_approve_reject_modal',
                'approvalId' => opp.Id
            },
            context
        );

        handler.call();
    }

    @isTest
    public static void testModalDispatch_2() {
        
        Test.startTest();

        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Test.stopTest();

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .build();

        Slack_Modal_Dispatcher.Handler handler = new Slack_Modal_Dispatcher.Handler(
            new Map<String, Object>{
                'viewName' => 'approval_view_more_modal',
                'approvalId' => opp.Id
            },
            context
        );

        handler.call();
    }

    @isTest
    public static void testModalDispatch_3() {

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .build();

        Slack_Modal_Dispatcher.Handler handler = new Slack_Modal_Dispatcher.Handler(
            new Map<String, Object>{
                'viewName' => 'approval_assigned_modal'
            },
            context
        );

        handler.call();
    }

    @isTest
    public static void testModalDispatch_Fail() {

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .build();

        Slack_Modal_Dispatcher.Handler handler = new Slack_Modal_Dispatcher.Handler(
            new Map<String, Object>{
                'viewName' => ''
            },
            context
        );

        handler.call();
    }

    @isTest
    public static void testShortcutModalDispatch() {

        Slack.TestHarness.Message message = userSession.postMessage('Test Message!!');
        userSession.executeMessageShortcut('sfdc-view-assigned-approvals', message, slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('My Assigned Approvals', modal.getTitle());
    }

    @isTest
    public static void testSlashModalDispatch() {

        // execute the 'apex-view-record' command with an invalid object
        userSession.executeSlashCommand('/sfdc-view-assigned-approvals', null, slackApp);

        // assert the message modal
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('My Assigned Approvals', modal.getTitle());
        Slack.TestHarness.Header header = (Slack.TestHarness.Header) modal.getComponent(0, Slack.TestHarness.Header.class);
        System.assertEquals(
            'Text to go here',
            header.getText()
        );
    }

    @isTest
    public static void testEventDispatch_OpenHome() {
        // open app home and assert the content
        Slack.TestHarness.Home home = userSession.openAppHome(slackApp);
        // // System.assertEquals(3, home.getComponentCount());
        // Slack.TestHarness.Header header = (Slack.TestHarness.Header) home.getComponent(0, Slack.TestHarness.Header.class);
        // System.assertEquals('Welcome to the Toggle for SFDC App!', header.getText());
        // Slack.TestHarness.Section section = (Slack.TestHarness.Section) home.getComponent(1, Slack.TestHarness.Section.class);
        // System.assertEquals('To see how this custom home view was created, see the Slack_Event_Dispatcher apex class.', section.getText());
    }

    @isTest
    public static void testCommitDispatch_Fail() {

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .build();

        Slack_Commit_Dispatcher.Handler handler = new Slack_Commit_Dispatcher.Handler(
            new Map<String, Object>{
                'actionType' => ''
            },
            context
        );

        handler.call();
    }

    @isTest
    public static void testGetQuoteLines() {
        
        Test.startTest();
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];
        Test.stopTest();

        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        oppLines = Slack_CPQApprovals_Provider.getQuoteLines(opp.Id);
    }

    @isTest
    public static void testSubmitApproval() {
        
        Test.startTest();
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];
        Test.stopTest();

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .formData(new Map<String, Object>{
                'ApprovalStatus' => 'Approved'
            })
            .build();

        Slack_Commit_Dispatcher.Handler handler = new Slack_Commit_Dispatcher.Handler(
            new Map<String, Object>{
                'actionType' => 'approval_approve_reject',
                'approvalId' => opp.Id
            },
            context
        );

        handler.call();
    }

    @isTest
    public static void testSubmitApproval_Fail() {

        Test.startTest();
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];
        Test.stopTest();

        Slack.RequestContext context = new Slack.RequestContext.builder()
            .formData(new Map<String, Object>{
                'ApprovalStatus' => 'Approved'
            })
            .build();

        Slack_Commit_Dispatcher.Handler handler = new Slack_Commit_Dispatcher.Handler(
            new Map<String, Object>{
                'actionType' => 'approval_approve_reject'
            },
            context
        );

        handler.call();
    }

    // // this test creates a contact and views it in a modal
    // @isTest
    // static void testViewContact() {
    //     // create new account and contact records
    //     Test.startTest();
    //     Account account = new Account(Name = 'Joe Co');
    //     insert account;
    //     Contact contact = new Contact(
    //         FirstName = 'Joe',
    //         LastName = 'Smith',
    //         Phone = '777-777-7777',
    //         Email = 'joesmith@example.com',
    //         AccountId = account.Id
    //     );
    //     insert contact;
    //     Test.stopTest();

    //     // execute the 'apex-view-record' command and assert modal
    //     userSession.executeSlashCommand('/apex-view-record', 'Contact ' + contact.Id, slackApp);
    //     Slack.TestHarness.Modal modal = userSession.getTopModal();
    //     System.assertEquals('View Contact', modal.getTitle());
    //     Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(1, Slack.TestHarness.Section.class);
    //     System.assertEquals('Joe Smith', section.getText());

    //     modal.submit();

    //     // assert message contents with fields: name, id, phone, and email
    //     List<Slack.TestHarness.Message> messages = userSession.getMessages();
    //     System.assertEquals(1, messages.size());
    //     Slack.TestHarness.Message message = messages.get(0);
    //     System.assertEquals(7, message.getComponentCount());
    //     Slack.TestHarness.Header header = (Slack.TestHarness.Header) message.getComponent(0, Slack.TestHarness.Header.class);
    //     System.assertEquals('Contact Record Details', header.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(2, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Name:* Joe Smith', section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(3, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Id:* ' + contact.Id, section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(4, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Phone:* 777-777-7777', section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(5, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Email:* joesmith@example.com', section.getText());
    // }

    // // this test creates an opportunity and views it in a modal
    // @isTest
    // static void testViewOpportunity() {
    //     // create new opportunity record
    //     Test.startTest();
    //     Opportunity opportunity = new Opportunity(
    //         Name = 'Acme Co.',
    //         Amount = 50000.00,
    //         StageName = 'Qualification',
    //         CloseDate = Date.valueOf('2222-12-31')
    //     );
    //     insert opportunity;
    //     Test.stopTest();

    //     // execute the 'apex-view-record' command and assert modal
    //     userSession.executeSlashCommand('/apex-view-record', 'Opportunity ' + opportunity.Id, slackApp);
    //     Slack.TestHarness.Modal modal = userSession.getTopModal();
    //     System.assertEquals('View Opportunity', modal.getTitle());
    //     Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(1, Slack.TestHarness.Section.class);
    //     System.assertEquals('Acme Co.', section.getText());

    //     modal.submit();

    //     // assert message contents with fields: name, id, amount, stage name, qualification, and close date
    //     List<Slack.TestHarness.Message> messages = userSession.getMessages();
    //     System.assertEquals(1, messages.size());
    //     Slack.TestHarness.Message message = messages.get(0);
    //     System.assertEquals(7, message.getComponentCount());
    //     Slack.TestHarness.Header header = (Slack.TestHarness.Header) message.getComponent(0, Slack.TestHarness.Header.class);
    //     System.assertEquals('Opportunity Record Details', header.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(2, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Name:* Acme Co.', section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(3, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Id:* ' + opportunity.Id, section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(4, Slack.TestHarness.Section.class);
    //     System.assertEquals('*Amount:* 50000.00', section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(5, Slack.TestHarness.Section.class);
    //     System.assertEquals('*StageName:* Qualification', section.getText());
    //     section = (Slack.TestHarness.Section) message.getComponent(6, Slack.TestHarness.Section.class);
    //     System.assertEquals('*CloseDate:* Tue Dec 31 00:00:00 GMT 2222', section.getText());
    // }

    // // this test runs the view record command without any parameters
    // @isTest
    // static void testMissingParams() {
    //     // execute the 'apex-view-record' command without parameters
    //     userSession.executeSlashCommand('/apex-view-record', slackApp);

    //     // assert the message modal
    //     Slack.TestHarness.Modal modal = userSession.getTopModal();
    //     System.assertEquals('Invalid Parameters', modal.getTitle());
    //     Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(0, Slack.TestHarness.Section.class);
    //     System.assertEquals('The view record command requires 2 arguments: objectApiName and recordId.', section.getText());
    // }

    // // this test runs the view record command with invalid parameters
    // @isTest
    // static void testInvalidObject() {
    //     // execute the 'apex-view-record' command with an invalid object
    //     userSession.executeSlashCommand('/apex-view-record', 'Invalid_Object Invalid_Record_Id', slackApp);

    //     // assert the message modal
    //     Slack.TestHarness.Modal modal = userSession.getTopModal();
    //     System.assertEquals('Invalid Object', modal.getTitle());
    //     Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(0, Slack.TestHarness.Section.class);
    //     System.assertEquals(
    //         'The objectApiName was not a valid option. The view record command supports Account, Contact, and Opportunity.',
    //         section.getText()
    //     );
    // }
}
