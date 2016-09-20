@isTest
private class SampleTest {
    @TestSetup 
    static void setup(){
        // insert sample data that you want for all test methods here
    }
    
    // use comments to describe the scenario you're testing
    @isTest
    static void testSomething(){
        // set up test data for this scenario
        
        // execute the logic you're testing
        
        // query for the updated record(s)
        
        // assert expected results
        
        // System.assertEquals(expectedValue, actualValue, description);
        // System.assertNotEquals(expectedValue, actualValue, description);  
        // System.assert(booleanAssertion, description);
    }
}