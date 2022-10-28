import { LightningElement, api } from 'lwc';
import getDriverWinRaceResults from '@salesforce/apex/FormulaOneDAO.getDriverWinRaceResults';
const columns = [
    { label: 'Race Result Name', fieldName: 'Name',  type: 'text'  },
    { label: 'Grand Prix Name', fieldName: 'Grand_Prix__r.Name',  type: 'text' },
];

export default class driverRacingResults extends LightningElement {
    @api recordId;
    data = [];
    columns = columns;

    isError = false;
    isLoaded = false;

    async connectedCallback() {
        try {
            const response = await getDriverWinRaceResults({driverId : this.recordId});    
            this.data = response;
        } catch (error) {
            this.isError = true;
            console.error(error);
        } finally {
            this.isLoaded = true;
        }
    }    

}