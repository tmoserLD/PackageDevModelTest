import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminRuleCalculationItems extends LightningElement {

    // All calculation items for action
    @api items;

    // Object containing selections for all levels
    @api selected;

    // Create new toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.ruleActionTab !== 'calculationItems';
    }

    get filteredItems() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.items.filter(item => item.itemInfo.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.items;
        }
    }

    searchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    toggleCollapse() {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'rules',
                    rule: this.selected.rule,
                    ruleName: this.selected.ruleName,
                    ruleTab: this.selected.ruleTab,
                    ruleAction: this.selected.ruleAction,
                    ruleActionName: this.selected.ruleActionName,
                    ruleActionTab: this.selected.ruleActionTab === 'calculationItems' ? 'action' : 'calculationItems'
                }
            }
        });
    }

    // Create New event received
    createNewRecord(event) {
        this.createNew = true;
    }

    // Cancel Create New event received
    cancelCreateNewRecord(event) {
        this.createNew = false;
    }

    // Child saved event
    childSaved(event) {

        // Send childsaved event to parent
        const childSavedEvent = new CustomEvent(
            'childsaved', {
                detail: event.detail
            });
        this.dispatchEvent(childSavedEvent);
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