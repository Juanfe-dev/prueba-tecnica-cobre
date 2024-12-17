package karate;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;
import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class GeneralRunner {

    private static final String PROJECT_NAME = "Acceptance test report";
    private static final String PATH_BUILD = "target";
    private static final String CLASSPATH_KARATE_ACCEPTANCE = "classpath:karate/features/acceptance";
    private static final String CLASSPATH_KARATE_E2E = "classpath:karate/features/e2e";
    private static final String WITH_TAGS = System.getProperty("withTags","~@ignore");
    private static final String[] FILES_JSON = new String[]{"json"};
    private static final boolean TRUE = true;
    private static final Integer ZERO = 0;
    private static final String TEST_SUITE = System.getProperty("test-suite");
    private static final String THREAD_INPUT_PROPERTY = System.getProperty("threads-count", "1");
    private static final Integer THREAD_NUMBER = Integer.parseInt(THREAD_INPUT_PROPERTY);

    @Test
    void testParallel() {
        Results results;
        if ("acceptance".equals(TEST_SUITE)) {
            results = Runner.path(CLASSPATH_KARATE_ACCEPTANCE)
                    .outputCucumberJson(TRUE)
                    .tags(WITH_TAGS)
                    .parallel(THREAD_NUMBER);
        } else {
            results = Runner.path(CLASSPATH_KARATE_E2E)
                    .outputCucumberJson(TRUE)
                    .tags(WITH_TAGS)
                    .parallel(THREAD_NUMBER);
        }
        generateReport(results.getReportDir());
        assertEquals(ZERO, results.getFailCount(), results.getErrorMessages());
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), FILES_JSON, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File(PATH_BUILD), PROJECT_NAME);
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }
}
