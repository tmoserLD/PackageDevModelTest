import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminArchitectureManager extends LightningElement {

    @api type;
    @api
    get selected() {
        return this.selectedCopy;
    }
    set selected(value) {
        this.selectedCopy = value;
        this.currentChain = this.getCurrentChain();
    }
    @api selectedHistory;
    
    @track currentChain = [];
    @track selectedCopy;

    get undoAvailable() {
        if (this.selectedHistory !== undefined &&
            this.selectedHistory.length > 1    
        ) {
            return true;
        } else {
            return false;
        }
    }

    getCurrentChain() {
        let chain = [];
        if (this.type === 'Playbook') {
            if (this.selected !== undefined) {
                // Playbook
                if (this.selected.playbook !== undefined) {
                    chain.push({
                        base: true,
                        label: 'Playbooks',
                        obj: 'CPQ_Playbook__c',
                        recordId: this.selected.playbook,
                        recordName: this.selected.playbookName,
                        idAttribute: 'playbook',
                        tabValue: 'playbook'
                    });
                }
                // Question Group
                if (this.selected.questionGroup !== undefined) {
                    chain.push({
                        label: 'Question Groups',
                        obj: 'CPQ_Playbook_Question_Group__c',
                        recordId: this.selected.questionGroup,
                        recordName: this.selected.questionGroupName,
                        idAttribute: 'questionGroup',
                        parentTabAttribute: 'playbookTab',
                        parentTabValue: 'questionGroups',
                        tabValue: 'group'
                    });
                }
                // Question
                if (this.selected.question !== undefined) {
                    chain.push({
                        label: 'Questions',
                        obj: 'CPQ_Playbook_Question__c',
                        recordId: this.selected.question,
                        recordName: this.selected.questionName,
                        idAttribute: 'question',
                        parentTabAttribute: 'questionGroupTab',
                        parentTabValue: 'questions',
                        tabValue: 'question'
                    });
                }
                // Rule
                if (this.selected.rule !== undefined) {
                    chain.push({
                        label: 'Rules',
                        obj: 'CPQ_Playbook_Rule__c',
                        recordId: this.selected.rule,
                        recordName: this.selected.ruleName,
                        idAttribute: 'rule',
                        parentTabAttribute: 'playbookTab',
                        parentTabValue: 'rules',
                        tabValue: 'rule'
                    });
                }
                // Rule Criteria Group
                if (this.selected.ruleCriteriaGroup !== undefined) {
                    chain.push({
                        label: 'Criteria Groups',
                        obj: 'CPQ_Playbook_Rule_Criteria_Group__c',
                        recordId: this.selected.ruleCriteriaGroup,
                        recordName: this.selected.ruleCriteriaGroupName,
                        idAttribute: 'ruleCriteriaGroup',
                        parentTabAttribute: 'ruleTab',
                        parentTabValue: 'criteriaGroups',
                        tabValue: 'group'
                    });
                }
                // Rule Criterion
                if (this.selected.ruleCriteriaGroupCriterion !== undefined) {
                    chain.push({
                        label: 'Criteria',
                        obj: 'CPQ_Playbook_Rule_Criterion__c',
                        recordId: this.selected.ruleCriteriaGroupCriterion,
                        recordName: this.selected.ruleCriteriaGroupCriterionName,
                        idAttribute: 'ruleCriteriaGroupCriterion',
                        parentTabAttribute: 'ruleCriteriaGroupTab',
                        parentTabValue: 'criteria',
                        tabValue: 'criterion'
                    });
                }
                // Rule Action
                if (this.selected.ruleAction !== undefined) {
                    chain.push({
                        label: 'Actions',
                        obj: 'CPQ_Playbook_Rule_Action__c',
                        recordId: this.selected.ruleAction,
                        recordName: this.selected.ruleActionName,
                        idAttribute: 'ruleAction',
                        parentTabAttribute: 'ruleTab',
                        parentTabValue: 'actions',
                        tabValue: 'action'
                    });
                }
                // Rule Calculation Item
                if (this.selected.ruleActionCalculationItem !== undefined) {
                    chain.push({
                        label: 'Calculation Items',
                        obj: 'CPQ_Playbook_Rule_Calculation_Item__c',
                        recordId: this.selected.ruleActionCalculationItem,
                        recordName: this.selected.ruleActionCalculationItemName,
                        idAttribute: 'ruleActionCalculationItem',
                        parentTabAttribute: 'ruleActionTab',
                        parentTabValue: 'calculationItems',
                        tabValue: 'item'
                    });
                }
                // Approval
                if (this.selected.approval !== undefined) {
                    chain.push({
                        label: 'Approvals',
                        obj: 'CPQ_Playbook_Approval__c',
                        recordId: this.selected.approval,
                        recordName: this.selected.approvalName,
                        idAttribute: 'approval',
                        parentTabAttribute: 'playbookTab',
                        parentTabValue: 'approvals',
                        tabValue: 'approval'
                    });
                }
                // Approval Criteria Group
                if (this.selected.approvalCriteriaGroup !== undefined) {
                    chain.push({
                        label: 'Critieria Groups',
                        obj: 'CPQ_Playbook_Approval_Criteria_Group__c',
                        recordId: this.selected.approvalCriteriaGroup,
                        recordName: this.selected.approvalCriteriaGroupName,
                        idAttribute: 'approvalCriteriaGroup',
                        parentTabAttribute: 'approvalTab',
                        parentTabValue: 'criteriaGroups',
                        tabValue: 'group'
                    });
                }
                // Approval Criterion
                if (this.selected.approvalCriteriaGroupCriterion !== undefined) {
                    chain.push({
                        label: 'Criteria',
                        obj: 'CPQ_Playbook_Approval_Criterion__c',
                        recordId: this.selected.approvalCriteriaGroupCriterion,
                        recordName: this.selected.approvalCriteriaGroupCriterionName,
                        idAttribute: 'approvalCriteriaGroupCriterion',
                        parentTabAttribute: 'approvalCriteriaGroupTab',
                        parentTabValue: 'criteria',
                        tabValue: 'criterion'
                    });
                }
                // Approver Group
                if (this.selected.approvalApproverGroup !== undefined) {
                    chain.push({
                        label: 'Approver Groups',
                        obj: 'CPQ_Playbook_Approver_Group__c',
                        recordId: this.selected.approvalApproverGroup,
                        recordName: this.selected.approvalApproverGroupName,
                        idAttribute: 'approvalApproverGroup',
                        parentTabAttribute: 'approvalTab',
                        parentTabValue: 'approverGroups',
                        tabValue: 'group'
                    });
                }
                // Approver
                if (this.selected.approvalApproverGroupApprover !== undefined) {
                    chain.push({
                        label: 'Approvers',
                        obj: 'CPQ_Playbook_Approver__c',
                        recordId: this.selected.approvalApproverGroupApprover,
                        recordName: this.selected.approvalApproverGroupApproverName,
                        idAttribute: 'approvalApproverGroupApprover',
                        parentTabAttribute: 'approvalApproverGroupTab',
                        parentTabValue: 'approvers',
                        tabValue: 'approver'
                    });
                }
                // Proposal Section
                if (this.selected.proposalSection !== undefined) {
                    chain.push({
                        label: 'Proposal Sections',
                        obj: 'CPQ_Playbook_Proposal_Section__c',
                        recordId: this.selected.proposalSection,
                        recordName: this.selected.proposalSectionName,
                        idAttribute: 'proposalSection',
                        parentTabAttribute: 'playbookTab',
                        parentTabValue: 'proposalSections',
                        tabValue: 'section'
                    });
                }
                // Proposal Section Criteria Group
                if (this.selected.proposalSectionCriteriaGroup !== undefined) {
                    chain.push({
                        label: 'Criteria Groups',
                        obj: 'CPQ_Playbook_Proposal_Criteria_Group__c',
                        recordId: this.selected.proposalSectionCriteriaGroup,
                        recordName: this.selected.proposalSectionCriteriaGroupName,
                        idAttribute: 'proposalSectionCriteriaGroup',
                        parentTabAttribute: 'proposalSectionTab',
                        parentTabValue: 'criteriaGroups',
                        tabValue: 'group'
                    });
                }
                // Proposal Section Criterion
                if (this.selected.proposalSectionCriteriaGroupCriterion !== undefined) {
                    chain.push({
                        label: 'Criteria',
                        obj: 'CPQ_Playbook_Proposal_Criterion__c',
                        recordId: this.selected.proposalSectionCriteriaGroupCriterion,
                        recordName: this.selected.proposalSectionCriteriaGroupCriterionName,
                        idAttribute: 'proposalSectionCriteriaGroupCriterion',
                        parentTabAttribute: 'proposalSectionCriteriaGroupTab',
                        parentTabValue: 'criteria',
                        tabValue: 'criterion'
                    });
                }
            } else {
                chain.push({
                    base: true,
                    label: 'Playbooks',
                    obj: 'CPQ_Playbook__c',
                    noRecord: true,
                    idAttribute: 'playbook'
                });
            }
        }
        else if (this.type === 'Pricebook') {
            if (this.selected !== undefined) {
                // Pricebook
                if (this.selected.pricebook !== undefined) {
                    chain.push({
                        base: true,
                        label: 'Pricebooks',
                        obj: 'Pricebook2',
                        recordId: this.selected.pricebook,
                        recordName: this.selected.pricebookName,
                        idAttribute: 'pricebook',
                        tabValue: 'pricebook'
                    });
                }
                // Pricebook Entry
                if (this.selected.pricebookEntry !== undefined) {
                    chain.push({
                        label: 'Pricebook Entries',
                        obj: 'PricebookEntry',
                        recordId: this.selected.pricebookEntry,
                        recordName: this.selected.pricebookEntryName,
                        idAttribute: 'pricebookEntry',
                        parentTabAttribute: 'pricebookTab',
                        parentTabValue: 'entries',
                        tabValue: 'entry'
                    });
                }
                // Pricing Set
                if (this.selected.pricingSet !== undefined) {
                    chain.push({
                        label: 'Pricing Sets',
                        obj: 'CPQ_Pricing_Set__c',
                        recordId: this.selected.pricingSet,
                        recordName: this.selected.pricingSetName,
                        idAttribute: 'pricingSet',
                        parentTabAttribute: 'pricebookTab',
                        parentTabValue: 'sets',
                        tabValue: 'pricingSet'
                    });
                }
                // Pricing Threshold
                if (this.selected.pricingThreshold !== undefined) {
                    chain.push({
                        label: 'Pricing Thresholds',
                        obj: 'CPQ_Pricing_Threshold__c',
                        recordId: this.selected.pricingThreshold,
                        recordName: this.selected.pricingThresholdName,
                        idAttribute: 'pricingThreshold',
                        parentTabAttribute: 'pricingSetTab',
                        parentTabValue: 'thresholds',
                        tabValue: 'threshold'
                    });
                }
            } else {
                chain.push({
                    base: true,
                    label: 'Pricebooks',
                    obj: 'Pricebook2',
                    noRecord: true,
                    idAttribute: 'pricebook'
                });
            }
        }
        else if (this.type === 'Product') {
            if (this.selected !== undefined) {
                // Product
                if (this.selected.product !== undefined) {
                    chain.push({
                        base: true,
                        label: 'Products',
                        obj: 'Product2',
                        recordId: this.selected.product,
                        recordName: this.selected.productName,
                        idAttribute: 'product',
                        tabValue: 'product'
                    });
                }
            } else {
                chain.push({
                    base: true,
                    label: 'Products',
                    obj: 'Product2',
                    noRecord: true,
                    idAttribute: 'product'
                });
            }
        }

        return chain;
    }

    handleSelectObject(event) {

        let selected = this.selectedFromChain(event.target.getAttribute('data-obj'), event.target.getAttribute('data-record-id'));

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: selected
                }
            }
        );
        this.dispatchEvent(selectEvent);
    }

    selectedFromChain(objectName, recordId) {
        let selected = {};
        let objFound = false;
        this.currentChain.forEach(function(obj) {
            if (objFound !== true) {
                if (
                    (
                        recordId !== undefined &&
                        recordId !== null
                    ) ||
                    obj.obj !== objectName
                ) {
                    selected[obj.idAttribute] = obj.recordId;
                    selected[obj.idAttribute + 'Name'] = obj.recordName;
                    if (obj.obj === objectName) {
                        selected[obj.idAttribute + 'Tab'] = obj.tabValue;
                    }
                }
                if (obj.parentTabAttribute !== undefined) {
                    selected[obj.parentTabAttribute] = obj.parentTabValue;
                }
            }

            if (obj.obj === objectName) {
                objFound = true;
            }
        }, this);

        return selected;
    }

    refresh() {

        // Send refresh event to parent
        const refreshEvent = new CustomEvent(
            'refresh'
        );
        this.dispatchEvent(refreshEvent);
    }

    undo () {
     
        // Send undo event to parent
        const undoEvent = new CustomEvent(
            'undo'
        );
        this.dispatchEvent(undoEvent);   
    }
}