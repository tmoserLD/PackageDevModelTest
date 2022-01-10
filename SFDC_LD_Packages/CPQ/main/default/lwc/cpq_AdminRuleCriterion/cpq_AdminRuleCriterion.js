import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminRuleCriterion extends LightningElement {

    // Spinner
    @track loading = false;

    // Criterion
    @api criterion;

    // Object containing selections for all levels
    @api selected;

    // If criterion is currently selected
    get isSelected() {
        if (this.selected.ruleCriteriaGroupCriterion !== undefined) {
            return this.selected.ruleCriteriaGroupCriterion.includes(this.criterion.criterionInfo.Id);
        } else {
            return false;
        }
    }

    selectCriterion(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'rules',
                    rule: this.selected.rule,
                    ruleName: this.selected.ruleName,
                    ruleTab: 'criteriaGroups',
                    ruleCriteriaGroup: this.selected.ruleCriteriaGroup,
                    ruleCriteriaGroupName: this.selected.ruleCriteriaGroupName,
                    ruleCriteriaGroupTab: 'criteria',
                    ruleCriteriaGroupCriterion: this.selected.ruleCriteriaGroupCriterion === this.criterion.criterionInfo.Id ? undefined : this.criterion.criterionInfo.Id,
                    ruleCriteriaGroupCriterionName: this.selected.ruleCriteriaGroupCriterionName === this.criterion.criterionInfo.Name ? undefined : this.criterion.criterionInfo.Name
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
        if (this.selected.ruleCriteriaGroupCriterionName === undefined) {
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
                        ruleCriteriaGroup: this.selected.ruleCriteriaGroup,
                        ruleCriteriaGroupName: this.selected.ruleCriteriaGroupName,
                        ruleCriteriaGroupTab: 'criteria',
                        ruleCriteriaGroupCriterion: this.criterion.criterionInfo.Id,
                        ruleCriteriaGroupCriterionName: this.criterion.criterionInfo.Name
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