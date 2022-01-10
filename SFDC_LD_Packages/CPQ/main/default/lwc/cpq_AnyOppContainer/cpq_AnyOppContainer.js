import { LightningElement, track } from 'lwc';

export default class CPQ_AnyOppContainer extends LightningElement {

    // Fields for SOSL search
    @track fields = ["Name"];

    // Fields for display
    @track displayFields = 'Name, StageName'

    // Id for Opp to show CPQ
    @track oppId

    get hasOppId() {
        return (this.oppId !== undefined && this.oppId !== null && this.oppId !== '');
    }

    handleLookup(event){
        this.oppId = event.detail;
    }

}