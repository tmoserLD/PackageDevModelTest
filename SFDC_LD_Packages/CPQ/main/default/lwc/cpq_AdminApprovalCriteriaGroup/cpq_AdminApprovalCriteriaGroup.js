import { LightningElement, api, track } from 'lwc';

export default class Cpq_AdminApprovalCriteriaGroup extends LightningElement {

    // Spinner
    @track loading = false;

    // Criteria group
    @api group;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.approvalCriteriaGroup !== undefined
        ) {
            return this.selected.approvalCriteriaGroup.includes(this.group.groupInfo.Id);
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
                    playbookTab: 'approvals',
                    approval: this.selected.approval,
                    approvalName: this.selected.approvalName,
                    approvalTab: 'criteriaGroups',
                    approvalCriteriaGroup: this.selected.approvalCriteriaGroup === this.group.groupInfo.Id ? undefined : this.group.groupInfo.Id,
                    approvalCriteriaGroupName: this.selected.approvalCriteriaGroupName === this.group.groupInfo.Name ? undefined : this.group.groupInfo.Name,
                    approvalCriteriaGroupTab: 'group'
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
                        approvalCriteriaGroup: this.group.groupInfo.Id,
                        approvalCriteriaGroupName: this.group.groupInfo.Name,
                        approvalCriteriaGroupTab: this.selected.approvalCriteriaGroupTab
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