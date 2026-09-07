package karate.db;

import com.intuit.karate.junit5.Karate;

class DbRunner {

    @Karate.Test
    Karate testDb() {
        return Karate.run("db-validation").relativeTo(getClass());
    }

}
