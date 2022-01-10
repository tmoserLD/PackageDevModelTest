import { LightningElement, api, track } from 'lwc';
export default class CPQ_AdminQuestionGroup extends LightningElement {

    // Spinner
    @track loading = false;

    // Question group
    @api group;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.questionGroup !== undefined
        ) {
            return this.selected.questionGroup.includes(this.group.groupInfo.Id);
        } else {
            return false;
        }
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
        if (this.selected.questionGroupName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'questionGroups',
                        questionGroup: this.group.groupInfo.Id,
                        questionGroupName: this.group.groupInfo.Name,
                        questionGroupTab: this.selected.questionGroupTab
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
}