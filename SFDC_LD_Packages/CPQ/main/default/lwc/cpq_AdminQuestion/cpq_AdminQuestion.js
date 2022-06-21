import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminQuestion extends LightningElement {

    // Spinner
    @track loading = false;

    // Question
    @api question;

    // Object containing selections for all levels
    @api selected;

    // If question is currently selected
    get isSelected() {
        if (this.selected.question !== undefined
        ) {
            return this.selected.question.includes(this.question.questionInfo.Id);
        } else {
            return false;
        }
    }

    selectQuestion(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'questionGroups',
                    questionGroup: this.selected.questionGroup,
                    questionGroupName: this.selected.questionGroupName,
                    questionGroupTab: 'questions',
                    question: this.selected.question === this.question.questionInfo.Id ? undefined : this.question.questionInfo.Id,
                    questionName: this.selected.questionName === this.question.questionInfo.Name ? undefined : this.question.questionInfo.Name,
                    questionTab: 'question'
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
        if (this.selected.questionName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'questionGroups',
                        questionGroup: this.selected.questionGroup,
                        questionGroupName: this.selected.questionGroupName,
                        questionGroupTab: 'questions',
                        question: this.question.questionInfo.Id,
                        questionName: this.question.questionInfo.Name,
                        questionTab: this.selected.questionTab
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