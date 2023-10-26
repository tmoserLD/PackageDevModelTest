global class Slack_CPQApprovals_Provider {

    global static ApprovalInfo getApprovalMessageDetails(Id approvalId) {

        ApprovalInfo approvalInfo = new ApprovalInfo();

        return approvalInfo;
    }

    global class ApprovalInfo {
        global String approvalsText = '*Approvals*\n>   - Term Length less than 1 day\n>   - ARR Discount > 40%';
        global String approvalNotes = '*AE Notes (<https://launchdarkly.lightning.force.com/lightning/r/User/0051K00000A0k2ZQAR/view | Tristan Moser>)*\n>I am very excited about this deal. Please consider approving as quickly as possible so that I can make money. Thanks!\n\n*Deal Management Notes*\n>Tristan deserves a raise for this deal! Amazing\n\n*Additional Notes*\n>This could be a game changer for us. Please don\'t mess this up...';
        global String headerText = ':wave: The following approval(s) have been submitted for your approval';
        global String opportunityLinkText = '*Opportunity:*\n<https://launchdarkly.lightning.force.com/lightning/r/Opportunity/0061K00000kKsYzQAK/view | IT TEST - Expansion - Sales - 2022>';
        global String quoteLinkText = '*Quote:*\n<https://launchdarkly.lightning.force.com/lightning/r/SBQQ__Quote__c/aAQ6T000001DZXQWA4/view | Q-34287>';
    }

    global static List<OpportunityLineItem> getQuoteLines(Id approvalId) {

        // List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<OpportunityLineItem> quoteLines = new List<OpportunityLineItem>();

        insert quoteLines;

        quoteLines = [
            SELECT Id,
                Name,
                ProductCode,
                Quantity,
                TotalPrice
            FROM OpportunityLineItem
            ORDER BY ProductCode
        ];

        return quoteLines;
    }
}