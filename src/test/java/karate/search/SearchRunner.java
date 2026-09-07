package karate.search;

import com.intuit.karate.junit5.Karate;

class SearchRunner {

    @Karate.Test
    Karate testDataDriven() {
        return Karate.run("data-driven").relativeTo(getClass());
    }

}
