import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminRuleCriteriaGroup extends LightningElement {

    // Spinner
    @track loading = false;

    // Criteria group
    @api group;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.ruleCriteriaGroup !== undefined
        ) {
            return this.selected.ruleCriteriaGroup.includes(this.group.groupInfo.Id);
        } else {
            return false;
        }
    }

    selectGroup(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'rules',
                    rule: this.selected.rule,
                    ruleName: this.selected.ruleName,
                    ruleTab: 'criteriaGroups',
                    ruleCriteriaGroup: this.selected.ruleCriteriaGroup === this.group.groupInfo.Id ? undefined : this.group.groupInfo.Id,
                    ruleCriteriaGroupName: this.selected.ruleCriteriaGroupName === this.group.groupInfo.Name ? undefined : this.group.groupInfo.Name,
                    ruleCriteriaGroupTab: 'group'
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
        if (this.selected.ruleCriteriaGroupName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'rules',
                        rule: this.selected.rule,
                        ruleName: this.selected.ruleName,
                        ruleTab: 'criteriaGroups',
                        ruleCriteriaGroup: this.group.groupInfo.Id,
                        ruleCriteriaGroupName: this.group.groupInfo.Name,
                        ruleCriteriaGroupTab: this.selected.ruleCriteriaGroupTab
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