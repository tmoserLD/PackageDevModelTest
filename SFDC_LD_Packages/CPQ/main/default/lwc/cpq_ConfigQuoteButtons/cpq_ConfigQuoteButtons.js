import { LightningElement, api, track } from 'lwc';

// Save Method
import saveQuoteConfiguration from '@salesforce/apex/cpq_ConfigQuoteClass.saveQuoteConfiguration';

// Delete Records Method
import deleteRecords from '@salesforce/apex/cpq_ContainerClass.deleteRecords';

export default class CPQ_ConfigQuoteButtons extends LightningElement {

    @api configType;
    @api existingQuoteData;
    @api oppInfo;
    @api playbooks;
    @api quoteApprovals;
    @api quoteName;
    @api quoteProducts;
    @api selectedPlaybookId;
    @api selectedPricebook;
    @api isCPQAdmin;

    @track loading;
    @track quoteToPreview;
    @track showPreview;

    // Determine if System Settings include Proposal
    get allowProposal() {
        if (this.oppInfo.SystemSettings !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c !== undefined &&
            this.oppInfo.SystemSettings.Quote_Table_Actions__c.split(';').includes('Proposal')    
        ) {
            return true;
        } else {
            return false;
        }
    }

    // Determine if Cancel button can be clicked
    get disableCancelButton() {
        if (this.loading === true) {
            return true;
        } else {
            return false;
        }   
    }

    // Determine if Save button can be clicked
    get disableSaveButton() {
        if (this.loading === true) {
            return true;
        } else {
            return false;
        }
    }

