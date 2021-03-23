package de.schoeneborn.payara.defect;

import javax.ejb.Stateless;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Stateless
@Path("/system-property")
public class SystemPropertyResource {


    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public Response getSystemProperties() {
        return Response.ok(System.getProperty("test.payara.property.first")).build();
    }

}
