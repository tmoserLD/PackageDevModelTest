/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ Quote Configuration controller class
*
* Tested by cpq_ConfigQuoteClassTest
*/
public with sharing class cpq_ConfigQuoteClass {

    // /////////////////////////////////////////////////////
    // Retrievals

    /**
    * @description Query all necessary info for quote configuration
    * @param adjustingContract Id of Contract record being upgraded for this quote configuration
    * @return ConfigInfo object
    */
    @AuraEnabled
    public static ConfigInfo getConfigInfo(Id adjustingContract, Boolean contractView) {

        // Return wrapper obj
        ConfigInfo configObj = new ConfigInfo();
        configObj.playbooks = new List<PlaybookInfo>();
        configObj.rules = new List<RuleInfo>();
        configObj.approvals = new List<ApprovalInfo>();
        configObj.pricebooks = new List<PricebookInfo>();
        configObj.currencyMap = getCurrencyMap(System.UserInfo.isMultiCurrencyOrganization());

        // Check if User is CPQ Admin
        configObj.isCPQAdmin = false;
        for (PermissionSetAssignment permSetAssignment : [
            SELECT
                Id
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'CPQ_Admin' AND
                AssigneeId=:System.UserInfo.getUserId()
        ]) {
            configObj.isCPQAdmin = true;
        }

        // Custom QLI Fields being stamped and shown as columns
        Boolean hasCustomField = false;
        Set<String> standardFields = new Set<String>{
            'Quantity',
            'Unit_Price',
            'List_Price',
            'Start_Date',
            'End_Date',
            'Manually_Addible',
            'Pricing_Set_Identifier',
            'Removable'
        };
        SObjectType qliType;
        DescribeSObjectResult qliObject;
        SObjectType entType;
        DescribeSObjectResult entObject;

        // PricebookEntry Base Fields
        Set<String> pricebookEntryFields = new Set<String>{
            'Id',
            'Adjustable_Product_Columns__c',
            'Currency__c',
            'Manually_Addible__c',
            'Pricing_Set_Identifier__c',
            'Product2Id',
            'Product2.Name',
            'Quantity__c',
            'Removable__c',
            'UnitPrice',
            'UseStandardPrice'
        };
        if (System.UserInfo.isMultiCurrencyOrganization() == true) {
            pricebookEntryFields.add('CurrencyIsoCode');
        }

        // Contract_Entitlement__c Base Fields
        Set<String> entitlementFields = new Set<String>{
            'Id',
            'CPQ_Playbook_Rule_Action__c',
            'Discount__c',
            'End_Date__c',
            'List_Price__c',
            'Product__c',
            'Quantity__c',
            'Start_Date__c',
            'SubTotal_Price__c',
            'Total_Price__c',
            'Unit_Price__c',
            'Contract__r.ContractNumber'
        };

        // Contract Base Fields
        Set<String> contractFields = new Set<String>{
            'Id',
            'Contract_End_Date__c',
            'Contract_Start_Date__c',
            'Contract_Status__c',
            'Contract_Total__c',
            'CPQ_Playbook__c',
            'CPQ_Playbook__r.Pricebook__c',
            'Opportunity__c',
            'Opportunity__r.Name',
            'Quote__c'
        };
        if (System.UserInfo.isMultiCurrencyOrganization() == true) {
            contractFields.add('CurrencyIsoCode');
        }

        // PLAYBOOKS

        // Active Playbooks
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
                Product_Summary_Columns__c,
                Product_Summary_Group_by_Default__c,
                Product_Summary_Sort_by_Default__c,
                Quote_View_Display_Fields__c
            FROM CPQ_Playbook__c
            WHERE IsActive__c = TRUE AND
                Pricebook__r.IsActive = TRUE
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

            // Add to map
            playbookInfoSets.put(playbook.ID, playbookInfoSet);

            List<String> customQLIFields = new List<String>();
            if (playbook.Product_Summary_Columns__c != null) {
                for (String prodCol : playbook.Product_Summary_Columns__c.split(';')) {
                    customQLIFields.add(prodCol);

                    if (!standardFields.contains(prodCol) &&
                        contractView != true
                    ) {
                        hasCustomField = true;
                    }
                }
            }

            List<String> entColumnFields = new List<String>();
            if (playbook.Entitlement_Summary_Columns__c != null) {
                for (String entCol : playbook.Entitlement_Summary_Columns__c.split(';')) {
                    entitlementFields.add(entCol);
                    entColumnFields.add(entCol);
                }
            }

            playbookInfoSet.productColumns = new List<RecordColumn>();
            playbookInfoSet.entitlementColumns = new List<RecordColumn>();

            // Get Label Info on custom QLI fields
            if (hasCustomField) {
                if (qliType == null) {
                    qliType = ((SObject)(Type.forName('Schema.QuoteLineItem').newInstance())).getSObjectType();
                    qliObject = qliType.getDescribe();
                }
                for (String customField : customQLIFields) {
                    
                    // Custom QLI field
                    if (qliObject.fields
                        .getMap()
                        .containsKey(customField) &&
                        !standardFields.contains(customField)
                    ) {
                        RecordColumn newCol = new RecordColumn();
                        newCol.label = qliObject.fields
                            .getMap()
                            .get(customField)
                            .getDescribe()
                            .getLabel();
                        newCol.field = customField;
                        Schema.DisplayType fieldType = qliObject.fields
                            .getMap()
                            .get(customField)
                            .getDescribe()
                            .getType();

                        if (fieldType == Schema.DisplayType.Boolean) {
                            newCol.type = 'Boolean';
                        }
                        else if (fieldType == Schema.DisplayType.Currency) {
                            newCol.type = 'Currency';
                        }
                        else if (fieldType == Schema.DisplayType.Date ||
                            fieldType == Schema.DisplayType.DateTime
                        ) {
                            newCol.type = 'Date';
                        }
                        else if (fieldType == Schema.DisplayType.Double ||
                            fieldType == Schema.DisplayType.Integer ||
                            fieldType == Schema.DisplayType.Long
                        ) {
                            newCol.type = 'Number';
                        }
                        else if (fieldType == Schema.DisplayType.Percent) {
                            newCol.type = 'Percent';
                        }
                        else {
                            newCol.type = 'Text';
                        }

                        playbookInfoSet.productColumns.add(newCol);
                    }
                    // Standard CPQ
                    else {
                        RecordColumn newCol = new RecordColumn();
                        newCol.field = customField;
                        playbookInfoSet.productColumns.add(newCol);
                    }
                }
            } else {
                for (String customField : customQLIFields) {
                    RecordColumn newCol = new RecordColumn();
                    newCol.field = customField;
                    playbookInfoSet.productColumns.add(newCol);
                }
            }

            // Get Label Info on entitlement fields
            if (adjustingContract != null ||
                contractView == true
            ) {
                if (entType == null) {
                    entType = ((SObject)(Type.forName('Schema.Contract_Entitlement__c').newInstance())).getSObjectType();
                    entObject = entType.getDescribe();
                }
                for (String field : entColumnFields) {
                    
                    // Custom Entitlement field
                    if (entObject.fields
                        .getMap()
                        .containsKey(field)
                    ) {
                        RecordColumn newCol = new RecordColumn();
                        newCol.label = entObject.fields
                            .getMap()
                            .get(field)
                            .getDescribe()
                            .getLabel();
                        newCol.field = field;
                        Schema.DisplayType fieldType = entObject.fields
                            .getMap()
                            .get(field)
                            .getDescribe()
                            .getType();

                        if (fieldType == Schema.DisplayType.Boolean) {
                            newCol.type = 'Boolean';
                        }
                        else if (fieldType == Schema.DisplayType.Currency) {
                            newCol.type = 'Currency';
                        }
                        else if (fieldType == Schema.DisplayType.Date ||
                            fieldType == Schema.DisplayType.DateTime
                        ) {
                            newCol.type = 'Date';
                        }
                        else if (fieldType == Schema.DisplayType.Double ||
                            fieldType == Schema.DisplayType.Integer ||
                            fieldType == Schema.DisplayType.Long
                        ) {
                            newCol.type = 'Number';
                        }
                        else if (fieldType == Schema.DisplayType.Percent) {
                            newCol.type = 'Percent';
                        }
                        else {
                            newCol.type = 'Text';
                        }

                        playbookInfoSet.entitlementColumns.add(newCol);
                    }
                }
            }

            // Show Contract fields as product fields when viewing contract
            if (contractView == true) {
                playbookInfoSet.productColumns = playbookInfoSet.entitlementColumns;
                playbookInfoSet.playbookInfo.Product_Summary_Group_by_Default__c = playbookInfoSet.playbookInfo.Entitlement_Summary_Group_by_Default__c;
                playbookInfoSet.playbookInfo.Product_Summary_Sort_by_Default__c = playbookInfoSet.playbookInfo.Entitlement_Summary_Sort_by_Default__c;
            }
        }

        // Active Question Groups
        List<CPQ_Playbook_Question_Group__c> playbookQuestionGroups = new List<CPQ_Playbook_Question_Group__c>();
        playbookQuestionGroups = [
            SELECT Id,
                CPQ_Playbook__c,
                Default_Collapsed__c,
                Display_Order__c,
                IsActive__c,
                IsHidden__c,
                Label__c,
                Name
            FROM CPQ_Playbook_Question_Group__c
            WHERE CPQ_Playbook__c IN:playbookIDs AND
                IsActive__c = TRUE
            ORDER BY Display_Order__c ASC
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

        // Active Questions
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
                Query_String__c,
                Quote_Save_Field__c,
                Record_Display_Fields__c,
                Record_Selection_Behavior__c,
                Step_Value__c,
                Variable_Name__c
            FROM CPQ_Playbook_Question__c
            WHERE CPQ_Playbook_Question_Group__c IN:playbookQuestionGroupIDs AND
                IsActive__c = TRUE
            ORDER BY Display_Order__c ASC
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

            // Update Contract fields if applicable
            if (question.Default_Field_Value__c != null &&
                question.Default_Field_Value__c.split('\\.')[0] == 'Contract' &&
                question.Default_Field_Value__c.split('\\.').size() == 2
            ) {
                contractFields.add(question.Default_Field_Value__c.split('\\.')[1]);
            }
        }

        configObj.playbooks = playbookInfoSets.values();


        // RULES

        // Active Rules
        List<CPQ_Playbook_Rule__c> rules = new List<CPQ_Playbook_Rule__c>();
        rules = [
            SELECT Id,
                CPQ_Playbook__c,
                Execution_Order__c,
                Evaluate_When__c,
                IsActive__c,
                Name
            FROM CPQ_Playbook_Rule__c
            WHERE IsActive__c = TRUE AND
                CPQ_Playbook__c IN:playbookIDs
            ORDER BY Execution_Order__c ASC
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

        // Active Criteria Groups
        List<CPQ_Playbook_Rule_Criteria_Group__c> ruleCriteriaGroups = new List<CPQ_Playbook_Rule_Criteria_Group__c>();
        ruleCriteriaGroups = [
            SELECT Id,
                CPQ_Playbook_Rule__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name
            FROM CPQ_Playbook_Rule_Criteria_Group__c
            WHERE CPQ_Playbook_Rule__c IN:ruleIDs AND
                IsActive__c = TRUE
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

        // Active Criteria
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
            WHERE CPQ_Playbook_Rule_Criteria_Group__c IN:ruleCriteriaGroupIDs AND
                IsActive__c = TRUE
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

        // Active Actions
        List<CPQ_Playbook_Rule_Action__c> actions = new List<CPQ_Playbook_Rule_Action__c>();
        actions = [
            SELECT Id,
                Action_Type__c,
                Calculation_Type__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Rule__c,
                Execution_Order__c,
                IsActive__c,
                Name,
                Numeric_Math_Operator__c,
                Product__c,
                Product_Adjustment_Field__c,
                Product_Adjustment_Field_Type__c,
                Product_Adjustment_Target_Rule_Action__c,
                Product_Field_Value_Boolean__c,
                Product_Field_Value_Currency__c,
                Product_Field_Value_Date__c,
                Product_Field_Value_Decimal__c,
                Product_Field_Value_Integer__c,
                Product_Field_Value_Text__c,
                Question_Adjustment_Field__c,
                Question_Group_Adjustment_Field__c,
                Question_Field_Value_Boolean__c,
                Question_Field_Value_Currency__c,
                Question_Field_Value_Date__c,
                Question_Field_Value_Decimal__c,
                Question_Field_Value_Integer__c,
                Question_Field_Value_Text__c,
                Target_Manual_Addition_Only__c,
                Value_Source_Type__c
            FROM CPQ_Playbook_Rule_Action__c
            WHERE CPQ_Playbook_Rule__c IN:ruleIDs AND
                IsActive__c = TRUE
            ORDER BY Execution_Order__c ASC
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

        // Active Calculation Items
        List<CPQ_Playbook_Rule_Calculation_Item__c> calulationItems = new List<CPQ_Playbook_Rule_Calculation_Item__c>();
        calulationItems = [
            SELECT Id,
                Calculation_Source__c,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,
                CPQ_Playbook_Rule_Action__c,
                CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__c,
                Entitlement_Calculation_Field__c,
                Execution_Order__c,
                IsActive__c,
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
            WHERE CPQ_Playbook_Rule_Action__c IN:ruleActionIDs AND
                IsActive__c = TRUE
            ORDER BY Execution_Order__c ASC
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

            // Update pricebookEntryFields
            if (item.Calculation_Source__c == 'Product' &&
                item.Product_Calculation_Field__c != null &&
                item.Product__c != null &&
                item.Product_Is_Entitlement__c != true
            ) {
                // Ensure valid obj.field structure
                if (item.Product_Calculation_Field__c.split('\\.').size() == 2) {
                    // Ensure valid obj
                    if (item.Product_Calculation_Field__c.split('\\.')[0] == 'Product2') {
                        pricebookEntryFields.add(item.Product_Calculation_Field__c);
                    } else if (item.Product_Calculation_Field__c.split('\\.')[0] == 'PricebookEntry') {
                        pricebookEntryFields.add(item.Product_Calculation_Field__c.split('\\.')[1]);
                    }
                }
            }

            // Update entitlementFields
            if (item.Calculation_Source__c == 'Product' &&
                item.Entitlement_Calculation_Field__c != null &&
                item.Product__c != null &&
                item.Product_Is_Entitlement__c == true
            ) {
                // Ensure valid obj.field structure
                if (item.Entitlement_Calculation_Field__c.split('\\.').size() == 2) {
                    // Ensure valid obj
                    if (item.Entitlement_Calculation_Field__c.split('\\.')[0] == 'Product__r') {
                        entitlementFields.add(item.Entitlement_Calculation_Field__c);
                    }
                } else {
                    entitlementFields.add(item.Entitlement_Calculation_Field__c);
                }
            }
        }

        configObj.rules = ruleInfoSets.values();


        // Approvals

        // Active Approvals
        List<CPQ_Playbook_Approval__c> approvals = new List<CPQ_Playbook_Approval__c>();
        approvals = [
            SELECT Id,
                CPQ_Playbook__c,
                IsActive__c,
                Label__c,
                Name,
                Reason__c
            FROM CPQ_Playbook_Approval__c
            WHERE IsActive__c = TRUE AND
                CPQ_Playbook__c IN:playbookIDs
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

            // Add to map
            approvalInfoSets.put(approval.Id, approvalInfoSet);
        }

        // Active Criteria Groups
        List<CPQ_Playbook_Approval_Criteria_Group__c> approvalCriteriaGroups = new List<CPQ_Playbook_Approval_Criteria_Group__c>();
        approvalCriteriaGroups = [
            SELECT Id,
                CPQ_Playbook_Approval__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name
            FROM CPQ_Playbook_Approval_Criteria_Group__c
            WHERE CPQ_Playbook_Approval__c IN:approvalIDs AND
                IsActive__c = TRUE
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

        // Active Criteria
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
                Product_Is_Entitlement__c,
                Record_Lookup_Field__c,
                Record_Lookup_Field_Type__c,
                System_Value_Source__c,
                Target_Manual_Addition_Only__c
            FROM CPQ_Playbook_Approval_Criterion__c
            WHERE CPQ_Playbook_Approval_Criteria_Group__c IN:approvalCriteriaGroupIDs AND
                IsActive__c = TRUE
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


        // Active Approver Groups
        List<CPQ_Playbook_Approver_Group__c> approverGroups = new List<CPQ_Playbook_Approver_Group__c>();
        approverGroups = [
            SELECT Id,
                Approval_Order__c,
                Approvers_Required__c,
                CPQ_Playbook_Approval__c,
                IsActive__c,
                Name
            FROM CPQ_Playbook_Approver_Group__c
            WHERE CPQ_Playbook_Approval__c IN:approvalIDs AND
                IsActive__c = TRUE
            ORDER BY Approval_Order__c ASC
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

        // Active Approvers
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
            WHERE CPQ_Playbook_Approver_Group__c IN:approverGroupIDs AND
                IsActive__c = TRUE
            ORDER BY Manager_Approver__c DESC
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

        configObj.approvals = approvalInfoSets.values();


        // PRICEBOOKS

        // Active Pricebooks associated to active Playbooks
        List<Pricebook2> pricebooks = new List<Pricebook2>();
        String pricebookEntryFieldsString = '';
        for (String field : pricebookEntryFields) {
            pricebookEntryFieldsString += field + ',';
        }
        pricebookEntryFieldsString = pricebookEntryFieldsString.removeEnd(',');
        String pricebookQuery = 'SELECT Id,'
                                    + 'Description,'
                                    + 'IsActive,'
                                    + 'IsStandard,'
                                    + 'Name, '
                                + '('
                                    + 'SELECT '
                                    + pricebookEntryFieldsString
                                    + ' FROM PricebookEntries'
                                    + ' WHERE IsActive = true'
                                    + ' ORDER BY Pricebook2.Name, Product2.Name'
                                + ')'
                                + ' FROM Pricebook2'
                                + ' WHERE Id IN:pricebookIDs AND'
                                +  ' IsActive = true';
        pricebooks = Database.query(pricebookQuery);

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
                Identifier__c,
                Pricing_Type__c,
                Pricebook__c,
                Tiering_Field__c,
                (
                    SELECT Id,
                        Lower_Bound__c,
                        Upper_Bound__c,
                        Unit_Price__c
                    FROM CPQ_Pricing_Thresholds__r
                    WHERE IsActive__c = true
                    ORDER BY Lower_Bound__c, Upper_Bound__c
                )
            FROM CPQ_Pricing_Set__c
            WHERE Pricebook__c IN:pricebookIDs AND
                Pricebook__r.IsActive = true AND
                IsActive__c = true
        ]) {
            for (PricebookInfo pricebookInfoSet : pricebookInfoSets) {
                if (pricingSet.Pricebook__c == pricebookInfoSet.pricebookInfo.Id) {
                    pricebookInfoSet.pricingSets.add(pricingSet);
                }
            }
        }

        configObj.pricebooks = pricebookInfoSets;


        // Configure Entitlements query string for contract query if necessary
        configObj.entitlementFields = '';
        for (String field : entitlementFields) {
            configObj.entitlementFields += field + ',';
        }
        configObj.entitlementFields = configObj.entitlementFields.removeEnd(',');

        // Configure Contracts query string for contract query if necessary
        configObj.contractFields = '';
        for (String field : contractFields) {
            configObj.contractFields += field + ',';
        }
        configObj.contractFields = configObj.contractFields.removeEnd(',');

        return configObj;
    }

    public class ConfigInfo {
        @AuraEnabled public List<PlaybookInfo> playbooks;
        @AuraEnabled public List<RuleInfo> rules;
        @AuraEnabled public List<ApprovalInfo> approvals;
        @AuraEnabled public List<PricebookInfo> pricebooks;
        @AuraEnabled public String contractFields;
        @AuraEnabled public String entitlementFields; 
        @AuraEnabled public Map<String, Double> currencyMap;
        @AuraEnabled public Boolean isCPQAdmin;
    }

    public class PlaybookInfo {
        @AuraEnabled public CPQ_Playbook__c playbookInfo;
        @AuraEnabled public List<QuestionGroupInfo> questionGroups;
        @AuraEnabled public List<RecordColumn> productColumns; 
        @AuraEnabled public List<RecordColumn> entitlementColumns;
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

    public class PricebookInfo {
        @AuraEnabled public Pricebook2 pricebookInfo;
        @AuraEnabled public List<PricebookEntry> entries;
        @AuraEnabled public List<CPQ_Pricing_Set__c> pricingSets;
    }

    public class RecordColumn {
        @AuraEnabled public String label;
        @AuraEnabled public String field;
        @AuraEnabled public String type;
    }

    /**
    * @description Populate and retrieve currency conversion map
    * @param multiCurrency Whether or not org is a multicurrency org or not
    * @return Currency Conversion Map: Currency => Conversion Rate (from org default currency)
    */
    private static Map<String, Double> getCurrencyMap(Boolean multiCurrency) {

        Map<String, Double> currencyMap = new Map<String, Double>();

        if (multiCurrency == true) {
            List<sObject> currencies = Database.query('SELECT Id, ConversionRate, IsoCode FROM CurrencyType WHERE IsActive = TRUE');
            for (sObject c : currencies) {
                currencyMap.put((String) c.get('IsoCode'), (Double) c.get('ConversionRate'));
            }
        } else {
            currencyMap.put(System.UserInfo.getDefaultCurrency(), 1);
        }

        return currencyMap;
    }

    /**
    * @description Query contract info
    * @param contractId Id of Contract record info is needed for
    * @param contractFields Comma delineated list of Contract field API names that should be included in the base query
    * @param entitlementFields Comma delineated list of Contract_Entitlement__c field API names that should be included in the sub-query
    * @return Contract record with child answers and entitlements
    */
    @AuraEnabled
    public static Contract getContractInfo(Id contractId, String contractFields, String entitlementFields) {

        Contract cont = new Contract();
        String contractQuery = 'SELECT '
                + contractFields
                + ',('
                    + 'SELECT '
                        + 'Id,'
                        + 'CPQ_Playbook_Question__c,'
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c,'
                        + 'CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__r.CPQ_Playbook__c,'
                        + 'Selected_Records_String__c,'
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
                        +  entitlementFields
                    + ' FROM Contract_Entitlements__r'
                + ')'
            + ' FROM Contract'
            + ' WHERE Id=:contractId';
        cont = Database.query(contractQuery);

        return cont;
    }


    // /////////////////////////////////////////////////////
    // Actions


    /**
    * @description Save and associate quote configuration data into database records
    * @param quoteToSave Unsaved Quote record data
    * @param quoteLineItems List of Unsaved QuoteLineItem record data
    * @param playbookAnswers List of Unsaved CPQ_Playbook_Answer__c record data
    * @param quoteApprovals List of Unsaved CPQ_Quote_Approval__c record data
    * @param quoteApprovalSteps List of List of Unsaved CPQ_Quote_Approval_Step__c record data
    * @param quoteApprovers List of List of List of Unsaved CPQ_Quote_Approver__c record data
    * @param oppCurrency CurrencyIsoCode of opportunity
    * @param defaultCurrency Corporate CurrencyIsoCode of org
    * @param selectedPricebookEntries pricebook entries of pricebook used in CPQ configuration
    */
    @AuraEnabled
    public static Id saveQuoteConfiguration(
        Quote quoteToSave,
        List<QuoteLineItem> quoteLineItems,
        List<CPQ_Playbook_Answer__c> playbookAnswers,
        List<CPQ_Quote_Approval__c> quoteApprovals,
        List<List<CPQ_Quote_Approval_Step__c>> quoteApprovalSteps,
        List<List<List<CPQ_Quote_Approver__c>>> quoteApprovers,
        String oppCurrency,
        String defaultCurrency,
        List<PricebookEntry> selectedPricebookEntries
    ) {

        // Ensure proper pricebook
        Boolean adjustPricebookRecords = (oppCurrency != defaultCurrency && System.UserInfo.isMultiCurrencyOrganization());
        if (adjustPricebookRecords == true) {
            // Get existing entries of opp currency in standard price book
            String standardPriceBookQuery = ''
                + 'SELECT Id,'
                    + '('
                        + 'SELECT Id,'
                            + 'Product2Id,'
                            + 'Pricebook2Id'
                        + ' FROM PricebookEntries'
                        + ' WHERE CurrencyIsoCode =:oppCurrency'
                    + ')'
                + ' FROM Pricebook2'
                + ' WHERE IsStandard = true'
                + ' LIMIT 1';
            Pricebook2 standardPriceBook = Database.query(standardPriceBookQuery);
            Set<Id> standardPricebookProducts = new Set<Id>();
            for (PricebookEntry entry : standardPriceBook.PricebookEntries) {
                standardPricebookProducts.add(entry.Product2Id);
            }
            // Find existing child price book
            List<Pricebook2> childPriceBooks = new List<Pricebook2>();
            childPriceBooks = [
                SELECT Id,
                    Name,
                    (
                        SELECT Id,
                            Product2Id,
                            Pricebook2Id,
                            Quantity__c,
                            UnitPrice
                        FROM PricebookEntries
                        WHERE IsActive = true
                    )
                FROM Pricebook2
                WHERE Parent_Price_Book__c =:quoteToSave.Pricebook2Id AND
                    Currency__c =:oppCurrency
                LIMIT 1
            ];
            // Child price book exists
            if (childPriceBooks.size() > 0) {
                // Associate to quote
                quoteToSave.Pricebook2Id = childPriceBooks[0].Id;

                // Check for entry differences
                Set<Id> childPricebookProducts = new Set<Id>();
                for (PricebookEntry entry : childPriceBooks[0].PricebookEntries) {
                    childPricebookProducts.add(entry.Product2Id);
                }
                List<PricebookEntry> missingChildProductEntries = new List<PricebookEntry>();
                for (PricebookEntry entry : selectedPricebookEntries) {
                    if (!childPricebookProducts.contains(entry.Product2Id)) {
                        missingChildProductEntries.add(entry);
                    }
                }

                // Create missing entries if necessary
                List<PricebookEntry> newChildEntries = new List<PricebookEntry>();
                for (PricebookEntry entry : missingChildProductEntries) {
                    // Ensure entry exists on standard pricebook
                    if (!standardPricebookProducts.contains(entry.Product2Id)) {
                        PricebookEntry standardEntry = new PricebookEntry(
                            IsActive = true,
                            UnitPrice = entry.UnitPrice, // Consider adjusting for currency -- although irrelevant since this is more of a formality
                            Quantity__c = entry.Quantity__c,
                            Product2Id = entry.Product2Id,
                            Pricebook2Id = standardPriceBook.Id,
                            Currency__c = oppCurrency
                        );
                        standardEntry.put('CurrencyIsoCode', oppCurrency);
                        newChildEntries.add(standardEntry); 
                    }
                    // New child entry
                    PricebookEntry childEntry = new PricebookEntry(
                        IsActive = true,
                        UnitPrice = entry.UnitPrice, // Consider adjusting for currency -- although irrelevant since this is more of a formality
                        Quantity__c = entry.Quantity__c,
                        Product2Id = entry.Product2Id,
                        Pricebook2Id = childPriceBooks[0].Id,
                        Currency__c = oppCurrency
                    );
                    childEntry.put('CurrencyIsoCode', oppCurrency);
                    newChildEntries.add(childEntry);
                }
                if (newChildEntries.size() > 0) {
                    insert newChildEntries;
                }

                // Associate to qlis
                for (QuoteLineItem qli : quoteLineItems) {
                    for (PricebookEntry entry : childPriceBooks[0].PricebookEntries) {
                        if (qli.Product2Id == entry.Product2Id &&
                            quoteToSave.Pricebook2Id == entry.Pricebook2Id
                        ) {
                            qli.PricebookEntryId = entry.Id;
                        }
                    }
                    for (PricebookEntry entry : newChildEntries) {
                        if (qli.Product2Id == entry.Product2Id &&
                            quoteToSave.Pricebook2Id == entry.Pricebook2Id
                        ) {
                            qli.PricebookEntryId = entry.Id;
                        }
                    }
                }
            }
            // Child price book does not exist
            else {
                // Create child price book
                Pricebook2 childPriceBook = new Pricebook2(
                    Name = oppCurrency + ' (' + quoteToSave.Pricebook2Id + ')',
                    Description = 'Child Price Book of ' + quoteToSave.Pricebook2Id + ' for the currency of ' + oppCurrency,
                    Currency__c = oppCurrency,
                    IsActive = true,
                    Parent_Price_Book__c = quoteToSave.Pricebook2Id
                );
                childPriceBook.put('CurrencyIsoCode', oppCurrency);
                insert childPriceBook;

                // Associate to quote
                quoteToSave.Pricebook2Id = childPriceBook.Id;

                // Create child price book entries
                List<PricebookEntry> childPriceBookEntries = new List<PricebookEntry>();
                for (PricebookEntry entry : selectedPricebookEntries) {
                    // Ensure entry exists on standard pricebook
                    if (!standardPricebookProducts.contains(entry.Product2Id)) {
                        PricebookEntry standardEntry = new PricebookEntry(
                            IsActive = true,
                            UnitPrice = entry.UnitPrice, // Consider adjusting for currency -- although irrelevant since this is more of a formality
                            Quantity__c = entry.Quantity__c,
                            Product2Id = entry.Product2Id,
                            Pricebook2Id = standardPriceBook.Id,
                            Currency__c = oppCurrency
                        );
                        standardEntry.put('CurrencyIsoCode', oppCurrency);
                        childPriceBookEntries.add(standardEntry); 
                    }
                    // New child entry
                    PricebookEntry childEntry = new PricebookEntry(
                        IsActive = true,
                        UnitPrice = entry.UnitPrice, // Consider adjusting for currency -- although irrelevant since this is more of a formality
                        Quantity__c = entry.Quantity__c,
                        Product2Id = entry.Product2Id,
                        Pricebook2Id = childPriceBook.Id,
                        Currency__c = oppCurrency
                    );
                    childEntry.put('CurrencyIsoCode', oppCurrency);
                    childPriceBookEntries.add(childEntry);
                }
                insert childPriceBookEntries;

                // Associate to qlis
                for (QuoteLineItem qli : quoteLineItems) {
                    for (PricebookEntry entry : childPriceBookEntries) {
                        if (qli.Product2Id == entry.Product2Id &&
                            quoteToSave.Pricebook2Id == entry.Pricebook2Id
                        ) {
                            qli.PricebookEntryId = entry.Id;
                        }
                    }
                }
            }
        }

        // Save quote;
        upsert quoteToSave;

        // Get and delete existing QLIs on quote if applicable
        List<QuoteLineItem> existingQLIs = new List<QuoteLineItem>();
        existingQLIs = [
            SELECT Id
            FROM QuoteLineItem
            WHERE QuoteId=:quoteToSave.Id
        ];
        if (existingQLIs.size() > 0) {
            delete existingQLIs;
        }

        // Associate Quote to QLIs
        for (QuoteLineItem qli : quoteLineItems) {
            qli.QuoteId = quoteToSave.Id;
        }

        // Insert QLIs
        insert quoteLineItems;

        // Get and delete existing Playbook Answers on quote if applicable
        List<CPQ_Playbook_Answer__c> existingAnswers = new List<CPQ_Playbook_Answer__c>();
        existingAnswers = [
            SELECT Id
            FROM CPQ_Playbook_Answer__c
            WHERE Quote__c=:quoteToSave.Id
        ];
        if (existingAnswers.size() > 0) {
            delete existingAnswers;
        }

        // Associate Quote to Answers
        for (CPQ_Playbook_Answer__c answer : playbookAnswers) {
            answer.Quote__c = quoteToSave.Id;
            
            // Currency
            if (System.UserInfo.isMultiCurrencyOrganization() == true) {
                answer.put('CurrencyIsoCode', oppCurrency);
            }
        }

        // Insert Answers
        insert playbookAnswers;

        // Get and delete existing Approvals on quote if applicable
        List<CPQ_Quote_Approval__c> existingApprovals = new List<CPQ_Quote_Approval__c>();
        existingApprovals = [
            SELECT Id
            FROM CPQ_Quote_Approval__c
            WHERE Quote__c=:quoteToSave.Id
        ];
        if (existingApprovals.size() > 0) {
            delete existingApprovals;
        }

        // Associate Quote to Approvals
        for (CPQ_Quote_Approval__c approval : quoteApprovals) {
            approval.Quote__c = quoteToSave.Id;
        }

        // Insert Answers
        insert quoteApprovals;

        // Get and delete existing Approval Steps on quote if applicable
        List<CPQ_Quote_Approval_Step__c> existingApprovalSteps = new List<CPQ_Quote_Approval_Step__c>();
        existingApprovalSteps = [
            SELECT Id
            FROM CPQ_Quote_Approval_Step__c
            WHERE CPQ_Quote_Approval__r.Quote__c=:quoteToSave.Id
        ];
        if (existingApprovalSteps.size() > 0) {
            delete existingApprovalSteps;
        }

        // Associate Quote Approval Id to Steps
        List<CPQ_Quote_Approval_Step__c> steps = new List<CPQ_Quote_Approval_Step__c>();
        for (Integer index=0; index < quoteApprovalSteps.size(); index++) {
            for (CPQ_Quote_Approval_Step__c step : quoteApprovalSteps[index]) {
                step.CPQ_Quote_Approval__c = quoteApprovals[index].Id;
                steps.add(step);
            }
        }

        // Insert Steps
        insert steps;

        // Get and delete existing Approval Steps on quote if applicable
        List<CPQ_Quote_Approver__c> existingApprovers = new List<CPQ_Quote_Approver__c>();
        existingApprovers = [
            SELECT Id
            FROM CPQ_Quote_Approver__c
            WHERE CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c=:quoteToSave.Id
        ];
        if (existingApprovers.size() > 0) {
            delete existingApprovers;
        }

        // Associate Approval Step Id to Approvers
        List<CPQ_Quote_Approver__c> approvers = new List<CPQ_Quote_Approver__c>();
        for (Integer index=0; index < quoteApprovers.size(); index++) {
            for (Integer index2=0; index2 < quoteApprovers[index].size(); index2++) {
                for (CPQ_Quote_Approver__c approver : quoteApprovers[index][index2]) {
                    approver.CPQ_Quote_Approval_Step__c = quoteApprovalSteps[index][index2].Id;
                    approvers.add(approver);
                }
            }
        }

        // Save Approvers
        insert approvers;

        return quoteToSave.Id;
    }

    /**
    * @description Query records from query string
    * @param question CPQ_Playbook_Question__c record
    * @return sObject records and column info
    */
    @AuraEnabled
    public static QueryInfo queryLookupQuestion(CPQ_Playbook_Question__c question) {

        QueryInfo returnQueryInfo = new QueryInfo();
        returnQueryInfo.records = new List<sObject>();
        returnQueryInfo.recordCurrencies = new Map<Id, String>();

        // Query records
        String queryString = question.Query_String__c;
        returnQueryInfo.records = Database.query(queryString);

        // Get columns (if necessary)
        String recordColumns = question.Record_Display_Fields__c;
        returnQueryInfo.columns = new List<RecordColumn>();

        // Extract Object name from query string
        String objectName = queryString.toLowerCase().split('from')[1].split(' ')[1];

        // Describe objects
        SObjectType objType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult obj = objType.getDescribe();

        // Evaluate Record Columns
        for (String field : recordColumns.split(';')) {
            
            // Valid Quote field
            if (obj.fields
                .getMap()
                .containsKey(field)
            ) {
                RecordColumn newCol = new RecordColumn();
                newCol.label = obj.fields
                    .getMap()
                    .get(field)
                    .getDescribe()
                    .getLabel();
                newCol.field = field;
                Schema.DisplayType fieldType = obj.fields
                    .getMap()
                    .get(field)
                    .getDescribe()
                    .getType();

                if (fieldType == Schema.DisplayType.Boolean) {
                    newCol.type = 'Boolean';
                }
                else if (fieldType == Schema.DisplayType.Currency) {
                    newCol.type = 'Currency';
                }
                else if (fieldType == Schema.DisplayType.Date ||
                    fieldType == Schema.DisplayType.DateTime
                ) {
                    newCol.type = 'Date';
                }
                else if (fieldType == Schema.DisplayType.Double ||
                    fieldType == Schema.DisplayType.Integer ||
                    fieldType == Schema.DisplayType.Long
                ) {
                    newCol.type = 'Number';
                }
                else if (fieldType == Schema.DisplayType.Percent) {
                    newCol.type = 'Percent';
                }
                else {
                    newCol.type = 'Text';
                }

                returnQueryInfo.columns.add(newCol);
            }
        }

        // Determine currency of records
        if (System.UserInfo.isMultiCurrencyOrganization()) {
            Set<Id> recordIDs = new Set<Id>();
            for (sObject record : returnQueryInfo.records) {
                recordIDs.add((Id) record.get('Id'));
            }
            String recordQuery = ''
                + 'SELECT Id,'
                    + 'CurrencyIsoCode'
                + ' FROM ' + objectName
                + ' WHERE Id IN:recordIDs';
            for (sObject record : Database.query(recordQuery)) {
                returnQueryInfo.recordCurrencies.put((Id) record.get('Id'), (String) record.get('CurrencyIsoCode'));
            }
        } else {
            for (sObject record : returnQueryInfo.records) {
                returnQueryInfo.recordCurrencies.put((Id) record.get('Id'), System.UserInfo.getDefaultCurrency());
            }
        }

        return returnQueryInfo;
    }

    public class QueryInfo {
        @AuraEnabled public List<sObject> records;
        @AuraEnabled public List<RecordColumn> columns;
        @AuraEnabled public Map<Id, String> recordCurrencies;
    }
}
    