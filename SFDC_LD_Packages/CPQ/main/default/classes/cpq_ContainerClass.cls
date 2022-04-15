/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ Main Container controller class
*
* Tested by cpq_ContainerClassTest
*/
public with sharing class cpq_ContainerClass {

    // /////////////////////////////////////////////////////
    // Retrievals

    /**
    * @description Query all necessary info for CPQ visibility for an opportunity
    * @param oppId Id of Opportunity record CPQ is accessing
    * @return CPQInfo object
    */
    @AuraEnabled
    public static CPQInfo getCPQInfo(Id oppId) {

        // Get Object Fields for Default Field Values and Product Cacluations
        Boolean multiCurrency = System.UserInfo.isMultiCurrencyOrganization();
        Map<String, String> objFieldsStrings = getObjectFields(multiCurrency);

        // Return wrapper obj
        CPQInfo cpqObj = new CPQInfo();
        if (multiCurrency == true) {
            List<sObject> currencies = new List<sObject>();
            currencies = Database.query('SELECT Id, ConversionRate, IsoCode FROM CurrencyType WHERE IsActive = TRUE AND IsCorporate = TRUE');
            if (currencies.size() > 0) {
                cpqObj.defaultCurrency = (String) currencies[0].get('IsoCode');
            }   
        }
        
        if (cpqObj.defaultCurrency == null) {
            cpqObj.defaultCurrency = System.UserInfo.getDefaultCurrency();
        }

        // Opportunity and parent info
        Opportunity opp = new Opportunity();
        String oppQuery = 'SELECT ' + objFieldsStrings.get('Opportunity') + ', (SELECT Id, UserId FROM OpportunityTeamMembers),(SELECT Id,ContentDocumentId, ContentDocument.LatestPublishedVersion.Title FROM AttachedContentDocuments WHERE ContentDocument.LatestPublishedVersion.CPQ_Proposal__c = TRUE ORDER BY CreatedDate DESC) FROM Opportunity WHERE Id=\'' + oppId + '\''; 
        opp = Database.query(oppQuery);
        cpqObj.oppInfo = opp;

        // Verify User can access opp
        cpqObj.hasOppAccess = false;
        // Check if User is Opportunity Owner
        if (System.UserInfo.getUserId() == opp.OwnerId) {
            cpqObj.hasOppAccess = true;
        }
        if (cpqObj.hasOppAccess == false) {
            // Check if User is Opportunity Team Member
            for (OpportunityTeamMember otm : opp.OpportunityTeamMembers) {
                if (otm.UserId == System.UserInfo.getUserId()) {
                    cpqObj.hasOppAccess = true;
                }
            }
        }
        if (cpqObj.hasOppAccess == false) {
            // Check if User is CPQ Admin
            for (PermissionSetAssignment permSetAssignment : [
                SELECT
                    Id
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'CPQ_Admin' AND
                    AssigneeId=:System.UserInfo.getUserId()
            ]) {
                cpqObj.hasOppAccess = true;
            }
        }

        // Only proceed if User has opp access
        if (cpqObj.hasOppAccess == true) {

            // Contracts
            List<Contract> contracts = new List<Contract>();
            String contractsSubQueries = ', ('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,'
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__r.CPQ_Playbook__c,'
                        + 'Value_Boolean__c,'
                        + 'Value_Currency__c,'
                        + 'Value_Date__c,'
                        + 'Value_Decimal__c,'
                        + 'Value_Integer__c,'
                        + 'Value_Text__c'
                    + ' FROM Contract_Playbook_Answers__r'
                + '),'
                + '('
                    + 'SELECT '
                        + objFieldsStrings.get('Contract_Entitlement__c')
                    + ' FROM Contract_Entitlements__r'
                + ')';
            String contractsQuery = 'SELECT ' + objFieldsStrings.get('Contract') + contractsSubQueries + ' FROM Contract WHERE AccountId=\'' + opp.AccountId + '\' ORDER BY Contract_Start_Date__c DESC, Contract_End_Date__c DESC, ContractNumber'; 
            contracts = Database.query(contractsQuery);
            cpqObj.contracts = contracts;

            // Quotes with child records
            List<Quote> quotes = new List<Quote>();
            String quotesSubQueries = ', ('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,'
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__r.CPQ_Playbook__c,'
                        + 'HasBeenTouched__c,'
                        + 'Quote__c,'
                        + 'Value_Boolean__c,'
                        + 'Value_Currency__c,'
                        + 'Value_Date__c,'
                        + 'Value_Decimal__c,'
                        + 'Value_Integer__c,'
                        + 'Value_Text__c'
                    + ' FROM CPQ_Playbook_Answers__r'
                + '), '
                + '('
                    + 'SELECT '
                        + objFieldsStrings.get('QuoteLineItem')   
                    + ' FROM QuoteLineItems'
                + '), '
                + '('
                    + 'SELECT Id,'
                        + 'CPQ_Playbook_Approval__r.Label__c,'
                        + 'CPQ_Playbook_Approval__r.Reason__c,'
                        + 'Notes_for_Approvers__c,'
                        + 'Status__c'
                    + ' FROM CPQ_Quote_Approvals__r'
                + ')';
            String quotesQuery = 'SELECT ' + objFieldsStrings.get('Quote') + quotesSubQueries + ' FROM Quote WHERE OpportunityId=\'' + oppId + '\' AND Shell_Quote__c != true ORDER BY CreatedDate DESC'; 
            quotes = Database.query(quotesQuery);
            cpqObj.quotes = quotes;

            // Approval steps
            List<CPQ_Quote_Approval_Step__c> approvalSteps = new List<CPQ_Quote_Approval_Step__c>();
            approvalSteps = [
                SELECT Id,
                    CPQ_Quote_Approval__c,
                    CPQ_Quote_Approval__r.Quote__c,
                    Status__c,
                    (
                        SELECT Id,
                            Approver__c,
                            Approver__r.Name,
                            CPQ_Playbook_Approver__r.Approver__c,
                            CPQ_Playbook_Approver__r.Approver__r.Name,
                            CPQ_Playbook_Approver__r.Manager_Approver__c,
                            Decision_Reason__c,
                            Status__c
                        FROM CPQ_Quote_Approvers__r
                        ORDER BY CPQ_Playbook_Approver__r.Manager_Approver__c DESC
                    )
                FROM CPQ_Quote_Approval_Step__c
                WHERE CPQ_Quote_Approval__r.Quote__r.OpportunityId=:oppId
            ];
            cpqObj.approvalSteps = approvalSteps;

            // User
            String userQuery = 'SELECT ' + objFieldsStrings.get('User') + ' FROM User WHERE Id=\'' + System.UserInfo.getUserId() + '\''; 
            User userInfo = Database.query(userQuery);
            cpqObj.userInfo = userInfo;

        }

        return cpqObj;
    }

    public class CPQInfo {
        @AuraEnabled public Opportunity oppInfo;
        @AuraEnabled public List<Contract> contracts;
        @AuraEnabled public List<Quote> quotes;
        @AuraEnabled public List<CPQ_Quote_Approval_Step__c> approvalSteps;
        @AuraEnabled public User userInfo;
        @AuraEnabled public Boolean hasOppAccess;
        @AuraEnabled public String defaultCurrency;
    }

    /**
    * @description Retrieve all necessary fields for object queries
    * @param multiCurrency Whether or not org is a multicurrency org or not
    * @return Object/Field Map: Object Name => Comma delineated list of field API names
    */
    public static Map<String, String> getObjectFields(Boolean multiCurrency) {

        Map<String, String> objFieldQueryStrings = new Map<String, String>();
        Map<String, Set<String>> objFieldSets = new Map<String, Set<String>>();

        // Quote
        Set<String> quoteFields = new Set<String>{
            'Id',
            'Adjustment_of_Contract__c',
            'Adjustment_of_Contract__r.ContractNumber',
            'Adjustment_Type__c',
            'CPQ_Playbook__c',
            'CPQ_Playbook__r.Default_Term_in_Months__c',
            'CPQ_Playbook__r.Label__c',
            'CPQ_Playbook__r.Pricebook__c',
            'End_Date__c',
            'IsSyncing',
            'Name',
            'Playbook_Status__c',
            'Start_Date__c',
            'TotalPrice',
            'Total_Price__c'
        };
        objFieldSets.put('Quote', quoteFields);

        // QuoteLineItem
        Set<String> quoteLineItemFields = new Set<String>{
            'Id',
            'CPQ_Playbook_Rule_Action__c',
            'Discount__c',
            'End_Date__c',
            'List_Price__c',
            'PricebookEntryId',
            'Product2Id',
            'Product2.Name',
            'Quantity__c',
            'Unit_Price__c',
            'Start_Date__c',
            'Total_Price__c'
        };
        objFieldSets.put('QuoteLineItem', quoteLineItemFields);

        // Opportunity
        Set<String> oppFields = new Set<String>{
            'Id',
            'Lock_CPQ__c',
            'Name',
            'OwnerId',
            'Owner.Name',
            'Owner.ManagerId',
            'Owner.Manager.Name',
            'Account.Id',
            'Account.Name'
        };
        if (multiCurrency == true) {
            oppFields.add('CurrencyIsoCode');
        }
        objFieldSets.put('Opportunity', oppFields);

        // Account
        objFieldSets.put('Account', new Set<String>());

        // User
        Set<String> userFields = new Set<String>{
            'Id',
            'Name',
            'Profile.Id',
            'Profile.Name'
        };
        objFieldSets.put('User', userFields);

        // Profile
        objFieldSets.put('Profile', new Set<String>());

        // UserRole
        objFieldSets.put('UserRole', new Set<String>());

        // Contract
        Set<String> contractFields = new Set<String>{
            'Id',
            'Adjusted_by_Contract__c',
            'Adjusted_by_Contract__r.ContractNumber',
            'Adjustment_of_Contract__c',
            'Adjustment_of_Contract__r.ContractNumber',
            'Adjustment_Type__c',
            'Contract_End_Date__c',
            'ContractNumber',
            'Contract_Start_Date__c',
            'Contract_Status__c',
            'Contract_Total__c',
            'CPQ_Playbook__c',
            'CPQ_Playbook__r.Default_Term_in_Months__c',
            'CPQ_Playbook__r.Label__c',
            'CPQ_Playbook__r.Pricebook__c',
            'Opportunity__c',
            'Opportunity__r.Name',
            'Quote__c'
        };
        if (multiCurrency == true) {
            contractFields.add('CurrencyIsoCode');
        }
        objFieldSets.put('Contract', contractFields);

        // Contract Entitlement
        Set<String> entitlementFields = new Set<String>{
            'Id',
            'CPQ_Playbook_Rule_Action__c',
            'Discount__c',
            'End_Date__c',
            'List_Price__c',
            'Product__c',
            'Product_Name__c',
            'Quantity__c',
            'Start_Date__c',
            'Total_Price__c',
            'Unit_Price__c'
        };
        objFieldSets.put('Contract_Entitlement__c', entitlementFields);

        // Query all active default field value questions from active groups from active playbooks
        for (CPQ_Playbook_Question__c question : [
            SELECT Id,
                Default_Field_Value__c
            FROM CPQ_Playbook_Question__c
            WHERE IsActive__c=true AND
                CPQ_Playbook_Question_Group__r.IsActive__c=true AND
                CPQ_Playbook_Question_Group__r.CPQ_Playbook__r.IsActive__c=true AND
                Default_Field_Value__c != null
        ]) {
            // Valid field values are formatted as obj.field
            if (question.Default_Field_Value__c.split('\\.').size() > 0) {

                String obj = question.Default_Field_Value__c.split('\\.')[0];
                String field = question.Default_Field_Value__c.split('\\.')[1];

                // Only add fields from valid objects
                if (objFieldSets.containsKey(obj)) {

                    // Base level queries: Quote, Opportunity, User
                    if (obj == 'Quote' ||
                        obj == 'Opportunity' ||
                        obj == 'User'
                    ) {
                        objFieldSets.get(obj).add(field);
                    }
                    // Related level queries: Account, Profile
                    else if (obj == 'Account') {
                        objFieldSets.get('Opportunity').add('Account.' + field);
                    }
                    else if (obj == 'Profile') {
                        objFieldSets.get('User').add('Profile.' + field);
                    }
                    else if (obj == 'UserRole') {
                        objFieldSets.get('User').add('UserRole.' + field);
                    }
                }
            }
        }

        Set<String> standardProductFields = new Set<String>{
            'Quantity',
            'Unit_Price',
            'List_Price',
            'Start_Date',
            'End_Date',
            'Quantity_Editable',
            'Dates_Editable',
            'Discountable',
            'List_Price_Editable',
            'Manually_Addible',
            'Removable'
        };
        // Query all active product stamping actions from active rules from active playbooks
        for (CPQ_Playbook_Rule_Action__c action : [
            SELECT Id,
                Product_Adjustment_Field__c
            FROM CPQ_Playbook_Rule_Action__c
            WHERE IsActive__c=true AND
                CPQ_Playbook_Rule__r.IsActive__c=true AND
                CPQ_Playbook_Rule__r.CPQ_Playbook__r.IsActive__c=true AND
                Action_Type__c = 'Adjust product field'
        ]) {
            // Valid field values are not standard CPQ fields
            if (!standardProductFields.contains(action.Product_Adjustment_Field__c)) {

                objFieldSets.get('QuoteLineItem').add(action.Product_Adjustment_Field__c);
            }
        }

        // Query all active playbooks
        for (CPQ_Playbook__c playbook : [
            SELECT Id,
                Entitlement_Summary_Columns__c
            FROM CPQ_Playbook__c
            WHERE IsActive__c=true AND
                Entitlement_Summary_Columns__c != null
        ]) {
            // Extract each field
            for (String field : playbook.Entitlement_Summary_Columns__c.split(';')) {

                objFieldSets.get('Contract_Entitlement__c').add(field);
            }
        }

        // Convert sets to comma delineated strings
        for (String obj : objFieldSets.keySet()) {
            String fieldsString = '';
            for (String field : objFieldSets.get(obj)) {
                fieldsString += field + ',';
            }
            fieldsString = fieldsString.removeEnd(',');
            objFieldQueryStrings.put(obj, fieldsString);
        }

        return objFieldQueryStrings;
    }

    // /////////////////////////////////////////////////////
    // Actions

    /**
    * @description Generic method to delete a list of sObject records
    * @param records List of sObject records
    */
    @AuraEnabled
    public static void deleteRecords(List<sObject> records) {
        delete records;
    }

    /**
    * @description Generic method to update a list of sObject records
    * @param records List of sObject records
    */
    @AuraEnabled
    public static void updateRecords(List<sObject> records) {
        update records;
    }

    /**
    * @description Submit all incomplete approvals that exist for a given quote
    * @param quoteId Id of Quote record where approvals are being submitted
    */
    @AuraEnabled
    public static void submitForApproval(List<CPQ_Quote_Approval__c> approvals) {

        // To be submitted - approvals
        Set<Id> approvalIDs = new Set<Id>();
        List<CPQ_Quote_Approval__c> approvalsToSubmit = new List<CPQ_Quote_Approval__c>();
        for (CPQ_Quote_Approval__c approval : approvals) {
            if (approval.Status__c != 'Submitted' &&
                approval.Status__c != 'Approved'
            ) {
                approval.Status__c = 'Submitted';
                approvalsToSubmit.add(approval);
                approvalIDs.add(approval.Id);
            }
        }

        // Update approvals
        update approvalsToSubmit;

        // Associated Approval Steps/Approvers
        List<CPQ_Quote_Approval_Step__c> steps = new List<CPQ_Quote_Approval_Step__c>();
        List<CPQ_Quote_Approver__c> approvers = new List<CPQ_Quote_Approver__c>();
        steps = [
            SELECT Id,
                Approval_Order__c,
                CPQ_Quote_Approval__c,
                Status__c,
                (
                    SELECT Id,
                        Status__c
                    FROM CPQ_Quote_Approvers__r
                )
            FROM CPQ_Quote_Approval_Step__c
            WHERE CPQ_Quote_Approval__c IN:approvalIDs
            ORDER BY Approval_Order__c ASC
        ];

        // Submit first step, mark pending for all others
        for (CPQ_Quote_Approval_Step__c step : steps) {
            String stepStatus = 'Pending';
            if (step.Approval_Order__c == steps[0].Approval_Order__c) {
                stepStatus = 'Submitted';
            }
            step.Status__c = stepStatus;
            for (CPQ_Quote_Approver__c approver: step.CPQ_Quote_Approvers__r) {
                approver.Status__c = stepStatus;
                approvers.add(approver);
            }
        }

        // Update approval steps
        update steps;

        // Update approvers
        update approvers;
    }

    /**
    * @description Recall all pending approvers that exist for given approvals on a quote
    * @param quoteId Id of Quote record where approvers are being recalled
    */
    @AuraEnabled
    public static void recallApprovals(Id quoteId) {

        // Associated Approvers
        List<CPQ_Quote_Approver__c> approvers = new List<CPQ_Quote_Approver__c>();
        approvers = [
            SELECT Id,
                Status__c
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c =:quoteId AND
                Status__c != 'Approved' AND
                Status__c != 'Rejected'
        ];

        for (CPQ_Quote_Approver__c approver : approvers) {
            approver.Status__c = 'Recalled';
        }

        // Update approvers
        update approvers;
    }

    /**
    * @description Generate and save quote proposal to opportunity
    * @param quoteInfo Quote record associated with proposal
    * @param oppInfo Quote record associated with proposal
    */
    @AuraEnabled
    public static void generatePDF(Quote quoteInfo, Opportunity oppInfo){

        // Get unapproved approvals, shell info
        Quote quoteData = [
            SELECT Id,
                Shell_Quote__c,
                (
                    SELECT Id
                    FROM CPQ_Quote_Approvals__r
                    WHERE Status__c != 'Approved'
                )
            FROM Quote
            WHERE Id=:quoteInfo.Id
        ];
        Boolean isDraft = false;
        if (quoteData.CPQ_Quote_Approvals__r.size() > 0 ||
            quoteData.Shell_Quote__c == true
        ) {
            isDraft = true;
        }
        
        // Proposal VF Page
        Pagereference pg = Page.cpq_ProposalVF;
        pg.getParameters().put('quoteId', quoteInfo.Id);
        pg.getParameters().put('isDraft', String.valueOf(isDraft));

        // PDF File
        ContentVersion pdfAttachment = new ContentVersion();
        pdfAttachment.Title = (quoteInfo.Name + ' (' + Date.today().format() + ')').left(250);
        pdfAttachment.PathOnClient = (quoteInfo.Name + ' (' + Date.today().format() + ')').left(250) + '.pdf';
        pdfAttachment.VersionData = (Test.isRunningTest() ? blob.valueOf('Unit.Test') : pg.getContentAsPDF());
        pdfAttachment.Description = 'Quote Proposal submitted on ' + Date.today().format() + '. Quote: ' + quoteInfo.Name + ' (' + quoteInfo.Id + '), Opportunity: ' + oppInfo.Name + ' (' + oppInfo.Id + ').';
        pdfAttachment.CPQ_Proposal__c = true;

        insert pdfAttachment;

        // Chatter Post
        FeedItem post = new FeedItem(
            Body = 'Quote Proposal created from: ' + quoteInfo.Name + ' (' + quoteInfo.Id + ').',
            ParentId = oppInfo.Id
        );

        insert post;

        // PDF Attachment
        FeedAttachment postAttachment = new FeedAttachment(
            FeedEntityId = post.Id,
            RecordId = pdfAttachment.Id,
            Type = 'CONTENT'
        );

        insert postAttachment;
    }

    /**
    * @description Clone Quote record and child CPQ records
    * @param quoteId Id of Quote record to clone
    */
    @AuraEnabled
    public static void cloneQuoteData(Id quoteId) {

        // Quote Fields
        String quoteFields = '';
        SObjectType quoteType = ((SObject)(Type.forName('Schema.Quote').newInstance())).getSObjectType();
        DescribeSObjectResult quoteObject = quoteType.getDescribe();
        for (String field : quoteObject.fields.getMap().keySet()) {
            quoteFields += field + ',';
        }
        quoteFields = quoteFields.removeEnd(',');

        // Query Quote
        Quote q = Database.query('SELECT ' + quoteFields + ' FROM Quote WHERE Id=:quoteId');

        // Prep for clone
        q.Id = null;
        if (q.Name.left(7) != 'Clone: ') {
            q.Name = 'CLONE: ' + q.Name.left(245);
        }
        q.IsClone__c = true;

        // Insert new clone
        insert q;


        // Quote Line Item Fields
        String qliFields = '';
        SObjectType qliType = ((SObject)(Type.forName('Schema.QuoteLineItem').newInstance())).getSObjectType();
        DescribeSObjectResult qliObject = qliType.getDescribe();
        for (String field : qliObject.fields.getMap().keySet()) {
            qliFields += field + ',';
        }
        qliFields = qliFields.removeEnd(',');

        // Query Quote Line Items
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        qlis = Database.query('SELECT ' + qliFields + ' FROM QuoteLineItem WHERE QuoteId=:quoteId');

        // Prep for clone
        for (QuoteLineItem qli : qlis) {
            qli.Id = null;
            qli.QuoteId = q.Id;
        }

        // Insert new clones, if qlis exist
        if (qlis.size() > 0) {
            insert qlis;
        }


        // Query Playbook Answers
        List<CPQ_Playbook_Answer__c> answers = new List<CPQ_Playbook_Answer__c>();
        answers = [
            SELECT Id,
                CPQ_Playbook_Question__c,
                HasBeenTouched__c,
                Quote__c,
                Value_Boolean__c,
                Value_Currency__c,
                Value_Date__c,
                Value_Decimal__c,
                Value_Integer__c,
                Value_Text__c
            FROM CPQ_Playbook_Answer__c
            WHERE Quote__c=:quoteId
        ];

        // Prep for clone
        for (CPQ_Playbook_Answer__c answer : answers) {
            answer.Id = null;
            answer.Quote__c = q.Id;
        }

        // Insert new clones, if answers exist
        if (answers.size() > 0) {
            insert answers;
        }


        // Query Quote Approvals
        List<CPQ_Quote_Approval__c> approvals = new List<CPQ_Quote_Approval__c>();
        approvals = [
            SELECT Id,
                CPQ_Playbook_Approval__c,
                Name,
                Notes_for_Approvers__c,
                Quote__c,
                Status__c
            FROM CPQ_Quote_Approval__c
            WHERE Quote__c=:quoteId
        ];

        // Store old approval IDs
        List<Id> oldApprovalIDs = new List<Id>();

        // Prep for clone
        for (CPQ_Quote_Approval__c approval : approvals) {
            // Store old Id
            oldApprovalIDs.add(approval.Id);

            approval.Id = null;
            approval.Quote__c = q.Id;
        }

        // Insert new clones, if approvals exists
        if (approvals.size() > 0) {
            insert approvals;

            // Store new approval IDs
            List<Id> newApprovalIDs = new List<Id>();
            for (CPQ_Quote_Approval__c approval : approvals) {
                // Store old Id
                newApprovalIDs.add(approval.Id);
            } 


            // Query Quote Approval Steps
            List<CPQ_Quote_Approval_Step__c> steps = new List<CPQ_Quote_Approval_Step__c>();
            steps = [
                SELECT Id,
                    CPQ_Quote_Approval__c,
                    CPQ_Playbook_Approver_Group__c,
                    Name,
                    Status__c
                FROM CPQ_Quote_Approval_Step__c
                WHERE CPQ_Quote_Approval__r.Quote__c=:quoteId
            ];

            // Store old approval step IDs
            List<Id> oldStepIDs = new List<Id>();

            // Prep for clone
            for (CPQ_Quote_Approval_Step__c step : steps) {
                // Store old Id
                oldStepIDs.add(step.Id);

                step.Id = null;
                step.CPQ_Quote_Approval__c = newApprovalIds[oldApprovalIDs.indexOf(step.CPQ_Quote_Approval__c)];
            }

            // Insert new clones, if steps exists
            if (steps.size() > 0) {
                insert steps;

                // Store new approval step IDs
                List<Id> newStepIDs = new List<Id>();
                for (CPQ_Quote_Approval_Step__c step : steps) {
                    // Store old Id
                    newStepIDs.add(step.Id);
                } 

                // Query Quote Approvers
                List<CPQ_Quote_Approver__c> approvers = new List<CPQ_Quote_Approver__c>();
                approvers = [
                    SELECT Id,
                        Approver__c,
                        CPQ_Playbook_Approver__c,
                        CPQ_Quote_Approval_Step__c,
                        Name,
                        Status__c
                    FROM CPQ_Quote_Approver__c
                    WHERE CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c=:quoteId
                ];

                // Store old approver statuses
                List<String> oldApproverStatuses = new List<String>();

                // Prep for clone
                for (CPQ_Quote_Approver__c approver : approvers) {
                    approver.Id = null;
                    approver.CPQ_Quote_Approval_Step__c = newStepIds[oldStepIDs.indexOf(approver.CPQ_Quote_Approval_Step__c)];
                    oldApproverStatuses.add(approver.Status__c);
                    if (approver.Status__c == 'Submitted') {
                        approver.Status__c = 'Pending';
                    }
                }

                // Insert new clones, if approvers exists
                if (approvers.size() > 0) {
                    insert approvers;

                    // Submit 'Submitted' approvers
                    List<CPQ_Quote_Approver__c> approversToSubmit = new List<CPQ_Quote_Approver__c>();
                    for (Integer index=0;index < approvers.size();index++) {
                        if (oldApproverStatuses[index] == 'Submitted') {
                            approvers[index].Status__c = 'Submitted';
                            approversToSubmit.add(approvers[index]);
                        }
                    }

                    if (approversToSubmit.size() > 0) {
                        update approversToSubmit;
                    }
                }
            }
        }
    }
}
