import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminQuestions extends LightningElement {

    // All questions for group
    @api questions;

    // Object containing selections for all levels
    @api selected;

    // Create new question toggle
    @track createNew = false;

    // Spinner
    @track loading = false;

    // Search Term
    @track searchTerm;

    get collapsed() {
        return this.selected.questionGroupTab !== 'questions';
    }

    get filteredQuestions() {
        if (this.searchTerm !== '' &&
            this.searchTerm !== undefined &&
            this.searchTerm !== null
        ) {
            return this.questions.filter(question => question.questionInfo.Name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        } else {
            return this.questions;
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
                    playbookTab: 'questionGroups',
                    questionGroup: this.selected.questionGroup,
                    questionGroupName: this.selected.questionGroupName,
                    questionGroupTab: this.selected.questionGroupTab === 'questions' ? 'group' : 'questions'
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