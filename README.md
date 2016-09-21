# Introduction to Apex Testing - Dreamforce 2016

Presented by [Laura Meerkatz](https://github.com/lmeerkatz) and [Adam Lincoln](https://github.com/adamlincoln), developers at [Salesforce.org](http://developer.salesforce.org/#team)

This readme provides resources related to that session. This repository should also contain everything you need to deploy this code to a dev org.

## Testing Basics
### Test Class Structure

[Sample Test Class](/blob/master/src/classes/SampleTest.cls)

<pre><code>@isTest
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
    }
}</code></pre>

## What to Test
* Positive tests (things that should happen do happen)
* Negative tests (things that shouldn't happen don't happen)
* Exception tests (exceptions we're expecting are thrown as expected)

 



