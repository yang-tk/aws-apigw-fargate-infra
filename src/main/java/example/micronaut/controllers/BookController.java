package example.micronaut.controllers;

import io.micronaut.http.MediaType;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;

@Controller("/book")
public class BookController {

    @Get(produces = MediaType.APPLICATION_JSON)
    public String index() {
        return "Hello World";
    }
}