({
  getDriversRating: function (component) {
    const action = component.get("c.getDriversRatingServerMethod");
    action.setCallback(this, function (serverResponse) {
      component.set("v.drivers", serverResponse.getReturnValue());
    });

    $A.enqueueAction(action);
  }
});