    get disablePreviewButton() {
        let disabled = false;
        this.playbooks.forEach(function(playbook) {
            if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                playbook.questionGroups.forEach(function(group) {
                    group.questions.forEach(function(question) {
                        
                        // Question still needs attention
                        if (group.groupInfo.IsHidden__c !== true &&
                            question.questionInfo.IsHidden__c !== true &&
                            question.questionInfo.IsRequired__c &&
                            !question.questionInfo.IsReadOnly__c &&
                            (
                                question.questionInfo.answer === undefined ||
                                question.questionInfo.answer === null ||
                                question.questionInfo.answer === '' ||
                                (
                                    !question.questionInfo.touched &&
                                    !question.questionInfo.IsReadOnly__c
                                )
                            )
                        ) {
                            disabled = true;
                        }
                    }, this);
                }, this);
            }
        }, this);
        return disabled;
    }

    get viewMode() {
        return this.configType.includes('View');
    }

    get normalView() {
        return this.configType === 'View';
    }

    // Cancel clicked - return to main
    cancel() {
        const cancelEvent = new CustomEvent(
            'cancelevent', {
                detail: '' 
            });
        this.dispatchEvent(cancelEvent);
    }

    // Preview clicked - generate shell records
    async previewProposal() {
        this.generateQuote(true);
    }

    // Save clicked - generate true records
    async saveQuote() {
        this.generateQuote(false);
    }

    // Generate records
    async generateQuote(shellQuote) {

        // Set spinner
        this.loading = true;

        // Configure Quote
        let quote = {
            sobjectType: 'Quote',
            Id: shellQuote === true ? undefined : this.existingQuoteData.Id,
            Name: this.quoteName,
            OpportunityId: this.oppInfo.Id,
            CPQ_Playbook__c: this.selectedPlaybookId,
            Pricebook2Id: this.selectedPricebook.Id,
            Adjustment_of_Contract__c: this.existingQuoteData.Adjustment_of_Contract__c,
            Adjustment_Type__c: this.existingQuoteData.Adjustment_Type__c,
            Shell_Quote__c: shellQuote
        };

        // Configure QLIs
        let quoteLineItems = [];
        this.quoteProducts.filter(product => product.playbookId === this.selectedPlaybookId).forEach(function(product) {
            let qli = {}

            // QLI Stamp Fields
            product.qliFields.forEach(function(qliField) {
                qli[qliField] = product[qliField];
            }, this);

            // CPQ set Fields
            qli.sobjectType = 'QuoteLineItem';
            qli.CPQ_Playbook_Rule_Action__c = product.addedByAction;
            qli.End_Date__c = new Date(product.End_Date);
            qli.Discount__c = product.Discount;
            qli.Discount = 0;
            qli.List_Price__c = Number(product.List_Price);
            qli.PricebookEntryId = product.Id;
            qli.Product2Id = product.Product2Id;
            qli.Quantity = Math.min(product.Quantity, 9999999999.99);
            qli.Quantity__c = (product.Quantity);
            qli.Unit_Price__c = Number(product.Unit_Price);
            qli.Start_Date__c = new Date(product.Start_Date);
            qli.UnitPrice = product.Unit_Price;

            quoteLineItems.push(qli);
        }, this);

        // Configure Playbook Answers
        let playbookAnswers = [];
        let playbookComplete = true;
        this.playbooks.forEach(function(playbook) {
            if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                playbook.questionGroups.forEach(function(group) {
                    group.questions.forEach(function(question) {

                        let playbookAnswer = {
                            sobjectType: 'CPQ_Playbook_Answer__c',
                            CPQ_Playbook_Question__c: question.questionInfo.Id,
                            Name: question.questionInfo.Name
                        };

                        // Answer Value
                        if (question.questionInfo.Answer_Type__c === 'Boolean') {
                            playbookAnswer.Value_Boolean__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Currency') {
                            playbookAnswer.Value_Currency__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Date') {
                            playbookAnswer.Value_Date__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Decimal') {
                            playbookAnswer.Value_Decimal__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Integer') {
                            playbookAnswer.Value_Integer__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Picklist' ||
                            question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                            question.questionInfo.Answer_Type__c === 'Text' ||
                            question.questionInfo.Answer_Type__c === 'Text Area' ||
                            question.questionInfo.Answer_Type__c === 'Record Lookup'
                        ) {
                            playbookAnswer.Value_Text__c = question.questionInfo.answer;
                            playbookAnswer.Selected_Records_String__c = JSON.stringify(question.questionInfo.selectedRecords);
                        }

                        // Answer "Touched"
                        playbookAnswer.HasBeenTouched__c = question.questionInfo.touched;

                        playbookAnswers.push(playbookAnswer);
                        
                        // Question still needs attention
                        if (group.groupInfo.IsHidden__c !== true &&
                            question.questionInfo.IsHidden__c !== true &&
                            question.questionInfo.IsRequired__c &&
                            !question.questionInfo.IsReadOnly__c &&
                            (
                                question.questionInfo.answer === undefined ||
                                question.questionInfo.answer === null ||
                                question.questionInfo.answer === '' ||
                                (
                                    !question.questionInfo.touched &&
                                    !question.questionInfo.IsReadOnly__c
                                )
                            )
                        ) {
                            playbookComplete = false;
                        }

                        // Populate Quote Fields
                        if (question.questionInfo.Quote_Save_Field__c !== undefined) {
                            quote[question.questionInfo.Quote_Save_Field__c] = question.questionInfo.answer;
                        }
                    }, this);
                }, this);
            }
        }, this);

        if (playbookComplete === true) {
            quote.Playbook_Status__c = 'Complete';
        } else {
            quote.Playbook_Status__c = 'Incomplete';
        }

        // Configure Quote Approvals
        let quoteApprovals = [];
        let quoteApprovalSteps = [];
        let quoteApprovers = [];
        if (shellQuote !== true) {
            this.quoteApprovals.forEach(function(approval) {
                let quoteApproval = {
                    sobjectType: 'CPQ_Quote_Approval__c',
                    CPQ_Playbook_Approval__c: approval.approvalInfo.Id,
                    Name: approval.approvalInfo.Name,
                    Status__c: 'Pending'
                };
                quoteApprovals.push(quoteApproval);

                let approvalSteps = [];
                let stepApprovers = [];
                approval.approverGroups.forEach(function(group) {
                    let approvalStep = {
                        sobjectType: 'CPQ_Quote_Approval_Step__c',
                        CPQ_Playbook_Approver_Group__c: group.groupInfo.Id,
                        Name: group.groupInfo.Name,
                        Status__c: 'Pending'
                    };
                    approvalSteps.push(approvalStep);

                    let approvers = [];
                    group.approvers.forEach(function(approver) {
                        let quoteApprover = {
                            sobjectType: 'CPQ_Quote_Approver__c',
                            CPQ_Playbook_Approver__c: approver.approverInfo.Id,
                            Status__c: 'Pending'
                        };

                        if (approver.approverInfo.Manager_Approver__c === true) {
                            if (this.oppInfo.Owner) {
                                if (this.oppInfo.Owner.ManagerId) {
                                    quoteApprover.Approver__c = this.oppInfo.Owner.ManagerId;
                                    quoteApprover.Name = this.oppInfo.Owner.Manager.Name;
                                    approvers.push(quoteApprover);
                                }
                            }
                        } else {
                            quoteApprover.Approver__c = approver.approverInfo.Approver__c;
                            quoteApprover.Name = approver.approverInfo.Approver__r.Name;
                            approvers.push(quoteApprover);
                        }
                    }, this);
                    stepApprovers.push(approvers);
                }, this);
                quoteApprovalSteps.push(approvalSteps);
                quoteApprovers.push(stepApprovers);
            }, this);
        }

        // Send object to database
        try {
            let quoteId = await saveQuoteConfiguration({
                quoteToSave: quote,
                quoteLineItems: quoteLineItems,
                playbookAnswers: playbookAnswers,
                quoteApprovals: quoteApprovals,
                quoteApprovalSteps: quoteApprovalSteps,
                quoteApprovers: quoteApprovers
            });

            if (shellQuote !== true) {

                // Send save event to parent
                const saveEvent = new CustomEvent(
                    'saveevent', {
                        detail: {
                            toast: {
                                title: 'Success!',
                                message: 'Quote was saved',
                                variant: 'success'
                            }
                        }
                    });
                this.dispatchEvent(saveEvent);
            } else {

                // Show preview
                this.quoteToPreview = {
                    Id: quoteId,
                    CPQ_Quote_Approvals__r: [{Status__c: 'Pending'}],
                    Name: 'Preview: ' + this.quoteName
                }
                this.showPreview = true;
            }
        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to save the quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Preview window closed
    async closedPreview() {

        this.loading = true;

        // Hide Preview Modal
        this.showPreview = false;

        // Delete Shell Quote
        try {
            await deleteRecords({
                records: [
                    {
                        sobjectType: 'Quote',
                        Id: this.quoteToPreview.Id
                    }
                ]
            });
        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the preview quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Toggle Admin View
    toggleAdminView() {
        const configTypeUpdateEvent = new CustomEvent(
            'configtypeupdate', {
                detail: this.configType === 'View' ? 'Admin View' : 'View'
            });
        this.dispatchEvent(configTypeUpdateEvent);
    }
}