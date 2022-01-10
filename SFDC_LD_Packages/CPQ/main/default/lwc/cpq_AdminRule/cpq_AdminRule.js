import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminRule extends LightningElement {

    // Spinner
    @track loading = false;

    // Rule
    @api rule;

    // Object containing selections for all levels
    @api selected;

    // If rule is currently selected
    get isSelected() {
        if (this.selected.rule !== undefined
        ) {
            return this.selected.rule.includes(this.rule.ruleInfo.Id);
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
        if (this.selected.ruleName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'rules',
                        rule: this.rule.ruleInfo.Id,
                        ruleName: this.rule.ruleInfo.Name,
                        ruleTab: this.selected.ruleTab
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