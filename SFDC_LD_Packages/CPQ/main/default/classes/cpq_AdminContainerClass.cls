/**
* @author Tristan Moser
* @date 4/19/2022
*
* @description CPQ Admin Console controller class
*
* Tested by cpq_AdminContainerClassTest
*/
public with sharing class cpq_AdminContainerClass {

    // /////////////////////////////////////////////////////
    // Retrievals

    /**
    * @description Query system settings record -- create if non-existant
    * @return CPQ System Settings record
    */
    @AuraEnabled
    public static CPQ_System_Settings__c getSystemSettings() {

        // Find record
        List<CPQ_System_Settings__c> systemSettings = new List<CPQ_System_Settings__c>();
        systemSettings = [
            SELECT Id,
                Contract_Table_Actions__c,
                Contract_Table_Columns__c,
                Default_Playbook__c,
                Quote_Table_Actions__c,
                Quote_Table_Columns__c
            FROM CPQ_System_Settings__c
            LIMIT 1
        ];

        // Create initial record if it does not exist
        if (systemSettings.size() == 0) {
            CPQ_System_Settings__c initialRecord = new CPQ_System_Settings__c(
                Contract_Table_Actions__c = 'View;Amend;Replace;Renew;Void',
                Contract_Table_Columns__c = 'ContractNumber;Contract_Start_Date__c;Contract_End_Date__c;Contract_Status__c',
                Default_Playbook__c = null,
                Quote_Table_Actions__c = 'View;Edit;Sync;Proposal;Clone;Delete',
                Quote_Table_Columns__c = 'Name;CPQ_Playbook__c;Playbook_Status__c;TotalPrice'
            );
            insert initialRecord;
            systemSettings.add(initialRecord);
        }

        return systemSettings[0];

    }

    /**
    * @description Query all playbooks in system as well as all nested child records
    * @return List of PlaybookInfo objects
    */
    @AuraEnabled
    public static List<PlaybookInfo> getPlaybooks() {

        // PLAYBOOKS

        // All Playbooks
        List<CPQ_Playbook__c> playbooks = new List<CPQ_Playbook__c>();
        playbooks = [
            SELECT Id,
                Contract_View_Display_Fields__c,
                Default_Term_in_Months__c,
                Entitlement_Summary_Columns__c,
                Entitlement_Summary_Group_by_Default__c,
                Entitlement_Summary_Sort_by_Default__c,
                IsActive__c,
                Label__c,
                Name,
                Pricebook__c,
                Pricebook__r.IsActive,
                Product_Summary_Columns__c,
                Product_Summary_Group_by_Default__c,
                Product_Summary_Sort_by_Default__c,
                Proposal_Header__c,
                Proposal_Header_Type__c,
                Proposal_Footer__c,
                Quote_View_Display_Fields__c,
                (
                    SELECT Id,
                        ContentDocument.LatestPublishedVersionId
                    FROM AttachedContentDocuments
                )
            FROM CPQ_Playbook__c
            ORDER BY IsActive__c DESC,
                Name
        ];

        Set<Id> playbookIDs = new Set<Id>();
        Set<Id> playbookQuestionGroupIDs = new Set<Id>();
        Set<Id> pricebookIDs = new Set<Id>();

        // Set Map of playbook object
        Map<Id, PlaybookInfo> playbookInfoSets = new Map<Id, PlaybookInfo>();
        for (CPQ_Playbook__c playbook : playbooks) {
            // Track all playbook IDs
            playbookIDs.add(playbook.Id);

            // Track all pricebooks associated to playbooks
            pricebookIDs.add(playbook.Pricebook__c);

            // Configure PlaybookInfo class object 
            PlaybookInfo playbookInfoSet = new PlaybookInfo();
            playbookInfoSet.playbookInfo = playbook;
            playbookInfoSet.questionGroups = new List<QuestionGroupInfo>();
            playbookInfoSet.rules = new List<RuleInfo>();
            playbookInfoSet.approvals = new List<ApprovalInfo>();
            playbookInfoSet.proposalSections = new List<SectionInfo>();

            // Add to map
            playbookInfoSets.put(playbook.ID, playbookInfoSet);
        }

        // All Question Groups
        List<CPQ_Playbook_Question_Group__c> playbookQuestionGroups = new List<CPQ_Playbook_Question_Group__c>();
        playbookQuestionGroups = [
            SELECT Id,
                CPQ_Playbook__c,
                Default_Collapsed__c,
                Display_Order__c,
                IsActive__c,
                IsHidden__c,
                Label__c,
                Name,
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Actions__r
                    ORDER BY IsActive__c DESC, Name
                )
            FROM CPQ_Playbook_Question_Group__c
            WHERE CPQ_Playbook__c IN:playbookIDs
            ORDER BY IsActive__c DESC,
                Display_Order__c ASC
        ];

        // Update Map of playbook object
        for (CPQ_Playbook_Question_Group__c questionGroup : playbookQuestionGroups) {

            // Track all question group IDs
            playbookQuestionGroupIDs.add(questionGroup.Id);

            // Configure QuestionGroupInfo class object 
            QuestionGroupInfo questionGroupInfoSet = new QuestionGroupInfo();
            questionGroupInfoSet.groupInfo = questionGroup;
            questionGroupInfoSet.questions = new List<QuestionInfo>();

            // Update map
            PlaybookInfo playbookInfoSet = playbookInfoSets.get(questionGroup.CPQ_Playbook__c);
            playbookInfoSet.questionGroups.add(questionGroupInfoSet);
        }

        // All Questions
        List<CPQ_Playbook_Question__c> playbookQuestions = new List<CPQ_Playbook_Question__c>();
        playbookQuestions = [
            SELECT Id,
                Answer_Type__c,
                CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Question_Group__r.CPQ_Playbook__c,
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
                Maximum_Record_Selections__c,
                Maximum_Value__c,
                Minimum_Value__c,
                Name,
                Picklist_Answers__c,
                Proposal_Label__c,
                Query_String__c,
                Quote_Save_Field__c,
                Record_Display_Fields__c,
                Record_Selection_Behavior__c,
                Step_Value__c,
                Variable_Name__c,
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule_Criteria_Group__c,
                        CPQ_Playbook_Rule_Criteria_Group__r.Name,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Criteria__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Approval_Criteria_Group__c,
                        CPQ_Playbook_Approval_Criteria_Group__r.Name,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__c,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.Name,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.CPQ_Playbook__c,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Approval_Criteria__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Proposal_Criteria_Group__c,
                        CPQ_Playbook_Proposal_Criteria_Group__r.Name,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__c,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.Name,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.CPQ_Playbook__c,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Proposal_Criteria__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Actions__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Action_Name__c,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule_Action__c,
                        CPQ_Playbook_Rule_Action__r.Name,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Calculation_Items__r
                    ORDER BY IsActive__c DESC, Name
                )
            FROM CPQ_Playbook_Question__c
            WHERE CPQ_Playbook_Question_Group__c IN:playbookQuestionGroupIDs
            ORDER BY IsActive__c DESC,
                Display_Order__c ASC
        ];

        // Update Map of playbook object
        for (CPQ_Playbook_Question__c question : playbookQuestions) {

            // Configure QuestionInfo class object 
            QuestionInfo questionInfoSet = new QuestionInfo();
            questionInfoSet.questionInfo = question;

            // Update map
            PlaybookInfo playbookInfoSet = playbookInfoSets.get(question.CPQ_Playbook_Question_Group__r.CPQ_Playbook__c);
            for (QuestionGroupInfo questionGroup : playbookInfoSet.questionGroups) {
                if (questionGroup.groupInfo.Id == question.CPQ_Playbook_Question_Group__c) {
                    questionGroup.questions.add(questionInfoSet);
                    break;
                }
            }
        }


        // RULES

        // All Rules
        List<CPQ_Playbook_Rule__c> rules = new List<CPQ_Playbook_Rule__c>();
        rules = [
            SELECT Id,
                CPQ_Playbook__c,
                Execution_Order__c,
                Evaluate_When__c,
                IsActive__c,
                Name
            FROM CPQ_Playbook_Rule__c
            WHERE CPQ_Playbook__c IN:playbookIDs
            ORDER BY IsActive__c DESC,
                Execution_Order__c ASC,
                Name
        ];

        Set<Id> ruleIDs = new Set<Id>();
        Set<Id> ruleCriteriaGroupIDs = new Set<Id>();
        Set<Id> ruleActionIDs = new Set<Id>();

        // Set Map of rule object
        Map<Id, RuleInfo> ruleInfoSets = new Map<Id, RuleInfo>();
        for (CPQ_Playbook_Rule__c rule : rules) {
            // Track all rule IDs
            ruleIDs.add(rule.Id);

            // Configure RuleInfo class object 
            RuleInfo ruleInfoSet = new RuleInfo();
            ruleInfoSet.ruleInfo = rule;
            ruleInfoSet.criteriaGroups = new List<CriteriaGroupInfo>();
            ruleInfoSet.actions = new List<ActionInfo>();

            // Add to map
            ruleInfoSets.put(rule.Id, ruleInfoSet);
        }

        // All Rule Criteria Groups
        List<CPQ_Playbook_Rule_Criteria_Group__c> ruleCriteriaGroups = new List<CPQ_Playbook_Rule_Criteria_Group__c>();
        ruleCriteriaGroups = [
            SELECT Id,
                CPQ_Playbook_Rule__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name
            FROM CPQ_Playbook_Rule_Criteria_Group__c
            WHERE CPQ_Playbook_Rule__c IN:ruleIDs
            ORDER BY IsActive__c DESC,
                Name
        ];

        // Update Map of rule object
        for (CPQ_Playbook_Rule_Criteria_Group__c criteriaGroup : ruleCriteriaGroups) {

            // Track all criteria group IDs
            ruleCriteriaGroupIDs.add(criteriaGroup.Id);

            // Configure CriteriaGroupInfo class object 
            CriteriaGroupInfo criteriaGroupInfoSet = new CriteriaGroupInfo();
            criteriaGroupInfoSet.groupInfo = criteriaGroup;
            criteriaGroupInfoSet.criteria = new List<CriterionInfo>();

            // Update map
            RuleInfo ruleInfoSet = ruleInfoSets.get(criteriaGroup.CPQ_Playbook_Rule__c);
            ruleInfoSet.criteriaGroups.add(criteriaGroupInfoSet);
        }

        // All Rule Criteria
        List<CPQ_Playbook_Rule_Criterion__c> criteria = new List<CPQ_Playbook_Rule_Criterion__c>();
        criteria = [
            SELECT Id,
                Comparison_Operator__c,
                Comparison_Value_Boolean__c,
                Comparison_Value_Currency__c,
                Comparison_Value_Date__c,
                Comparison_Value_Decimal__c,
                Comparison_Value_Integer__c,
                Comparison_Value_Text__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.Answer_Type__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Rule_Criteria_Group__c,
                CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__c,
                Criterion_Source__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name,
                Product__c,
                Product_Criterion_Target_Rule_Action__c,
                Product_Field__c,
                Product_Field_Type__c,
                Product_Is_Entitlement__c,
                Record_Lookup_Field__c,
                Record_Lookup_Field_Type__c,
                System_Value_Source__c,
                Target_Manual_Addition_Only__c
            FROM CPQ_Playbook_Rule_Criterion__c
            WHERE CPQ_Playbook_Rule_Criteria_Group__c IN:ruleCriteriaGroupIDs
            ORDER BY IsActive__c DESC,
                Name
        ];

        // Update Map of rule object
        for (CPQ_Playbook_Rule_Criterion__c criterion : criteria) {

            // Configure CriterionInfo class object 
            CriterionInfo criterionInfoSet = new CriterionInfo();
            criterionInfoSet.criterionInfo = criterion;

            // Update map
            RuleInfo ruleInfoSet = ruleInfoSets.get(criterion.CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__c);
            for (CriteriaGroupInfo criteriaGroup : ruleInfoSet.criteriaGroups) {
                if (criteriaGroup.groupInfo.Id == criterion.CPQ_Playbook_Rule_Criteria_Group__c) {
                    criteriaGroup.criteria.add(criterionInfoSet);
                    break;
                }
            }
        }

        // All Actions
        List<CPQ_Playbook_Rule_Action__c> actions = new List<CPQ_Playbook_Rule_Action__c>();
        actions = [
            SELECT Id,
                Action_Type__c,
                Calculation_Type__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.Answer_Type__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Rule__c,
                Execution_Order__c,
                Field_Value_Boolean__c,
                Field_Value_Currency__c,
                Field_Value_Date__c,
                Field_Value_Decimal__c,
                Field_Value_Integer__c,
                Field_Value_Text__c,
                IsActive__c,
                Name,
                Numeric_Math_Operator__c,
                Product__c,
                Product_Adjustment_Field__c,
                Product_Adjustment_Field_Type__c,
                Product_Adjustment_Target_Rule_Action__c,
                Question_Adjustment_Field__c,
                Question_Group_Adjustment_Field__c,
                Target_Manual_Addition_Only__c,
                Value_Source_Type__c,
                (
                    SELECT Id
                    FROM Product_Rule_Criterion_Targets__r
                ),
                (
                    SELECT Id
                    FROM Product_Approval_Criterion_Targets__r
                ),
                (
                    SELECT Id
                    FROM Product_Proposal_Criterion_Targets__r
                ),
                (
                    SELECT Id
                    FROM Product_Calculation_Targets__r
                ),
                (
                    SELECT Id
                    FROM Product_Adjustment_Targets__r
                )
            FROM CPQ_Playbook_Rule_Action__c
            WHERE CPQ_Playbook_Rule__c IN:ruleIDs
            ORDER BY IsActive__c DESC,
                Execution_Order__c ASC
        ];

        // Update Map of rule object
        for (CPQ_Playbook_Rule_Action__c action : actions) {

            // Track all action IDs
            ruleActionIDs.add(action.Id);

            // Configure ActionInfo class object 
            ActionInfo actionInfoSet = new ActionInfo();
            actionInfoSet.actionInfo = action;
            actionInfoSet.calculationItems = new List<CalculationItemInfo>();

            // Update map
            RuleInfo ruleInfoSet = ruleInfoSets.get(action.CPQ_Playbook_Rule__c);
            ruleInfoSet.actions.add(actionInfoSet);
        }

        // All Calculation Items
        List<CPQ_Playbook_Rule_Calculation_Item__c> calulationItems = new List<CPQ_Playbook_Rule_Calculation_Item__c>();
        calulationItems = [
            SELECT Id,
                Calculation_Source__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.Answer_Type__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Rule_Action__c,
                CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__c,
                Entitlement_Calculation_Field__c,
                Execution_Order__c,
                IsActive__c,
                Name,
                Product__c,
                Product_Calculation_Field__c,
                Product_Calculation_Field_Type__c,
                Product_Calculation_Target_Rule_Action__c,
                Product_Is_Entitlement__c,
                Record_Lookup_Behavior__c,
                Record_Lookup_Field__c,
                Record_Lookup_Field_Type__c,
                Static_Value_Boolean__c,
                Static_Value_Currency__c,
                Static_Value_Date__c,
                Static_Value_Decimal__c,
                Static_Value_Integer__c,
                Static_Value_Text__c,
                Static_Value_Type__c
            FROM CPQ_Playbook_Rule_Calculation_Item__c
            WHERE CPQ_Playbook_Rule_Action__c IN:ruleActionIDs
            ORDER BY IsActive__c DESC,
                Execution_Order__c ASC
        ];

        // Update Map of rule object
        for (CPQ_Playbook_Rule_Calculation_Item__c item : calulationItems) {

            // Configure ActionInfo class object 
            CalculationItemInfo calculationItemInfoSet = new CalculationItemInfo();
            calculationItemInfoSet.itemInfo = item;

            // Update map
            RuleInfo ruleInfoSet = ruleInfoSets.get(item.CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__c);
            for (ActionInfo action : ruleInfoSet.actions) {
                if (action.actionInfo.Id == item.CPQ_Playbook_Rule_Action__c) {
                    action.calculationItems.add(calculationItemInfoSet);
                    break;
                }
            }
        }

        // Update playbook map
        for (RuleInfo ruleInfoSet : ruleInfoSets.values()) {
            PlaybookInfo playbookInfoSet = playbookInfoSets.get(ruleInfoSet.ruleInfo.CPQ_Playbook__c);
            playbookInfoSet.rules.add(ruleInfoSet);
        }


        // Approvals

        // All Approvals
        List<CPQ_Playbook_Approval__c> approvals = new List<CPQ_Playbook_Approval__c>();
        approvals = [
            SELECT Id,
                CPQ_Playbook__c,
                IsActive__c,
                Label__c,
                Name,
                Persistent_Approval__c,
                Reason__c
            FROM CPQ_Playbook_Approval__c
            WHERE CPQ_Playbook__c IN:playbookIDs
            ORDER BY IsActive__c DESC,
                Label__c
        ];

        Set<Id> approvalIDs = new Set<Id>();
        Set<Id> approvalCriteriaGroupIDs = new Set<Id>();
        Set<Id> approverGroupIDs = new Set<Id>();

        // Set Map of approval object
        Map<Id, ApprovalInfo> approvalInfoSets = new Map<Id, ApprovalInfo>();
        for (CPQ_Playbook_Approval__c approval : approvals) {
            // Track all approval IDs
            approvalIDs.add(approval.Id);

            // Configure ApprovalInfo class object 
            ApprovalInfo approvalInfoSet = new ApprovalInfo();
            approvalInfoSet.approvalInfo = approval;
            approvalInfoSet.criteriaGroups = new List<ApprovalCriteriaGroupInfo>();
            approvalInfoSet.approverGroups = new List<ApproverGroupInfo>();
            approvalInfoSet.emailSections = new List<EmailSectionInfo>();

            // Add to map
            approvalInfoSets.put(approval.Id, approvalInfoSet);
        }

        // All Approval Criteria Groups
        List<CPQ_Playbook_Approval_Criteria_Group__c> approvalCriteriaGroups = new List<CPQ_Playbook_Approval_Criteria_Group__c>();
        approvalCriteriaGroups = [
            SELECT Id,
                CPQ_Playbook_Approval__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name
            FROM CPQ_Playbook_Approval_Criteria_Group__c
            WHERE CPQ_Playbook_Approval__c IN:approvalIDs
            ORDER BY IsActive__c DESC,
                Name
        ];

        // Update Map of approval object
        for (CPQ_Playbook_Approval_Criteria_Group__c criteriaGroup : approvalCriteriaGroups) {

            // Track all criteria group IDs
            approvalCriteriaGroupIDs.add(criteriaGroup.Id);

            // Configure ApprovalCriteriaGroupInfo class object 
            ApprovalCriteriaGroupInfo approvalCriteriaGroupInfoSet = new ApprovalCriteriaGroupInfo();
            approvalCriteriaGroupInfoSet.groupInfo = criteriaGroup;
            approvalCriteriaGroupInfoSet.criteria = new List<ApprovalCriterionInfo>();

            // Update map
            ApprovalInfo approvalInfoSet = approvalInfoSets.get(criteriaGroup.CPQ_Playbook_Approval__c);
            approvalInfoSet.criteriaGroups.add(approvalCriteriaGroupInfoSet);
        }

        // All Approval Criteria
        List<CPQ_Playbook_Approval_Criterion__c> approvalCriteria = new List<CPQ_Playbook_Approval_Criterion__c>();
        approvalCriteria = [
            SELECT Id,
                Comparison_Operator__c,
                Comparison_Value_Boolean__c,
                Comparison_Value_Currency__c,
                Comparison_Value_Date__c,
                Comparison_Value_Decimal__c,
                Comparison_Value_Integer__c,
                Comparison_Value_Text__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.Answer_Type__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Approval_Criteria_Group__c,
                CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__c,
                Criterion_Source__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name,
                Product__c,
                Product_Criterion_Target_Rule_Action__c,
                Product_Field__c,
                Product_Field_Type__c,
                Record_Lookup_Field__c,
                Record_Lookup_Field_Type__c,
                System_Value_Source__c,
                Target_Manual_Addition_Only__c
            FROM CPQ_Playbook_Approval_Criterion__c
            WHERE CPQ_Playbook_Approval_Criteria_Group__c IN:approvalCriteriaGroupIDs
            ORDER BY IsActive__c DESC,
                Name
        ];

        // Update Map of approval object
        for (CPQ_Playbook_Approval_Criterion__c criterion : approvalCriteria) {

            // Configure ApprovalCriterionInfo class object 
            ApprovalCriterionInfo approvalCriterionInfoSet = new ApprovalCriterionInfo();
            approvalCriterionInfoSet.criterionInfo = criterion;

            // Update map
            ApprovalInfo approvalInfoSet = approvalInfoSets.get(criterion.CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__c);
            for (ApprovalCriteriaGroupInfo criteriaGroup : approvalInfoSet.criteriaGroups) {
                if (criteriaGroup.groupInfo.Id == criterion.CPQ_Playbook_Approval_Criteria_Group__c) {
                    criteriaGroup.criteria.add(approvalCriterionInfoSet);
                    break;
                }
            }
        }


        // All Approver Groups
        List<CPQ_Playbook_Approver_Group__c> approverGroups = new List<CPQ_Playbook_Approver_Group__c>();
        approverGroups = [
            SELECT Id,
                Approval_Order__c,
                Approvers_Required__c,
                CPQ_Playbook_Approval__c,
                IsActive__c,
                Name
            FROM CPQ_Playbook_Approver_Group__c
            WHERE CPQ_Playbook_Approval__c IN:approvalIDs
            ORDER BY IsActive__c DESC,
                Approval_Order__c ASC
        ];

        // Update Map of approval object
        for (CPQ_Playbook_Approver_Group__c approverGroup : approverGroups) {

            // Track all approver group IDs
            approverGroupIDs.add(approverGroup.Id);

            // Configure ApproverGroupInfo class object 
            ApproverGroupInfo approverGroupInfoSet = new ApproverGroupInfo();
            approverGroupInfoSet.groupInfo = approverGroup;
            approverGroupInfoSet.approvers = new List<ApproverInfo>();

            // Update map
            ApprovalInfo approvalInfoSet = approvalInfoSets.get(approverGroup.CPQ_Playbook_Approval__c);
            approvalInfoSet.approverGroups.add(approverGroupInfoSet);
        }

        // All Approvers
        List<CPQ_Playbook_Approver__c> approvers = new List<CPQ_Playbook_Approver__c>();
        approvers = [
            SELECT Id,
                Approver__c,
                Approver__r.Name,
                CPQ_Playbook_Approver_Group__c,
                CPQ_Playbook_Approver_Group__r.CPQ_Playbook_Approval__c,
                IsActive__c,
                Manager_Approver__c,
                Name
            FROM CPQ_Playbook_Approver__c
            WHERE CPQ_Playbook_Approver_Group__c IN:approverGroupIDs
            ORDER BY IsActive__c DESC,
                Name,
                Manager_Approver__c DESC
        ];

        // Update Map of approval object
        for (CPQ_Playbook_Approver__c approver : approvers) {

            // Configure ApproverInfo class object 
            ApproverInfo approverInfoSet = new ApproverInfo();
            approverInfoSet.approverInfo = approver;

            // Update map
            ApprovalInfo approvalInfoSet = approvalInfoSets.get(approver.CPQ_Playbook_Approver_Group__r.CPQ_Playbook_Approval__c);
            for (ApproverGroupInfo approverGroup : approvalInfoSet.approverGroups) {
                if (approverGroup.groupInfo.Id == approver.CPQ_Playbook_Approver_Group__c) {
                    approverGroup.approvers.add(approverInfoSet);
                    break;
                }
            }
        }

        // All Email Sections
        List<CPQ_Playbook_Approval_Email_Section__c> emailSections = new List<CPQ_Playbook_Approval_Email_Section__c>();
        emailSections = [
            SELECT Id,
                Answer_Table_Questions__c,
                Body_Text_Block_1__c,
                Body_Text_Block_2__c,
                Body_Text_Block_3__c,
                CPQ_Playbook_Approval__c,
                Display_Order__c,
                IsActive__c,
                Name,
                Record_Table_Query__c,
                Section_Type__c,
                Table_Entries_Font_Color__c,
                Table_Entries_Font_Size__c,
                Table_Headers_Font_Color__c,
                Table_Headers_Font_Size__c,
                (
                    SELECT Id,
                        ContentDocument.LatestPublishedVersionId
                    FROM AttachedContentDocuments
                )
            FROM CPQ_Playbook_Approval_Email_Section__c
            WHERE CPQ_Playbook_Approval__c IN:approvalIDs
            ORDER BY IsActive__c DESC,
                Display_Order__c ASC
        ];

        // Update Map of approval object
        for (CPQ_Playbook_Approval_Email_Section__c emailSection : emailSections) {

            // Configure EmailSectionInfo class object 
            EmailSectionInfo EmailSectionInfoSet = new EmailSectionInfo();
            EmailSectionInfoSet.sectionInfo = emailSection;

            // Update map
            ApprovalInfo approvalInfoSet = approvalInfoSets.get(emailSection.CPQ_Playbook_Approval__c);
            approvalInfoSet.emailSections.add(EmailSectionInfoSet);
        }

        // Update playbook map
        for (ApprovalInfo approvalInfoSet : approvalInfoSets.values()) {
            PlaybookInfo playbookInfoSet = playbookInfoSets.get(approvalInfoSet.approvalInfo.CPQ_Playbook__c);
            playbookInfoSet.approvals.add(approvalInfoSet);
        }


        // Proposal Sections

        // All Proposal Sections
        List<CPQ_Playbook_Proposal_Section__c> sections = new List<CPQ_Playbook_Proposal_Section__c>();
        sections = [
            SELECT Id,
                Allow_Mid_Section_Page_Break__c,
                Answer_Table_Questions__c,
                Body_Text_Block_1__c,
                Body_Text_Block_2__c,
                Body_Text_Block_3__c,
                CPQ_Playbook__c,
                Display_Order__c,
                Force_Page_Break_After__c,
                Force_Page_Break_Before__c,
                Inputs_Column_1__c,
                Inputs_Column_2__c,
                Inputs_Column_3__c,
                Inputs_Font_Color__c,
                Inputs_Font_Size__c,
                IsActive__c,
                Name,
                Record_Table_Query__c,
                Section_Type__c,
                Table_Entries_Font_Color__c,
                Table_Entries_Font_Size__c,
                Table_Headers_Font_Color__c,
                Table_Headers_Font_Size__c,
                (
                    SELECT Id,
                        ContentDocument.LatestPublishedVersionId
                    FROM AttachedContentDocuments
                )
            FROM CPQ_Playbook_Proposal_Section__c
            WHERE CPQ_Playbook__c IN:playbookIDs
            ORDER BY IsActive__c DESC,
                Display_Order__c ASC
        ];

        Set<Id> sectionIDs = new Set<Id>();
        Set<Id> sectionCriteriaGroupIDs = new Set<Id>();

        // Set Map of proposal section object
        Map<Id, SectionInfo> sectionInfoSets = new Map<Id, SectionInfo>();
        for (CPQ_Playbook_Proposal_Section__c section : sections) {
            // Track all section IDs
            sectionIDs.add(section.Id);

            // Configure SectionInfo class object 
            SectionInfo sectionInfoSet = new SectionInfo();
            sectionInfoSet.sectionInfo = section;
            sectionInfoSet.criteriaGroups = new List<SectionCriteriaGroupInfo>();

            // Add to map
            sectionInfoSets.put(section.Id, sectionInfoSet);
        }

        // All Criteria Groups
        List<CPQ_Playbook_Proposal_Criteria_Group__c> proposalCriteriaGroups = new List<CPQ_Playbook_Proposal_Criteria_Group__c>();
        proposalCriteriaGroups = [
            SELECT Id,
                CPQ_Playbook_Proposal_Section__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name
            FROM CPQ_Playbook_Proposal_Criteria_Group__c
            WHERE CPQ_Playbook_Proposal_Section__c IN:sectionIDs
            ORDER BY IsActive__c DESC,
                Name
        ];

        // Update Map of section object
        for (CPQ_Playbook_Proposal_Criteria_Group__c criteriaGroup : proposalCriteriaGroups) {

            // Track all criteria group IDs
            sectionCriteriaGroupIDs.add(criteriaGroup.Id);

            // Configure SectionCriteriaGroupInfo class object 
            SectionCriteriaGroupInfo sectionCriteriaGroupInfoSet = new SectionCriteriaGroupInfo();
            sectionCriteriaGroupInfoSet.groupInfo = criteriaGroup;
            sectionCriteriaGroupInfoSet.criteria = new List<SectionCriterionInfo>();

            // Update map
            SectionInfo sectionInfoSet = sectionInfoSets.get(criteriaGroup.CPQ_Playbook_Proposal_Section__c);
            sectionInfoSet.criteriaGroups.add(sectionCriteriaGroupInfoSet);
        }

        // All Criteria
        List<CPQ_Playbook_Proposal_Criterion__c> sectionCriteria = new List<CPQ_Playbook_Proposal_Criterion__c>();
        sectionCriteria = [
            SELECT Id,
                Comparison_Operator__c,
                Comparison_Value_Boolean__c,
                Comparison_Value_Currency__c,
                Comparison_Value_Date__c,
                Comparison_Value_Decimal__c,
                Comparison_Value_Integer__c,
                Comparison_Value_Text__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.Answer_Type__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Proposal_Criteria_Group__c,
                CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__c,
                Criterion_Source__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name,
                Product__c,
                Product_Criterion_Target_Rule_Action__c,
                Product_Field__c,
                Product_Field_Type__c,
                Target_Manual_Addition_Only__c
            FROM CPQ_Playbook_Proposal_Criterion__c
            WHERE CPQ_Playbook_Proposal_Criteria_Group__c IN:sectionCriteriaGroupIDs
            ORDER BY IsActive__c DESC,
                Name
        ];

        // Update Map of section object
        for (CPQ_Playbook_Proposal_Criterion__c criterion : sectionCriteria) {

            // Configure SectionCriterionInfo class object 
            SectionCriterionInfo sectionCriterionInfoSet = new SectionCriterionInfo();
            sectionCriterionInfoSet.criterionInfo = criterion;

            // Update map
            SectionInfo sectionInfoSet = sectionInfoSets.get(criterion.CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__c);
            for (SectionCriteriaGroupInfo criteriaGroup : sectionInfoSet.criteriaGroups) {
                if (criteriaGroup.groupInfo.Id == criterion.CPQ_Playbook_Proposal_Criteria_Group__c) {
                    criteriaGroup.criteria.add(sectionCriterionInfoSet);
                    break;
                }
            }
        }

        // Update playbook map
        for (SectionInfo sectionInfoSet : sectionInfoSets.values()) {
            PlaybookInfo playbookInfoSet = playbookInfoSets.get(sectionInfoSet.sectionInfo.CPQ_Playbook__c);
            playbookInfoSet.proposalSections.add(sectionInfoSet);
        }

        return playbookInfoSets.values();
    }

    public class PlaybookInfo {
        @AuraEnabled public CPQ_Playbook__c playbookInfo;
        @AuraEnabled public List<QuestionGroupInfo> questionGroups;
        @AuraEnabled public List<RuleInfo> rules;
        @AuraEnabled public List<ApprovalInfo> approvals;
        @AuraEnabled public List<SectionInfo> proposalSections;
    }

    public class QuestionGroupInfo {
        @AuraEnabled public CPQ_Playbook_Question_Group__c groupInfo;
        @AuraEnabled public List<QuestionInfo> questions;
    }

    public class QuestionInfo {
        @AuraEnabled public CPQ_Playbook_Question__c questionInfo;
    }

    public class RuleInfo {
        @AuraEnabled public CPQ_Playbook_Rule__c ruleInfo;
        @AuraEnabled public List<CriteriaGroupInfo> criteriaGroups;
        @AuraEnabled public List<ActionInfo> actions;
    }

    public class CriteriaGroupInfo {
        @AuraEnabled public CPQ_Playbook_Rule_Criteria_Group__c groupInfo;
        @AuraEnabled public List<CriterionInfo> criteria;
    }

    public class CriterionInfo {
        @AuraEnabled public CPQ_Playbook_Rule_Criterion__c criterionInfo;
    }

    public class ActionInfo {
        @AuraEnabled public CPQ_Playbook_Rule_Action__c actionInfo;
        @AuraEnabled public List<CalculationItemInfo> calculationItems;
    }

    public class CalculationItemInfo {
        @AuraEnabled public CPQ_Playbook_Rule_Calculation_Item__c itemInfo;
    }

    public class ApprovalInfo {
        @AuraEnabled public CPQ_Playbook_Approval__c approvalInfo;
        @AuraEnabled public List<ApprovalCriteriaGroupInfo> criteriaGroups;
        @AuraEnabled public List<ApproverGroupInfo> approverGroups;
        @AuraEnabled public List<EmailSectionInfo> emailSections;
    }

    public class ApprovalCriteriaGroupInfo {
        @AuraEnabled public CPQ_Playbook_Approval_Criteria_Group__c groupInfo;
        @AuraEnabled public List<ApprovalCriterionInfo> criteria;
    }

    public class ApprovalCriterionInfo {
        @AuraEnabled public CPQ_Playbook_Approval_Criterion__c criterionInfo;
    }

    public class ApproverGroupInfo {
        @AuraEnabled public CPQ_Playbook_Approver_Group__c groupInfo;
        @AuraEnabled public List<ApproverInfo> approvers;
    }

    public class ApproverInfo {
        @AuraEnabled public CPQ_Playbook_Approver__c approverInfo;
    }

    public class EmailSectionInfo {
        @AuraEnabled public CPQ_Playbook_Approval_Email_Section__c sectionInfo;
    }

    public class SectionInfo {
        @AuraEnabled public CPQ_Playbook_Proposal_Section__c sectionInfo;
        @AuraEnabled public List<SectionCriteriaGroupInfo> criteriaGroups;
    }

    public class SectionCriteriaGroupInfo {
        @AuraEnabled public CPQ_Playbook_Proposal_Criteria_Group__c groupInfo;
        @AuraEnabled public List<SectionCriterionInfo> criteria;
    }

    public class SectionCriterionInfo {
        @AuraEnabled public CPQ_Playbook_Proposal_Criterion__c criterionInfo;
    }

    /**
    * @description Query all pricebooks in system as well as all nested child pricebook entry records
    * @return List of Pricebook records with PricebookEntries
    */
    @AuraEnabled
    public static List<PricebookInfo> getPricebooks() {

        // All Pricebooks
        List<Pricebook2> pricebooks = new List<Pricebook2>();
        pricebooks = [
            SELECT Id,
                Description,
                IsActive,
                IsStandard,
                Name,
                (
                    SELECT Id,
                        IsActive,
                        Adjustable_Product_Columns__c,
                        UnitPrice,
                        Manually_Addible__c,
                        Pricebook2Id,
                        Pricing_Set_Identifier__c,
                        Product2Id,
                        Product2.Name,
                        Quantity__c,
                        Removable__c
                    FROM PricebookEntries
                    WHERE Currency__c = null
                ),
                (
                    SELECT Id,
                        IsActive__c,
                        Name
                    FROM CPQ_Playbooks__r
                    ORDER BY IsActive__c DESC, Name
                )
            FROM Pricebook2
            WHERE Parent_Price_Book__c = null
            ORDER BY IsActive DESC,
                Name
        ];

        // Pricebook Sets
        List<PricebookInfo> pricebookInfoSets = new List<PricebookInfo>();
        for (Pricebook2 pricebook : pricebooks) {

            // Configure PricebookInfo class object 
            PricebookInfo pricebookInfoSet = new PricebookInfo();
            pricebookInfoSet.pricebookInfo = pricebook;
            pricebookInfoSet.entries = pricebook.PricebookEntries;
            pricebookInfoSet.pricingSets = new List<CPQ_Pricing_Set__c>();

            pricebookInfoSets.add(pricebookInfoSet);
        }

        for (CPQ_Pricing_Set__c pricingSet : [
            SELECT Id,
                IsActive__c,
                Identifier__c,
                Name,
                Pricing_Type__c,
                Pricebook__c,
                Tiering_Field__c,
                (
                    SELECT Id,
                        IsActive__c,
                        Name,
                        Lower_Bound__c,
                        Upper_Bound__c,
                        Unit_Price__c
                    FROM CPQ_Pricing_Thresholds__r
                    ORDER BY Lower_Bound__c, Upper_Bound__c
                )
            FROM CPQ_Pricing_Set__c
        ]) {
            for (PricebookInfo pricebookInfoSet : pricebookInfoSets) {
                if (pricingSet.Pricebook__c == pricebookInfoSet.pricebookInfo.Id) {
                    pricebookInfoSet.pricingSets.add(pricingSet);
                }
            }
        }

        return pricebookInfoSets;
    }

    public class PricebookInfo {
        @AuraEnabled public Pricebook2 pricebookInfo;
        @AuraEnabled public List<PricebookEntry> entries;
        @AuraEnabled public List<CPQ_Pricing_Set__c> pricingSets;
    }

    /**
    * @description Query all products in system
    * @return List of Product records
    */
    @AuraEnabled
    public static List<Product2> getProducts() {

        // All Products
        List<Product2> products = new List<Product2>();
        products = [
            SELECT Id,
                Description,
                Family,
                IsActive,
                Name,
                ProductCode,
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule_Criteria_Group__c,
                        CPQ_Playbook_Rule_Criteria_Group__r.Name,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Criteria__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Approval_Criteria_Group__c,
                        CPQ_Playbook_Approval_Criteria_Group__r.Name,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__c,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.Name,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.CPQ_Playbook__c,
                        CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Approval_Criteria__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Proposal_Criteria_Group__c,
                        CPQ_Playbook_Proposal_Criteria_Group__r.Name,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__c,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.Name,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.CPQ_Playbook__c,
                        CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Proposal_Criteria__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Actions__r
                    ORDER BY IsActive__c DESC, Name
                ),
                (
                    SELECT Id,
                        Action_Name__c,
                        Name,
                        IsActive__c,
                        CPQ_Playbook_Rule_Action__c,
                        CPQ_Playbook_Rule_Action__r.Name,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__c,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.Name,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name
                    FROM CPQ_Playbook_Rule_Calculation_Items__r
                    ORDER BY IsActive__c DESC, Name
                )
            FROM Product2
            ORDER BY IsActive DESC,
                Name
        ];

        return products;
    }

    /**
    * @description Get Question Answer_Type__c field value for given question
    * @param questionId Id of question record
    * @return Answer_Type__c field value
    */
    @AuraEnabled
    public static String getQuestionType(Id questionId) {
        return [
            SELECT Answer_Type__c
            FROM CPQ_Playbook_Question__c
            WHERE Id=:questionId
        ].Answer_Type__c;
    }

    /**
    * @description Get Field Type for given field, obj
    * @param field Field API name
    * @param obj Object API Name
    * @return Field type value
    */
    @AuraEnabled
    public static String getFieldType(String field, String objectName) {

        // Describe object
        SObjectType objType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult obj = objType.getDescribe();

        String fieldType;
            
        // Valid field
        if (obj.fields
            .getMap()
            .containsKey(field)
        ) {
            Schema.DisplayType fieldDisplayType = obj.fields
                .getMap()
                .get(field)
                .getDescribe()
                .getType();

            if (fieldDisplayType == Schema.DisplayType.Boolean) {
                fieldType = 'Boolean';
            }
            else if (fieldDisplayType == Schema.DisplayType.Currency) {
                fieldType = 'Currency';
            }
            else if (fieldDisplayType == Schema.DisplayType.Date ||
                fieldDisplayType == Schema.DisplayType.DateTime
            ) {
                fieldType = 'Date';
            }
            else if (fieldDisplayType == Schema.DisplayType.Double ||
                fieldDisplayType == Schema.DisplayType.Integer ||
                fieldDisplayType == Schema.DisplayType.Long ||
                fieldDisplayType == Schema.DisplayType.Percent
            ) {
                fieldType = 'Decimal';
            }
            else {
                fieldType = 'Text';
            }
        }

        return fieldType;
    }

    /**
    * @description Get Field Type for given lookup field, question
    * @param field Field API name
    * @param questionId Related Question record Id
    * @return Field type value
    */
    @AuraEnabled
    public static String getLookupFieldType(String field, Id questionId) {

        // Find Question
        CPQ_Playbook_Question__c question = [
            SELECT Id,
                Query_String__c
            FROM CPQ_Playbook_Question__c
            WHERE Id=:questionId
        ];

        // Get Object
        String objectName = question.Query_String__c.toLowerCase().split('from')[1].split(' ')[1];

        // Get Field Type
        String fieldType = getFieldType(field, objectName);

        return fieldType;
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
    * @description Generic method to insert a list of sObject records
    * @param records List of sObject records
    */
    @AuraEnabled
    public static void insertRecords(List<sObject> records) {
        insert records;
    }

    /**
    * @description Generic method to clone an sObject record
    * @param recordId Id of sObejct record to be cloned
    * @param objectAPI API Name of sObejct that the record belongs to
    * @return new sObject record
    */
    @AuraEnabled
    public static sObject cloneRecord(String recordId, String objectAPI) {

        // Get fields for sObject
        SObjectType objType = ((SObject)(Type.forName('Schema.' + objectAPI).newInstance())).getSObjectType();
        DescribeSObjectResult obj = objType.getDescribe();
        List<String> fields = new List<String>();
        for (String field : obj.fields.getMap().keySet()) {
            fields.add(field);
        }

        // Query for record
        String qry = 'SELECT ' + string.join(fields, ',') + ' FROM ' + objectAPI + ' WHERE Id =:recordId';
        sObject existingRecord = Database.query(qry);

        // Clone record
        sObject clonedRecord = existingRecord.clone(false, false, false, false);

        // Adjust fields on cloned record
        if (objectAPI == 'CPQ_Playbook_Question__c') {
            clonedRecord.put('Variable_Name__c', '*' + clonedRecord.get('Variable_Name__c'));
        }
        if (objectAPI == 'CPQ_Pricing_Set__c') {
            clonedRecord.put('Identifier__c', '*' + clonedRecord.get('Identifier__c'));
        }
        String currentName = (String) clonedRecord.get('Name');
        clonedRecord.put('Name', 'CLONE: ' + currentName.left(73));

        // Insert cloned record
        insert clonedRecord;

        // Return cloned record
        return clonedRecord;
    }

}