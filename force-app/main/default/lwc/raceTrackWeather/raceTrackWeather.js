import { LightningElement, api } from 'lwc';
import getRaceTrackWeather from '@salesforce/apex/FormulaOneDAO.getRaceTrackWeather';

export default class RaceTrackWeather extends LightningElement {
    @api recordId;
    weater = '';
    isError = false;

    async connectedCallback() {
        try {
            getRaceTrackWeather({
                raceId: this.recordId
            })
            .then(response => {
                const data = JSON.parse(response);
                if (response.data !== '') {
                    if(data.metric == 'fahrenheit') {
                        const celsius = Math.round(((data.temp - 32) * 5 / 9)*10)/10;
                        this.weater = '°C: ' + celsius;  
                    } else {
                        this.weater = '°c: ' + data.temp; 
                    }
                        
                    console.log('RaceTrackWeather: '+data.temp);
                } else {
                    this.weater = 'No data';
                    console.log("RaceTrackWeather: no data found");
                }
                
            })
        } catch (error) {
            this.isError = true;
            console.error(error);
        }
    }
}