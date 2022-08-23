public with sharing class cpq_ApprovalDisplayController {

    public CPQ_Quote_Approver__c approverRecord;
    public List<sectionObj> sections;

    public void setApproverRecord(CPQ_Quote_Approver__c record) {
        Id recordId = record.Id;
        approverRecord = [
            SELECT Id,
                Approval__c,
                CreatedBy.Name,
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.CPQ_Playbook_Approval__r.Reason__c,
                Quote__c,
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.OpportunityId,
                Opportunity__c,
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__r.Opportunity.AccountId,
                Account__c
            FROM CPQ_Quote_Approver__c
            WHERE Id=:recordId
        ];
    }

    public CPQ_Quote_Approver__c getApproverRecord() {
        return approverRecord;
    }

    public void setSections (List<sectionObj> s) {
        sections = s;
    }
        
    public List<sectionObj> getSections() {

        /****************
         * RECORD PREP
        ****************/

        Id approverId = approverRecord.Id;

        // Approver Info
        CPQ_Quote_Approver__c approverInfo = [
            SELECT Id,
                Approver__r.Id,
                Approver__r.Name,
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.CPQ_Playbook_Approval__c,
                CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c
            FROM CPQ_Quote_Approver__c
            WHERE Id=:approverId
        ];
        Id quoteId = approverInfo.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.Quote__c;
        Id approvalId = approverInfo.CPQ_Quote_Approval_Step__r.CPQ_Quote_Approval__r.CPQ_Playbook_Approval__c;

        // Quote Info
        String quoteQuery = ''
            + 'SELECT Id,'
                + 'Adjustment_of_Contract__c,'
                + 'Adjustment_Type__c,'
                + 'CPQ_Playbook__c,'
                + (System.UserInfo.isMultiCurrencyOrganization() == true ? 'CurrencyIsoCode,' : '')
                + 'End_Date__c,'
                + 'Start_Date__c,'
                + 'SubTotal_Price__c,'
                + 'Total_Price__c'
            + ' FROM Quote'
            + ' WHERE Id=:quoteId';
        Quote quoteInfo = Database.query(quoteQuery);

        // Currency Iso Code
        String currencyIsoCode;
        if (System.UserInfo.isMultiCurrencyOrganization() == true) {
            currencyIsoCode = (String) quoteInfo.get('CurrencyIsoCode');
        } else {
            currencyIsoCode = System.UserInfo.getDefaultCurrency();
        }

        // Currency Symbol
        String currencySymbol = currencyIsoCode;
        Map<String, String> currencySymbolsByIsoCode = new Map<String, String>{
            'AUD' => 'A$',
            'AWG' => 'ƒ',
            'BDT' => '৳',
            'CAD' => 'CAD$',
            'CNY' => '¥',
            'CRC' => '₡',
            'DKK' => 'kr',
            'EGP' => '£',
            'EUR' => '€',
            'FKP' => '£',
            'GBP' => '£',
            'GIP' => '£',
            'ILS' => '₪',
            'INR' => '₹',
            'ISK' => 'kr',
            'JPY' => '¥',
            'KHR' => '៛',
            'KRW' => '₩',
            'KZT' => '₸',
            'LBP' => '£',
            'NGN' => '₦',
            'NOK' => 'kr',
            'PHP' => '₱',
            'PYG' => '₲',
            'RUB' => '₽',
            'SDG' => '£',
            'SEK' => 'kr',
            'SHP' => '£',
            'SYP' => '£',
            'TRY' => '₺',
            'USD' => '$'
        };
        if (currencySymbolsByIsoCode.containsKey(currencyIsoCode)) {
            currencySymbol = currencySymbolsByIsoCode.get(currencyIsoCode);
        }

        // Sections that meet critieria
        List<sectionObj> tempSections = new List<sectionObj>();

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
            WHERE Quote__c=:quoteInfo.Id
        ]) {
            answerMap.put(answer.CPQ_Playbook_Question__r.Variable_Name__c, answer);
        }

        // All possible sections for playbook
        List<CPQ_Playbook_Approval_Email_Section__c> allSections = new List<CPQ_Playbook_Approval_Email_Section__c>();
        Set<Id> contentDocumentIDs = new Set<Id>();
        for (CPQ_Playbook_Approval_Email_Section__c section : [
            SELECT Id,
                Answer_Table_Questions__c,
                Body_Text_Block_1__c,
                Body_Text_Block_2__c,
                Body_Text_Block_3__c,
                CPQ_Playbook_Approval__c,
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
                        ContentDocument.Id
                    FROM AttachedContentDocuments
                )
            FROM CPQ_Playbook_Approval_Email_Section__c
            WHERE CPQ_Playbook_Approval__c=:approvalId AND
                IsActive__c = true
            ORDER BY Display_Order__c ASC
        ]) {
            allSections.add(section);

            if (section.AttachedContentDocuments.size() > 0) {
                contentDocumentIDs.add(section.AttachedContentDocuments[0].ContentDocument.Id);
            }
        }

        // Get ContentDistributions
        Map<Id, String> imageLinks = new Map<Id, String>();
        if (contentDocumentIDs.size() > 0) {

            // Map existing distribution links by file
            for (ContentDistribution dist : [
                SELECT Id,
                    ContentDocumentId,
                    ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentDocumentId IN:contentDocumentIDs
            ]) {
                imageLinks.put(dist.ContentDocumentId, dist.ContentDownloadUrl);
            }
        }


        /****************
         * SECTION PREP
        ****************/


        // Prepare each section
        for (CPQ_Playbook_Approval_Email_Section__c section : allSections) {

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
                            section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%'+questionVar+'%}',currencySymbol + String.valueOf(answer.Value_Currency__c != null ? answer.Value_Currency__c.format() : ''));
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
                            section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%'+questionVar+'%}',currencySymbol + String.valueOf(answer.Value_Currency__c != null ? answer.Value_Currency__c.format() : ''));
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
                            section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%'+questionVar+'%}',currencySymbol + String.valueOf(answer.Value_Currency__c != null ? answer.Value_Currency__c.format() : ''));
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

            // Remaining Question / EOL Text wrap / Empty Span resolution
            String remainingQuestionRegex = '\\{%[^%\\}]*%\\}';
            String emptySpanRegex = '<span[^>]*></span>';
            if (section.Body_Text_Block_1__c != null) {
                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('{%Approver.Name%}', approverInfo.Approver__r.Name);
                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replaceAll(remainingQuestionRegex, '');
                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
                section.Body_Text_Block_1__c = section.Body_Text_Block_1__c.replaceAll(emptySpanRegex, '');
            }
            if (section.Body_Text_Block_2__c != null) {
                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('{%Approver.Name%}', approverInfo.Approver__r.Name);
                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replaceAll(remainingQuestionRegex, '');
                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
                section.Body_Text_Block_2__c = section.Body_Text_Block_2__c.replaceAll(emptySpanRegex, '');
            }
            if (section.Body_Text_Block_3__c != null) {
                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('{%Approver.Name%}', approverInfo.Approver__r.Name);
                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replaceAll(remainingQuestionRegex, '');
                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replace('</p>', ' <span style="font-size:0.1px;color:white">|</span></p>');
                section.Body_Text_Block_3__c = section.Body_Text_Block_3__c.replaceAll(emptySpanRegex, '');
            }

            // Prep section object
            sectionObj sectionToAdd = new sectionObj();
            sectionToAdd.section = section;
            if (section.AttachedContentDocuments.size() > 0) {
                sectionToAdd.imageId = imageLinks.get(section.AttachedContentDocuments[0].ContentDocument.Id);
            }

            // Configure Record Table
            if (section.Section_Type__c == 'Record Table') {

                // Get Object Name and Fields from Query String
                String objName = section.Record_Table_Query__c.toLowerCase().split('from')[1].split(' ')[1];
                List<String> objFields = section.Record_Table_Query__c.toLowerCase().split(' from')[0].split('select ')[1].split(',');

                // Describe Object
                SObjectType objType = ((SObject)(Type.forName('Schema.' + objName).newInstance())).getSObjectType();
                DescribeSObjectResult obj = objType.getDescribe();

                // Get Headers from Records fields
                sectionToAdd.tableHeaders = new List<String>();
                for (String field : objFields) {
                    sectionToAdd.tableHeaders.add(
                        obj.fields
                            .getMap()
                            .get(field)
                            .getDescribe()
                            .getLabel()
                    );
                }

                // Get String values of record values
                sectionToAdd.tableRecords = new List<List<String>>();
                for (sObject rec : Database.query(section.Record_Table_Query__c)) {
                    List<String> record = new List<String>();
                    for (String field : objFields) {
                        Schema.DisplayType fieldType = obj.fields
                            .getMap()
                            .get(field)
                            .getDescribe()
                            .getType();
                        if (new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Date}.contains(
                            fieldType
                        )) {
                            String val = '';
                            
                            if (fieldType == Schema.DisplayType.Double) {
                                Double decVal = (Double)rec.get(field);
                                if (decVal != null) {
                                    val = String.valueOf(decVal.format());
                                }
                            }
                            else if (fieldType == Schema.DisplayType.Currency) {
                                Decimal decVal = (Decimal)rec.get(field);
                                if (decVal != null) {
                                    val = currencySymbol + String.valueOf(decVal.format());
                                }
                            }
                            else if (fieldType == Schema.DisplayType.Integer) {
                                Integer intVal = (Integer)rec.get(field);
                                if (intVal != null) {
                                    val = String.valueOf(intVal.format());
                                }
                            }
                            else if (fieldType == Schema.DisplayType.Date) {
                                Date dateVal = (Date)rec.get(field);
                                if (dateVal != null) {
                                    val = String.valueOf(dateVal.format());
                                }
                            }

                            record.add(val);
                        } else {
                            String val = String.valueOf(rec.get(field));
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

            tempSections.add(sectionToAdd);
            
        }

        return tempSections;
    } 

    public class sectionObj {
        public CPQ_Playbook_Approval_Email_Section__c section {get; set;}
        public String imageID {get; set;}
        public List<String> tableHeaders {get; set;}
        public List<List<String>> tableRecords {get; set;}
        public List<List<AnswerPair>> answerTablePairSets {get; set;}
    }

    public class AnswerPair {
        public String label {get; set;}
        public String value {get; set;}
    }
}
