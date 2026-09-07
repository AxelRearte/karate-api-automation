package karate.local;

import com.intuit.karate.junit5.Karate;

class LocalRunner {

    @Karate.Test
    Karate testLocal() {
        return Karate.run("products-local", "orders").relativeTo(getClass());
    }

}
