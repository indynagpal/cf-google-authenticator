<cfscript>
testSuite = createObject("component","mxunit.framework.TestSuite").TestSuite();
testSuite.addAll("cf-google-authenticator.tests.TestBase32");
testSuite.addAll("cf-google-authenticator.tests.TestKey");
results = testSuite.run();
writeOutput(results.getResultsOutput('html'));
</cfscript>