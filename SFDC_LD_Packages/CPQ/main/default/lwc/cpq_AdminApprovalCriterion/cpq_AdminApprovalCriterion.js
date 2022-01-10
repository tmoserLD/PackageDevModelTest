import { LightningElement, api, track } from 'lwc';

export default class Cpq_AdminApprovalCriterion extends LightningElement {

    // Spinner
    @track loading = false;

    // Criterion
    @api criterion;

    // Object containing selections for all levels
    @api selected;

    // If criterion is currently selected
    get isSelected() {
        if (this.selected.approvalCriteriaGroupCriterion !== undefined) {
            return this.selected.approvalCriteriaGroupCriterion.includes(this.criterion.criterionInfo.Id);
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
                    playbookTab: 'approvals',
                    approval: this.selected.approval,
                    approvalName: this.selected.approvalName,
                    approvalTab: 'criteriaGroups',
                    approvalCriteriaGroup: this.selected.approvalCriteriaGroup,
                    approvalCriteriaGroupName: this.selected.approvalCriteriaGroupName,
                    approvalCriteriaGroupTab: 'criteria',
                    approvalCriteriaGroupCriterion: this.selected.approvalCriteriaGroupCriterion === this.criterion.criterionInfo.Id ? undefined : this.criterion.criterionInfo.Id,
                    approvalCriteriaGroupCriterionName: this.selected.approvalCriteriaGroupCriterionName === this.criterion.criterionInfo.Name ? undefined : this.criterion.criterionInfo.Name
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
        if (this.selected.approvalCriteriaGroupName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.selected.approval,
                        approvalName: this.selected.approvalName,
                        approvalTab: 'criteriaGroups',
                        approvalCriteriaGroup: this.selected.approvalCriteriaGroup,
                        approvalCriteriaGroupName: this.selected.approvalCriteriaGroupName,
                        approvalCriteriaGroupTab: 'criteria',
                        approvalCriteriaGroupCriterion: this.criterion.criterionInfo.Id,
                        approvalCriteriaGroupCriterionName: this.criterion.criterionInfo.Name
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