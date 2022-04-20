import { LightningElement, api, track } from 'lwc';

export default class CPQ_MostActiveContract extends LightningElement {

    // Account
    @api account;

    // Contract record
    @api contract;

    // Config objects
    @api oppForConfig;
    @api userForConfig;

    @track hideHeader = true;

    // Header text
    get header() {
        let header = '';
        if (this.contract.Contract_Status__c === 'Active') {
            header = 'Active'
        } else if (this.contract.Contract_Status__c === 'Upcoming') {
            header = 'Upcoming';
        } else {
            header = 'Past';
        }
        header += ' Contract Product Details';
        return header;
    }
}