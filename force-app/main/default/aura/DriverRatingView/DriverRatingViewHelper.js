({
	getDriversRating : function() {
		const action = component.get("c.getDriversRatingServerMethod");
        action.setCallback(this, function(serverResponse) {
            const state = serverResponse.getState();
            
            if (state === 'SUCCESS') {
                const drivers = serverResponse.getReturnValue();
                component.set("v.drivers", drivers);
                
                console.log("drivers SUCCESS");
            } else if (state === 'INCOMPLETE') {
                // do smthng
				console.log("INCOMPLETE error");
            } else if (state === 'ERROR') {
                const errors = serverResponse.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message" + 
                                    errors[0].message);
                    } else {
                        console.log("Unknown error");
                    }
                }
                    
            }
                
        });
        
        $A.enqueueAction(action);
	}
    
})