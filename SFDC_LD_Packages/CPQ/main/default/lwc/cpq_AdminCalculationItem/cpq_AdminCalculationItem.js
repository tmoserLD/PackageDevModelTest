import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminCalculationItem extends LightningElement {

    // Spinner
    @track loading = false;

    // Item
    @api item;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.ruleActionCalculationItem !== undefined
        ) {
            return this.selected.ruleActionCalculationItem.includes(this.item.itemInfo.Id);
        } else {
            return false;
        }
    }

    selectItem(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'rules',
                    rule: this.selected.rule,
                    ruleName: this.selected.ruleName,
                    ruleTab: 'actions',
                    ruleAction: this.selected.ruleAction,
                    ruleActionName: this.selected.ruleActionName,
                    ruleActionTab: 'calculationItems',
                    ruleActionCalculationItem: this.selected.ruleActionCalculationItem === this.item.itemInfo.Id ? undefined : this.item.itemInfo.Id,
                    ruleActionCalculationItemName: this.selected.ruleActionCalculationItemName === this.item.itemInfo.Name ? undefined : this.item.itemInfo.Name,
                    ruleActionCalculationItemTab: 'item'
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
        if (this.selected.ruleActionCalculationItemName === undefined) {
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
                        ruleAction: this.selected.ruleAction,
                        ruleActionName: this.selected.ruleActionName,
                        ruleActionTab: this.selected.ruleActionTab,
                        ruleActionCalculationItem: this.item.itemInfo.Id,
                        ruleActionCalculationItemName: this.item.itemInfo.Name,
                        ruleActionCalculationItemTab: this.selected.ruleActionCalculationItemTab
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