To reproduce the bug simply build the project with `mvn clean install`.

Second step is running `docker compose up` in the project root directory. The .war archive is already deployed.

After that you can visit http://localhost:7080/test/rest/system-property to see the bug.

If you switch the order system properties are created the problem does not appear anymore.

As far as I could see the problem is related to the order system properties are written in domain.xml. If the property with placeholder comes first in the 
system property list no replacement happens.

If I update system property over admin console the bug disappears,too.

Notice: You might need to set proxy configuration inside docker-compose.yml file if you are behind a proxy.