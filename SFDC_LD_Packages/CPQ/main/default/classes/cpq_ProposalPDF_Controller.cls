/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description Quote Proposal PDF VFP controller class
*
* Tested by cpq_ProposalPDF_ControllerTest
*/
public class cpq_ProposalPDF_Controller {
    public Id quoteId {get; set;}
    public CPQ_Playbook__c playbook {get; set;}
    public String playbookHeaderImageId {get; set;}
    public List<sectionObj> sections {get; set;}
    public String sectionsPassed {get; set;}

    /**
    * @description Constuctor method to build out PDF layout based on criteria and quote configuration
    * Populates playbook and sections public variables
    * quoteId set as VFP parameter
    */
    public cpq_ProposalPDF_Controller() {

        Id quoteRecordId = ApexPages.currentPage().getParameters().get('quoteId');
        sectionsPassed = '';

        // Quote Info
        Quote quoteInfo = [
            SELECT Id,
                Adjustment_of_Contract__c,
                Adjustment_Type__c,
                CPQ_Playbook__c,
                End_Date__c,
                Start_Date__c,
                SubTotal_Price__c,
                Total_Price__c
            FROM Quote
            WHERE Id=:quoteRecordId
        ];

        // Playbook
        playbook = [
            SELECT Id,
                Proposal_Header__c,
                Proposal_Header_Type__c,
                Proposal_Footer__c,
                (
                    SELECT Id,
                        ContentDocument.LatestPublishedVersionId
                    FROM AttachedContentDocuments
                )
            FROM CPQ_Playbook__c
            WHERE Id=:quoteInfo.CPQ_Playbook__c
        ];
        if (playbook.AttachedContentDocuments.size() > 0) {
            playbookHeaderImageId = playbook.AttachedContentDocuments[0].ContentDocument.LatestPublishedVersionId;
        }

        // EOL text wrap fix
        if (playbook.Proposal_Header__c != null) {
            playbook.Proposal_Header__c = playbook.Proposal_Header__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
        }
        if (playbook.Proposal_Footer__c != null) {
            playbook.Proposal_Footer__c = playbook.Proposal_Footer__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
        }

        // Sections that meet critieria
        sections = new List<sectionObj>();

        // Question to Quote Answer Map
        Map<String, CPQ_Playbook_Answer__c> answerMap = new Map<String, CPQ_Playbook_Answer__c>();
        for (CPQ_Playbook_Answer__c answer : [
            SELECT Id,
                CPQ_Playbook_Question__c,
                CPQ_Playbook_Question__r.Answer_Type__c,
                CPQ_Playbook_Question__r.Proposal_Label__c,
                CPQ_Playbook_Question__r.Variable_Name__c,
                HasBeenTouched__c,
                Quote__c,
                Value_Boolean__c,
                Value_Currency__c,
                Value_Date__c,
                Value_Decimal__c,
                Value_Integer__c,
                Value_Text__c
            FROM CPQ_Playbook_Answer__c
            WHERE Quote__c=:quoteRecordId
        ]) {
            answerMap.put(answer.CPQ_Playbook_Question__r.Variable_Name__c, answer);
        }

        // All possible sections for playbook
        List<CPQ_Playbook_Proposal_Section__c> allSections = new List<CPQ_Playbook_Proposal_Section__c>();
        Set<Id> sectionIDs = new Set<Id>();
        Map<Id, List<CPQ_Playbook_Proposal_Criteria_Group__c>> criteriaGroupsMap = new Map<Id,List< CPQ_Playbook_Proposal_Criteria_Group__c>>();
        Set<String> productFields = new Set<String>{
            'CPQ_Playbook_Rule_Action__c',
            'Discount__c',
            'End_Date__c',
            'List_Price__c',
            'Product2Id',
            'Quantity__c',
            'Start_Date__c',
            'SubTotal_Price__c',
            'Total_Price__c',
            'Quoted_Price__c'
        };
        Set<String> entitlementFields = new Set<String>{
            'CPQ_Playbook_Rule_Action__c',
            'Discount__c',
            'End_Date__c',
            'List_Price__c',
            'Product__c',
            'Quantity__c',
            'Start_Date__c',
            'SubTotal_Price__c',
            'Total_Price__c',
            'Unit_Price__c'
        };
        for (CPQ_Playbook_Proposal_Section__c section : [
            SELECT Id,
                Allow_Mid_Section_Page_Break__c,
                Answer_Table_Questions__c,
                Body_Text_Block_1__c,
                Body_Text_Block_2__c,
                Body_Text_Block_3__c,
                CPQ_Playbook__c,
                Entitlement_Table_Fields__c,
                Force_Page_Break_After__c,
                Force_Page_Break_Before__c,
                Inputs_Column_1__c,
                Inputs_Column_2__c,
                Inputs_Column_3__c,
                Inputs_Font_Color__c,
                Inputs_Font_Size__c,
                IsActive__c,
                Name,
                Product_Table_QLI_Fields__c,
                Record_Table_Order_By_Clause__c,
                Record_Table_Where_Clause__c,
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
            WHERE CPQ_Playbook__c=:quoteInfo.CPQ_Playbook__c AND
                IsActive__c = true
            ORDER BY Display_Order__c ASC
        ]) {
            sectionIDs.add(section.Id);
            allSections.add(section);
            criteriaGroupsMap.put(section.Id, new List<CPQ_Playbook_Proposal_Criteria_Group__c>());

            if (section.Product_Table_QLI_Fields__c != null) {
                for (String field : section.Product_Table_QLI_Fields__c.split(';')) {
                    productFields.add(field);
                }
            }
            if (section.Entitlement_Table_Fields__c != null) {
                for (String field : section.Entitlement_Table_Fields__c.split(';')) {
                    entitlementFields.add(field);
                }
            }
        }

        // Query QLIs
        SObjectType qliType = ((SObject)(Type.forName('Schema.QuoteLineItem').newInstance())).getSObjectType();
        DescribeSObjectResult qliObject = qliType.getDescribe();
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        String qliQueryFields = '';
        for (String field : productFields) {
            qliQueryFields += field + ',';
        }
        qliQueryFields = qliQueryFields.substring(0, qliQueryFields.length()-1);
        String qliQueryString = 'SELECT ' + qliQueryFields + ' FROM QuoteLineItem WHERE QuoteId=\''+quoteRecordId+'\'';
        qlis = Database.query(qliQueryString);

        // Query Entitlements
        SObjectType entType = ((SObject)(Type.forName('Schema.Contract_Entitlement__c').newInstance())).getSObjectType();
        DescribeSObjectResult entObject = entType.getDescribe();
        List<Contract_Entitlement__c> entitlements = new List<Contract_Entitlement__c>();
        String entQueryFields = '';
        for (String field : entitlementFields) {
            entQueryFields += field + ',';
        }
        entQueryFields = entQueryFields.substring(0, entQueryFields.length()-1);
        String entQueryString = 'SELECT ' + entQueryFields + ' FROM Contract_Entitlement__c WHERE Contract__c=\''+quoteInfo.Adjustment_of_Contract__c+'\'';
        if (quoteInfo.Adjustment_of_Contract__c != null) {
            entitlements = Database.query(entQueryString);
        }

        // Criteria Groups and Criteria for all possible sections
        for (CPQ_Playbook_Proposal_Criteria_Group__c criteriaGroup : [
            SELECT Id,
                CPQ_Playbook_Proposal_Section__c,
                Evaluation_Logic__c,
                IsActive__c,
                N__c,
                Name,
                (
                    SELECT Id,
                        Comparison_Operator__c,
                        Comparison_Value_Boolean__c,
                        Comparison_Value_Currency__c,
                        Comparison_Value_Date__c,
                        Comparison_Value_Decimal__c,
                        Comparison_Value_Integer__c,
                        Comparison_Value_Text__c,
                        CPQ_Playbook_Question__c,
                        CPQ_Playbook_Question__r.Variable_Name__c,
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
                        Product_Is_Entitlement__c,
                        Target_Manual_Addition_Only__c
                    FROM CPQ_Playbook_Proposal_Criteria__r
                    WHERE IsActive__c = true
                )
            FROM CPQ_Playbook_Proposal_Criteria_Group__c
            WHERE CPQ_Playbook_Proposal_Section__c IN:sectionIDs AND
                IsActive__c = true
        ]) {
            criteriaGroupsMap.get(criteriaGroup.CPQ_Playbook_Proposal_Section__c).add(criteriaGroup);
        }

        // Evaluate each section to determine if it meets criteria
        for (CPQ_Playbook_Proposal_Section__c section : allSections) {

            // Assume true
            Boolean sectionEvaluation = true;

            // Set group Ns
            Map<String, Decimal> groupEvalN = new Map<String, Decimal>();
            groupEvalN.put('requireds', 1);
            groupEvalN.put('exactN_needed', 0);
            groupEvalN.put('exactN_passed', 0);
            groupEvalN.put('atLeastN_needed', -1);
            groupEvalN.put('atLeastN_passed', 0);
            groupEvalN.put('atMostN_needed', 1);
            groupEvalN.put('atMostN_passed', 0);

            // Evaluate Criteria Groups for this section
            for (CPQ_Playbook_Proposal_Criteria_Group__c criteriaGroup : criteriaGroupsMap.get(section.Id)) {

                // Assume true
                Boolean groupEvaluation = true;

                // Update needed Ns
                if (criteriaGroup.Evaluation_Logic__c == 'One of N required') {
                    groupEvalN.put('exactN_needed', criteriaGroup.N__c);
                }
                else if (criteriaGroup.Evaluation_Logic__c == 'One of at least N required') {
                    groupEvalN.put('atLeastN_needed', criteriaGroup.N__c);
                }
                else if (criteriaGroup.Evaluation_Logic__c == 'One of at most N required') {
                    groupEvalN.put('atMostN_needed', criteriaGroup.N__c);
                }

                // Set criteria Ns
                Map<String, Decimal> criterionEvalN = new Map<String, Decimal>();
                criterionEvalN.put('requireds', 1);
                criterionEvalN.put('exactN_needed', 0);
                criterionEvalN.put('exactN_passed', 0);
                criterionEvalN.put('atLeastN_needed', -1);
                criterionEvalN.put('atLeastN_passed', 0);
                criterionEvalN.put('atMostN_needed', 1);
                criterionEvalN.put('atMostN_passed', 0);

                // Evaluate each criterion
                for (CPQ_Playbook_Proposal_Criterion__c criterion : criteriaGroup.CPQ_Playbook_Proposal_Criteria__r) {

                    // Assume false, if no question found it remains false
                    Boolean criterionEvaluation = false;

                    // Update needed Ns
                    if (criterion.Evaluation_Logic__c == 'One of N required') {
                        criterionEvalN.put('exactN_needed', criterion.N__c);
                    }
                    else if (criterion.Evaluation_Logic__c == 'One of at least N required') {
                        criterionEvalN.put('atLeastN_needed', criterion.N__c);
                    }
                    else if (criterion.Evaluation_Logic__c == 'One of at most N required') {
                        criterionEvalN.put('atMostN_needed', criterion.N__c);
                    }

                    // Question
                    if (criterion.Criterion_Source__c == 'Question' &&
                        criterion.CPQ_Playbook_Question__c != null
                    ) {

                        // Find matching answer to question
                        CPQ_Playbook_Answer__c answer = answerMap.get(criterion.CPQ_Playbook_Question__r.Variable_Name__c);

                        // Evaluation by Comparison Type
                        if (answer != null) {
                            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean') {
                                criterionEvaluation = compareBoolean(answer.Value_Boolean__c, criterion.Comparison_Value_Boolean__c, criterion.Comparison_Operator__c);
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency') {
                                criterionEvaluation = compareDecimal(answer.Value_Currency__c, criterion.Comparison_Value_Currency__c, criterion.Comparison_Operator__c);
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date') {
                                criterionEvaluation = compareDate(answer.Value_Date__c, criterion.Comparison_Value_Date__c, criterion.Comparison_Operator__c);
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal') {
                                criterionEvaluation = compareDecimal(answer.Value_Decimal__c, criterion.Comparison_Value_Decimal__c, criterion.Comparison_Operator__c);
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer') {
                                criterionEvaluation = compareDecimal(answer.Value_Integer__c, criterion.Comparison_Value_Integer__c, criterion.Comparison_Operator__c);
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Multi-Select Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area'
                            ) {
                                criterionEvaluation = compareText(answer.Value_Text__c, criterion.Comparison_Value_Text__c, criterion.Comparison_Operator__c);
                            }
                        }
                    }
                    // Product
                    else if (criterion.Criterion_Source__c == 'Product' &&
                        criterion.Product__c != null
                    ) {

                        // Quote Product
                        if (criterion.Product_Is_Entitlement__c == false) {
                            for (QuoteLineItem qli : qlis) {
                                // Matching product
                                if (qli.Product2Id == criterion.Product__c &&
                                    (
                                        (
                                            criterion.Target_Manual_Addition_Only__c == false &&
                                            (
                                                criterion.Product_Criterion_Target_Rule_Action__c == null ||
                                                qli.CPQ_Playbook_Rule_Action__c == criterion.Product_Criterion_Target_Rule_Action__c
                                            )
                                        ) ||
                                        (
                                            criterion.Target_Manual_Addition_Only__c == true &&
                                            qli.CPQ_Playbook_Rule_Action__c == null
                                        )
                                    )
                                ) {
                                    // Comparison

                                    // Equality
                                    if (criterion.Comparison_Operator__c == 'Equals') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c == criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c == criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c == criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c == criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c == criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c == criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c == criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Equality Negation
                                    else if (criterion.Comparison_Operator__c == 'Does not equal') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c != criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c != criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c != criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c != criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c != criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c != criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c != criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Greater Than
                                    else if (criterion.Comparison_Operator__c == 'Greater than') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c > criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c > criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c > criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c > criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c > criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c > criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c > criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Greater than or equal
                                    else if (criterion.Comparison_Operator__c == 'Greater than or equal') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c >= criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c >= criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c >= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c >= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c >= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c >= criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c >= criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Less than
                                    else if (criterion.Comparison_Operator__c == 'Less than') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c < criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c < criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c < criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c < criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c < criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c < criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c < criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Less than or equal
                                    else if (criterion.Comparison_Operator__c == 'Less than or equal') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c <= criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c <= criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c <= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c <= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c <= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c <= criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c <= criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Empty
                                    else if (criterion.Comparison_Operator__c == 'Is empty') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (qli.Quantity__c == null);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (qli.Discount__c == null); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (qli.Quoted_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (qli.List_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (qli.Total_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (qli.Start_Date__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (qli.End_Date__c == null);
                                        }
                                    }
                                    // Not empty
                                    else if (criterion.Comparison_Operator__c == 'Is not empty') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = !(qli.Quantity__c == null);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = !(qli.Discount__c == null); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = !(qli.Quoted_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = !(qli.List_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = !(qli.Total_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = !(qli.Start_Date__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = !(qli.End_Date__c == null);
                                        }
                                    }
                                }
                            }
                        }
                        // Entitlements
                        else if (criterion.Product_Is_Entitlement__c == true) {
                            for (Contract_Entitlement__c ent : entitlements) {
                                // Matching product
                                if (ent.Product__c == criterion.Product__c &&
                                    (
                                        (
                                            criterion.Target_Manual_Addition_Only__c == false &&
                                            (
                                                criterion.Product_Criterion_Target_Rule_Action__c == null ||
                                                ent.CPQ_Playbook_Rule_Action__c == criterion.Product_Criterion_Target_Rule_Action__c
                                            )
                                        ) ||
                                        (
                                            criterion.Target_Manual_Addition_Only__c == true &&
                                            ent.CPQ_Playbook_Rule_Action__c == null
                                        )
                                    )
                                ) {
                                    // Comparison

                                    // Equality
                                    if (criterion.Comparison_Operator__c == 'Equals') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c == criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c == criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c == criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c == criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c == criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c == criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c == criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Equality Negation
                                    else if (criterion.Comparison_Operator__c == 'Does not equal') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c != criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c != criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c != criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c != criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c != criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c != criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c != criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Greater Than
                                    else if (criterion.Comparison_Operator__c == 'Greater than') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c > criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c > criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c > criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c > criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c > criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c > criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c > criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Greater than or equal
                                    else if (criterion.Comparison_Operator__c == 'Greater than or equal') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c >= criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c >= criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c >= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c >= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c >= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c >= criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c >= criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Less than
                                    else if (criterion.Comparison_Operator__c == 'Less than') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c < criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c < criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c < criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c < criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c < criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c < criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c < criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Less than or equal
                                    else if (criterion.Comparison_Operator__c == 'Less than or equal') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c <= criterion.Comparison_Value_Integer__c);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c <= criterion.Comparison_Value_Decimal__c); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c <= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c <= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c <= criterion.Comparison_Value_Currency__c);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c <= criterion.Comparison_Value_Date__c);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c <= criterion.Comparison_Value_Date__c);
                                        }
                                    }
                                    // Empty
                                    else if (criterion.Comparison_Operator__c == 'Is empty') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = (ent.Quantity__c == null);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = (ent.Discount__c == null); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = (ent.Unit_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = (ent.List_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = (ent.Total_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = (ent.Start_Date__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = (ent.End_Date__c == null);
                                        }
                                    }
                                    // Not empty
                                    else if (criterion.Comparison_Operator__c == 'Is not empty') {
                                        if (criterion.Product_Field__c == 'Quantity') {
                                            criterionEvaluation = !(ent.Quantity__c == null);    
                                        }
                                        else if (criterion.Product_Field__c == 'Discount') {
                                            criterionEvaluation = !(ent.Discount__c == null); 
                                        }
                                        else if (criterion.Product_Field__c == 'Unit Price') {
                                            criterionEvaluation = !(ent.Unit_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'List Price') {
                                            criterionEvaluation = !(ent.List_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Total Price') {
                                            criterionEvaluation = !(ent.Total_Price__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'Start Date') {
                                            criterionEvaluation = !(ent.Start_Date__c == null);
                                        }
                                        else if (criterion.Product_Field__c == 'End Date') {
                                            criterionEvaluation = !(ent.End_Date__c == null);
                                        }
                                    }
                                }
                            }
                        }
                    }


                    // Update needed Ns
                    if (criterionEvaluation == true) {
                        if (criterion.Evaluation_Logic__c == 'One of N required') {
                            Decimal currVal = criterionEvalN.get('exactN_passed');
                            criterionEvalN.put('exactN_passed', (currVal + 1));
                        }
                        else if (criterion.Evaluation_Logic__c == 'One of at least N required') {
                            Decimal currVal = criterionEvalN.get('atLeastN_passed');
                            criterionEvalN.put('atLeastN_passed', (currVal + 1));
                        }
                        else if (criterion.Evaluation_Logic__c == 'One of at most N required') {
                            Decimal currVal = criterionEvalN.get('atMostN_passed');
                            criterionEvalN.put('atMostN_passed', (currVal + 1));
                        }
                    } else {
                        // Criterion required, but did not pass
                        if (criterion.Evaluation_Logic__c == 'Required') {
                            criterionEvalN.put('requireds', 0);
                        }
                    }
                }

                // Check group evaluation status
                // At least 1 required criterion did not pass
                if (criterionEvalN.get('requireds') == 0) {
                    groupEvaluation = false;
                }
                // Mismatch of N required 
                else if (criterionEvalN.get('exactN_needed') != criterionEvalN.get('exactN_passed')) {
                    groupEvaluation = false;
                }
                // Mismatch of at least N required 
                else if (criterionEvalN.get('atLeastN_needed') > criterionEvalN.get('atLeastN_passed')) {
                    groupEvaluation = false;
                }
                // Mismatch of at most N required 
                else if (criterionEvalN.get('atMostN_needed') < criterionEvalN.get('atMostN_passed')) {
                    groupEvaluation = false;
                }

                // Update needed Ns
                if (groupEvaluation == true) {
                    if (criteriaGroup.Evaluation_Logic__c == 'One of N required') {
                        Decimal currVal = groupEvalN.get('exactN_passed');
                        groupEvalN.put('exactN_passed', (currVal + 1));
                    }
                    else if (criteriaGroup.Evaluation_Logic__c == 'One of at least N required') {
                        Decimal currVal = groupEvalN.get('atLeastN_passed');
                        groupEvalN.put('atLeastN_passed', (currVal + 1));
                    }
                    else if (criteriaGroup.Evaluation_Logic__c == 'One of at most N required') {
                        Decimal currVal = groupEvalN.get('atMostN_passed');
                        groupEvalN.put('atMostN_passed', (currVal + 1));
                    }
                } else {
                    // Criterion required, but did not pass
                    if (criteriaGroup.Evaluation_Logic__c == 'Required') {
                        groupEvalN.put('requireds', 0);
                    }
                }
            }

            // Check approval evaluation status
            // At least 1 required group did not pass
            if (groupEvalN.get('requireds') == 0) {
                sectionEvaluation = false;
            }
            // Mismatch of N required 
            else if (groupEvalN.get('exactN_needed') != groupEvalN.get('exactN_passed')) {
                sectionEvaluation = false;
            }
            // Mismatch of at least N required 
            else if (groupEvalN.get('atLeastN_needed') > groupEvalN.get('atLeastN_passed')) {
                sectionEvaluation = false;
            }
            // Mismatch of at most N required 
            else if (groupEvalN.get('atMostN_needed') < groupEvalN.get('atMostN_passed')) {
                sectionEvaluation = false;
            }

            // If section passed criteria, add it
            if (sectionEvaluation == true) {
                sectionsPassed += section.Id + ';';

                // Pipe text if applicable
                for (String questionVar : answerMap.keySet()) {

                    CPQ_Playbook_Answer__c answer = answerMap.get(questionVar);
                    if (answer != null) {
                        // Text 1
                        if (section.Body_Text_Block_1__c != null) {
                            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean') {
                                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Boolean__c));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency') {
                                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}','$'+String.valueOf(answer.Value_Currency__c != null ? answer.Value_Currency__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date') {
                                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Date__c != null ? answer.Value_Date__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal') {
                                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Decimal__c != null ? answer.Value_Decimal__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer') {
                                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Integer__c != null ? answer.Value_Integer__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Multi-Select Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area'
                            ) {
                                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}',answer.Value_Text__c != null ? answer.Value_Text__c : '');
                            } 
                        }
                        // Text 2
                        if (section.Body_Text_Block_2__c != null) {
                            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean') {
                                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Boolean__c));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency') {
                                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}','$'+String.valueOf(answer.Value_Currency__c != null ? answer.Value_Currency__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date') {
                                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Date__c != null ? answer.Value_Date__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal') {
                                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Decimal__c != null ? answer.Value_Decimal__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer') {
                                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Integer__c != null ? answer.Value_Integer__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Multi-Select Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area'
                            ) {
                                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}',answer.Value_Text__c != null ? answer.Value_Text__c : '');
                            } 
                        }
                        // Text 3
                        if (section.Body_Text_Block_3__c != null) {
                            if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean') {
                                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Boolean__c));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency') {
                                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}','$'+String.valueOf(answer.Value_Currency__c != null ? answer.Value_Currency__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date') {
                                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Date__c != null ? answer.Value_Date__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal') {
                                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Decimal__c != null ? answer.Value_Decimal__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer') {
                                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}',String.valueOf(answer.Value_Integer__c != null ? answer.Value_Integer__c.format() : ''));
                            }
                            else if (answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Multi-Select Picklist' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text' ||
                                answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area'
                            ) {
                                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}',answer.Value_Text__c != null ? answer.Value_Text__c : '');
                            } 
                        }
                    }
                }

                // EOL Text wrap resolution
                if (section.Body_Text_Block_1__c != null) {
                    section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
                }
                if (section.Body_Text_Block_2__c != null) {
                    section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
                }
                if (section.Body_Text_Block_3__c != null) {
                    section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
                }

                // Add section
                sectionObj sectionToAdd = new sectionObj();
                sectionToAdd.section = section;
                if (section.AttachedContentDocuments.size() > 0) {
                    sectionToAdd.imageID = section.AttachedContentDocuments[0].ContentDocument.LatestPublishedVersionId;
                }

                // Configure Product Table
                if (section.Section_Type__c == 'Product Table') {

                    // Get Headers from QLI fields
                    sectionToAdd.tableHeaders = new List<String>();
                    if (section.Product_Table_QLI_Fields__c != null) {
                        for (String field : section.Product_Table_QLI_Fields__c.split(';')) {
                            sectionToAdd.tableHeaders.add(
                                qliObject.fields
                                    .getMap()
                                    .get(field)
                                    .getDescribe()
                                    .getLabel()
                            );
                        }
                    }

                    // Get String values of QLI values
                    sectionToAdd.tableRecords = new List<List<String>>();
                    String tableQuery = qliQueryString;
                    if (section.Record_Table_Where_Clause__c != null) {
                        tableQuery += ' AND ' + section.Record_Table_Where_Clause__c;
                    }
                    if (section.Record_Table_Order_By_Clause__c != null) {
                        tableQuery += ' ORDER BY ' + section.Record_Table_Order_By_Clause__c;
                    }
                    for (QuoteLineItem qli : Database.query(tableQuery)) {
                        List<String> record = new List<String>();
                        for (String field : section.Product_Table_QLI_Fields__c.split(';')) {
                            Schema.DisplayType fieldType = qliObject.fields
                                .getMap()
                                .get(field)
                                .getDescribe()
                                .getType();
                            if (new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Date}.contains(
                                fieldType
                            )) {
                                String val;
                                
                                if (fieldType == Schema.DisplayType.Double) {
                                    Double decVal = (Double)qli.get(field);
                                    val = String.valueOf(decVal.format());
                                }
                                else if (fieldType == Schema.DisplayType.Currency) {
                                    Decimal decVal = (Decimal)qli.get(field);
                                    val = '$'+String.valueOf(decVal.format());
                                }
                                else if (fieldType == Schema.DisplayType.Integer) {
                                    Integer intVal = (Integer)qli.get(field);
                                    val = String.valueOf(intVal.format());
                                }
                                else if (fieldType == Schema.DisplayType.Date) {
                                    Date dateVal = (Date)qli.get(field);
                                    val = String.valueOf(dateVal.format());
                                }

                                record.add(val);
                            } else {
                                String val = String.valueOf(qli.get(field));
                                record.add(val);
                            }
                        }
                        sectionToAdd.tableRecords.add(record);
                    }
                }

                // Configure Entitlement Table
                if (section.Section_Type__c == 'Entitlement Table') {

                    // Get Headers from Entitlement fields
                    sectionToAdd.tableHeaders = new List<String>();
                    if (section.Entitlement_Table_Fields__c != null) {
                        for (String field : section.Entitlement_Table_Fields__c.split(';')) {
                            sectionToAdd.tableHeaders.add(
                                entObject.fields
                                    .getMap()
                                    .get(field)
                                    .getDescribe()
                                    .getLabel()
                            );
                        }
                    }

                    // Get String values of Entitlement values
                    sectionToAdd.tableRecords = new List<List<String>>();
                    String tableQuery = entQueryString;
                    if (section.Record_Table_Where_Clause__c != null) {
                        tableQuery += ' AND ' + section.Record_Table_Where_Clause__c;
                    }
                    if (section.Record_Table_Order_By_Clause__c != null) {
                        tableQuery += ' ORDER BY ' + section.Record_Table_Order_By_Clause__c;
                    }
                    for (Contract_Entitlement__c ent : Database.query(tableQuery)) {
                        List<String> record = new List<String>();
                        for (String field : section.Entitlement_Table_Fields__c.split(';')) {
                            Schema.DisplayType fieldType = entObject.fields
                                .getMap()
                                .get(field)
                                .getDescribe()
                                .getType();
                            if (new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Date}.contains(
                                fieldType
                            )) {
                                String val;
                                
                                if (fieldType == Schema.DisplayType.Double) {
                                    Double decVal = (Double)ent.get(field);
                                    val = String.valueOf(decVal.format());
                                }
                                else if (fieldType == Schema.DisplayType.Currency) {
                                    Decimal decVal = (Decimal)ent.get(field);
                                    val = '$'+String.valueOf(decVal.format());
                                }
                                else if (fieldType == Schema.DisplayType.Integer) {
                                    Integer intVal = (Integer)ent.get(field);
                                    val = String.valueOf(intVal.format());
                                }
                                else if (fieldType == Schema.DisplayType.Date) {
                                    Date dateVal = (Date)ent.get(field);
                                    val = String.valueOf(dateVal.format());
                                }

                                record.add(val);
                            } else {
                                String val = String.valueOf(ent.get(field));
                                record.add(val);
                            }
                        }
                        sectionToAdd.tableRecords.add(record);
                    }
                }

                // Configure Answer Table
                if (section.Section_Type__c.contains('Answer Table')) {
                    // Get Answer Pair Sets from Question Labels
                    sectionToAdd.answerTablePairSets = new List<List<AnswerPair>>();
                    List<AnswerPair> currAnswerPairSet = new List<AnswerPair>();
                    if (section.Answer_Table_Questions__c != null) {
                        for (String questionVar : section.Answer_Table_Questions__c.split(';')) {

                            // Associated Answer
                            CPQ_Playbook_Answer__c answer = answerMap.get(questionVar);
                            AnswerPair ansPair = new AnswerPair();
                            ansPair.label = '';
                            ansPair.value = '';

                            if (answer != null) {

                                // Label
                                ansPair.label = answer.CPQ_Playbook_Question__r.Proposal_Label__c;

                                // Value
                                if (
                                    answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Boolean' &&
                                    answer.Value_Boolean__c != null
                                ) {
                                    ansPair.value = String.valueOf(answer.Value_Boolean__c);
                                }
                                else if (
                                    answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Currency' &&
                                    answer.Value_Currency__c != null
                                ) {
                                    ansPair.value = String.valueOf(answer.Value_Currency__c.format());
                                }
                                else if (
                                    answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Date' &&
                                    answer.Value_Date__c != null    
                                ) {
                                    ansPair.value = String.valueOf(answer.Value_Date__c.format());
                                }
                                else if (
                                    answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Decimal' &&
                                    answer.Value_Decimal__c != null    
                                ) {
                                    ansPair.value = String.valueOf(answer.Value_Decimal__c.format());
                                }
                                else if (
                                    answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Integer' &&
                                    answer.Value_Integer__c != null
                                ) {
                                    ansPair.value = String.valueOf(answer.Value_Integer__c.format());
                                }
                                else if (
                                    (
                                        answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Picklist' ||
                                        answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Multi-Select Picklist' ||
                                        answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text' ||
                                        answer.CPQ_Playbook_Question__r.Answer_Type__c == 'Text Area'
                                    ) &&
                                    answer.Value_Text__c != null
                                ) {
                                    ansPair.value = answer.Value_Text__c;
                                }
                            }

                            currAnswerPairSet.add(ansPair);

                            if (section.Section_Type__c == 'Answer Table - 1 column' ||
                                (
                                    section.Section_Type__c == 'Answer Table - 2 columns' &&
                                    currAnswerPairSet.size() == 2
                                )
                            ) {
                                sectionToAdd.answerTablePairSets.add(currAnswerPairSet);
                                currAnswerPairSet = new List<AnswerPair>();
                            }
                        }
                    }

                    if (currAnswerPairSet.size() > 0) {
                        sectionToAdd.answerTablePairSets.add(currAnswerPairSet);
                    }
                }

                // Configure User Inputs
                if (section.Section_Type__c.contains('User Input')) {
                    if (section.Inputs_Column_1__c != null) {
                        sectionToAdd.inputs1 = section.Inputs_Column_1__c.split(';');
                    } else {
                        sectionToAdd.inputs1 = new List<String>();
                    }
                    if (section.Inputs_Column_2__c != null) {
                        sectionToAdd.inputs2 = section.Inputs_Column_2__c.split(';');
                    } else {
                        sectionToAdd.inputs2 = new List<String>();
                    }
                    if (section.Inputs_Column_3__c != null) {
                        sectionToAdd.inputs3 = section.Inputs_Column_3__c.split(';');
                    } else {
                        sectionToAdd.inputs3 = new List<String>();
                    }
                }

                sections.add(sectionToAdd);
            }
        }
    }

    public class sectionObj {
        public CPQ_Playbook_Proposal_Section__c section {get; set;}
        public String imageID {get; set;}
        public List<String> tableHeaders {get; set;}
        public List<List<String>> tableRecords {get; set;}
        public List<List<AnswerPair>> answerTablePairSets {get; set;}
        public List<String> inputs1 {get; set;}
        public List<String> inputs2 {get; set;}
        public List<String> inputs3 {get; set;}
    }

    public class AnswerPair {
        public String label {get; set;}
        public String value {get; set;}
    }

    /**
    * @description Compare Boolean answer to Boolean comparison value given the operator
    * @param answer Value of answer
    * @param comparisonValue Value of comparison
    * @param operator How values should be compared
    * @return Comparison result status
    */
    public static Boolean compareBoolean(Boolean answer, Boolean comparisonValue, String operator) {
        Boolean criterionEvaluation = false;
        
        if (operator == 'Equals') {
            criterionEvaluation = (answer == comparisonValue);
        }
        else if (operator == 'Does not equal') {
            criterionEvaluation = (answer != comparisonValue);
        }

        return criterionEvaluation;
    }

    /**
    * @description Compare Decimal answer to Decimal comparison value given the operator
    * @param answer Value of answer
    * @param comparisonValue Value of comparison
    * @param operator How values should be compared
    * @return Comparison result status
    */
    public static Boolean compareDecimal(Decimal answer, Decimal comparisonValue, String operator) {
        Boolean criterionEvaluation = false;
        
        if (operator == 'Equals') {
            criterionEvaluation = (answer == comparisonValue);
        }
        else if (operator == 'Does not equal') {
            criterionEvaluation = (answer != comparisonValue);
        }
        else if (operator == 'Greater than') {
            criterionEvaluation = (answer > comparisonValue);
        }
        else if (operator == 'Greater than or equal') {
            criterionEvaluation = (answer >= comparisonValue);
        }
        else if (operator == 'Less than') {
            criterionEvaluation = (answer < comparisonValue);
        }
        else if (operator == 'Less than or equal') {
            criterionEvaluation = (answer <= comparisonValue);
        }
        else if (operator == 'Is empty') {
            if (answer == null) {
                criterionEvaluation = true;
            } else {
                criterionEvaluation = false;
            }
        }
        else if (operator == 'Is not empty') {
            if (answer == null) {
                criterionEvaluation = false;
            } else {
                criterionEvaluation = true;
            }
        }

        return criterionEvaluation;
    }

    /**
    * @description Compare Date answer to Date comparison value given the operator
    * @param answer Value of answer
    * @param comparisonValue Value of comparison
    * @param operator How values should be compared
    * @return Comparison result status
    */
    public static Boolean compareDate(Date answer, Date comparisonValue, String operator) {
        Boolean criterionEvaluation = false;
        
        if (operator == 'Equals') {
            criterionEvaluation = (answer == comparisonValue);
        }
        else if (operator == 'Does not equal') {
            criterionEvaluation = (answer != comparisonValue);
        }
        else if (operator == 'Greater than') {
            criterionEvaluation = (answer > comparisonValue);
        }
        else if (operator == 'Greater than or equal') {
            criterionEvaluation = (answer >= comparisonValue);
        }
        else if (operator == 'Less than') {
            criterionEvaluation = (answer < comparisonValue);
        }
        else if (operator == 'Less than or equal') {
            criterionEvaluation = (answer <= comparisonValue);
        }
        else if (operator == 'Is empty') {
            if (answer == null) {
                criterionEvaluation = true;
            } else {
                criterionEvaluation = false;
            }
        }
        else if (operator == 'Is not empty') {
            if (answer == null) {
                criterionEvaluation = false;
            } else {
                criterionEvaluation = true;
            }
        }

        return criterionEvaluation;
    }

    /**
    * @description Compare Text answer to Text comparison value given the operator
    * @param answer Value of answer
    * @param comparisonValue Value of comparison
    * @param operator How values should be compared
    * @return Comparison result status
    */
    public static Boolean compareText(String answer, String comparisonValue, String operator) {
        Boolean criterionEvaluation = false;
        
        if (operator == 'Equals') {
            criterionEvaluation = (answer == comparisonValue);
        }
        else if (operator == 'Does not equal') {
            criterionEvaluation = (answer != comparisonValue);
        }
        else if (operator == 'Greater than') {
            criterionEvaluation = (answer > comparisonValue);
        }
        else if (operator == 'Greater than or equal') {
            criterionEvaluation = (answer >= comparisonValue);
        }
        else if (operator == 'Less than') {
            criterionEvaluation = (answer < comparisonValue);
        }
        else if (operator == 'Less than or equal') {
            criterionEvaluation = (answer <= comparisonValue);
        }
        else if (operator == 'Contains') {
            if (answer != null) {
                criterionEvaluation = (answer.contains(comparisonValue));
            } else {
                criterionEvaluation = false;
            }
        }
        else if (operator == 'Does not contain') {
            if (answer != null) {
                criterionEvaluation = (!answer.contains(comparisonValue));
            } else {
                criterionEvaluation = true;
            }
        }
        else if (operator == 'Is empty') {
            if (answer == null ||
                answer == ''
            ) {
                criterionEvaluation = true;
            } else {
                criterionEvaluation = false;
            }
        }
        else if (operator == 'Is not empty') {
            if (answer == null ||
                answer == ''
            ) {
                criterionEvaluation = false;
            } else {
                criterionEvaluation = true;
            }
        }

        return criterionEvaluation;
    }
}
