public class DriverDTO {
  public String firstName;
  public String lastName;
  public Integer age;

  public DriverDTO(String firstName, String lastName, Integer age) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.age = age;
  }

  public static Boolean isDriverFieldsNotEmpty(DriverDTO incomeDriver) {
    Boolean result = true;
    if (String.isBlank(incomeDriver.firstName)) {
      System.debug('Driver First Name field is Empty');
      result = false;
    }
    if (String.isBlank(incomeDriver.lastName)) {
      System.debug('Driver Last Name field is Empty');
      result = false;
    }
    if (
      incomeDriver.age == null ||
      (incomeDriver.age != null &&
      String.isBlank(String.valueOf(incomeDriver.age)))
    ) {
      System.debug('Driver Age field is Empty');
      result = false;
    }
    return result;
  }
}
