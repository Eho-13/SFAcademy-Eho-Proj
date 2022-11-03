import { LightningElement, api } from "lwc";
import getDriverWinRaceResults from "@salesforce/apex/FormulaOneDAO.getDriverWinRaceResults";
const columns = [
  { label: "Race Result Name", fieldName: "Name", type: "text" },
  { label: "Position", fieldName: "Position__c" },
  { label: "Grand Prix Name", fieldName: "Grand_Prix__r.Name", type: "text" }
];

export default class driverRacingResults extends LightningElement {
  @api recordId; //Unexpected '@'. (E024)
  data = []; //Class properties must be methods. Expected '(' but instead saw '='. (E054)
  columns = columns;
  isError = false;
  isLoaded = false;

  async connectedCallback() {
    try {
      const response = await getDriverWinRaceResults({
        driverId: this.recordId
      }); //Missing semicolon. (E058)
      this.data = response;
    } catch (error) {
      this.isError = true;
      console.error(error);
    } finally {
      this.isLoaded = true;
    }
  }
}
