import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminQuestion extends LightningElement {

    // Spinner
    @track loading = false;

    // Question
    @api question;

    // Object containing selections for all levels
    @api selected;

    // If question is currently selected
    get isSelected() {
        if (this.selected.question !== undefined
        ) {
            return this.selected.question.includes(this.question.questionInfo.Id);
        } else {
            return false;
        }
    }

    selectQuestion(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'questionGroups',
                    questionGroup: this.selected.questionGroup,
                    questionGroupName: this.selected.questionGroupName,
                    questionGroupTab: 'questions',
                    question: this.selected.question === this.question.questionInfo.Id ? undefined : this.question.questionInfo.Id,
                    questionName: this.selected.questionName === this.question.questionInfo.Name ? undefined : this.question.questionInfo.Name,
                    questionTab: 'question'
                }
            }
        });
    }

    // Child saved event
    childSaved(event) {

        // Send chilsaved event to parent
        const childsavedEvent = new CustomEvent(
            'childsaved', {
                detail: event.detail
            });
        this.dispatchEvent(childsavedEvent);
    }

    handleTabChange(event) {
        if (this.selected.questionName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'questionGroups',
                        questionGroup: this.selected.questionGroup,
                        questionGroupName: this.selected.questionGroupName,
                        questionGroupTab: 'questions',
                        question: this.question.questionInfo.Id,
                        questionName: this.question.questionInfo.Name,
                        questionTab: this.selected.questionTab
                    }
                }
            });
        }
    }

    // Select Event
    updateSelections(event) {

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: event.detail.selected
                }
            });
        this.dispatchEvent(selectEvent);
    }

    ruleCriterionSelected(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        playbookName: event.detail.item.CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name,
                        playbookTab: 'rules',
                        rule: event.detail.item.CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__c,
                        ruleName: event.detail.item.CPQ_Playbook_Rule_Criteria_Group__r.CPQ_Playbook_Rule__r.Name,
                        ruleTab: 'criteriaGroups',
                        ruleCriteriaGroup: event.detail.item.CPQ_Playbook_Rule_Criteria_Group__c,
                        ruleCriteriaGroupName: event.detail.item.CPQ_Playbook_Rule_Criteria_Group__r.Name,
                        ruleCriteriaGroupTab: 'criteria',
                        ruleCriteriaGroupCriterion: event.detail.item.Id,
                        ruleCriteriaGroupCriterionName: event.detail.item.Name,
                        ruleCriteriaGroupCriterionTab: 'criterion'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }

    approvalCriterionSelected(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.CPQ_Playbook__c,
                        playbookName: event.detail.item.CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.CPQ_Playbook__r.Name,
                        playbookTab: 'approvals',
                        approval: event.detail.item.CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__c,
                        approvalName: event.detail.item.CPQ_Playbook_Approval_Criteria_Group__r.CPQ_Playbook_Approval__r.Name,
                        approvalTab: 'criteriaGroups',
                        approvalCriteriaGroup: event.detail.item.CPQ_Playbook_Approval_Criteria_Group__c,
                        approvalCriteriaGroupName: event.detail.item.CPQ_Playbook_Approval_Criteria_Group__r.Name,
                        approvalCriteriaGroupTab: 'criteria',
                        approvalCriteriaGroupCriterion: event.detail.item.Id,
                        approvalCriteriaGroupCriterionName: event.detail.item.Name,
                        approvalCriteriaGroupCriterionTab: 'criterion'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }

    proposalCriterionSelected(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.CPQ_Playbook__c,
                        playbookName: event.detail.item.CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.CPQ_Playbook__r.Name,
                        playbookTab: 'proposalSections',
                        proposalSection: event.detail.item.CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__c,
                        proposalSectionName: event.detail.item.CPQ_Playbook_Proposal_Criteria_Group__r.CPQ_Playbook_Proposal_Section__r.Name,
                        proposalSectionTab: 'criteriaGroups',
                        proposalSectionCriteriaGroup: event.detail.item.CPQ_Playbook_Proposal_Criteria_Group__c,
                        proposalSectionCriteriaGroupName: event.detail.item.CPQ_Playbook_Proposal_Criteria_Group__r.Name,
                        proposalSectionCriteriaGroupTab: 'criteria',
                        proposalSectionCriteriaGroupCriterion: event.detail.item.Id,
                        proposalSectionCriteriaGroupCriterionName: event.detail.item.Name,
                        proposalSectionCriteriaGroupCriterionTab: 'criterion'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }

    actionSelected(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        playbookName: event.detail.item.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name,
                        playbookTab: 'rules',
                        rule: event.detail.item.CPQ_Playbook_Rule__c,
                        ruleName: event.detail.item.CPQ_Playbook_Rule__r.Name,
                        ruleTab: 'actions',
                        ruleAction: event.detail.item.Id,
                        ruleActionName: event.detail.item.Name,
                        ruleActionTab: 'action'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }

    calcItemSelected(event) {
        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: {
                        playbook: event.detail.item.CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.CPQ_Playbook__c,
                        playbookName: event.detail.item.CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.CPQ_Playbook__r.Name,
                        playbookTab: 'rules',
                        rule: event.detail.item.CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__c,
                        ruleName: event.detail.item.CPQ_Playbook_Rule_Action__r.CPQ_Playbook_Rule__r.Name,
                        ruleTab: 'actions',
                        ruleAction: event.detail.item.CPQ_Playbook_Rule_Action__c,
                        ruleActionName: event.detail.item.CPQ_Playbook_Rule_Action__r.Name,
                        ruleActionTab: 'calculationItems',
                        ruleActionCalculationItem: event.detail.item.Id,
                        ruleActionCalculationItemName: event.detail.item.Name,
                        ruleActionCalculationItemTab: 'item'
                    }
                }
            });
        this.dispatchEvent(selectEvent);
    }
}