import { LightningElement, api, track } from 'lwc';

export default class Cpq_AdminProposalCriteriaGroup extends LightningElement {

    // Spinner
    @track loading = false;

    // Criteria group
    @api group;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.proposalSectionCriteriaGroup !== undefined
        ) {
            return this.selected.proposalSectionCriteriaGroup.includes(this.group.groupInfo.Id);
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
                    playbookTab: 'proposalSections',
                    proposalSection: this.selected.proposalSection,
                    proposalSectionName: this.selected.proposalSectionName,
                    proposalSectionTab: 'criteriaGroups',
                    proposalSectionCriteriaGroup: this.selected.proposalSectionCriteriaGroup === this.group.groupInfo.Id ? undefined : this.group.groupInfo.Id,
                    proposalSectionCriteriaGroupName: this.selected.proposalSectionCriteriaGroupName === this.group.groupInfo.Name ? undefined : this.group.groupInfo.Name,
                    proposalSectionCriteriaGroupTab: 'group'
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
        if (this.selected.proposalSectionCriteriaGroupName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'proposalSections',
                        proposalSection: this.selected.proposalSection,
                        proposalSectionName: this.selected.proposalSectionName,
                        proposalSectionTab: 'criteriaGroups',
                        proposalSectionCriteriaGroup: this.group.groupInfo.Id,
                        proposalSectionCriteriaGroupName: this.group.groupInfo.Name,
                        proposalSectionCriteriaGroupTab: this.selected.proposalSectionCriteriaGroupTab
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