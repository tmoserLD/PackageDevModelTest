import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminRuleAction extends LightningElement {

    // Spinner
    @track loading = false;

    // Action
    @api action;

    // Object containing selections for all levels
    @api selected;

    // If action is currently selected
    get isSelected() {
        if (this.selected.ruleAction !== undefined
        ) {
            return this.selected.ruleAction.includes(this.action.actionInfo.Id);
        } else {
            return false;
        }
    }

    get dynamicSource() {
        return this.action.actionInfo.Value_Source_Type__c === 'Dynamic';
    }

    selectAction(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'rules',
                    rule: this.selected.rule,
                    ruleName: this.selected.ruleName,
                    ruleTab: 'actions',
                    ruleAction: this.selected.ruleAction === this.action.actionInfo.Id ? undefined : this.action.actionInfo.Id,
                    ruleActionName: this.selected.ruleActionName === this.action.actionInfo.Name ? undefined : this.action.actionInfo.Name,
                    ruleActionTab: 'action'
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
        if (this.selected.ruleActionName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'rules',
                        rule: this.selected.rule,
                        ruleName: this.selected.ruleName,
                        ruleTab: 'actions',
                        ruleAction: this.action.actionInfo.Id,
                        ruleActionName: this.action.actionInfo.Name,
                        ruleActionTab: this.selected.ruleActionTab
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

}