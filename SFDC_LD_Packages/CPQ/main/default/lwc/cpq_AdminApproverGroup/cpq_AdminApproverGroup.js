import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminApproverGroup extends LightningElement {

    // Spinner
    @track loading = false;

    // Approver Group
    @api group;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.approvalApproverGroup !== undefined
        ) {
            return this.selected.approvalApproverGroup.includes(this.group.groupInfo.Id);
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
                    approvalTab: 'approverGroups',
                    approvalApproverGroup: this.selected.approvalApproverGroup === this.group.groupInfo.Id ? undefined : this.group.groupInfo.Id,
                    approvalApproverGroupName: this.selected.approvalApproverGroupName === this.group.groupInfo.Name ? undefined : this.group.groupInfo.Name,
                    approvalApproverGroupTab: 'group'
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
        if (this.selected.approvalApproverGroupName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.selected.approval,
                        approvalName: this.selected.approvalName,
                        approvalTab: 'approverGroups',
                        approvalApproverGroup: this.group.groupInfo.Id,
                        approvalApproverGroupName: this.group.groupInfo.Name,
                        approvalApproverGroupTab: this.selected.approvalApproverGroupTab
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