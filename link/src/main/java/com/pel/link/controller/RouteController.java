package com.pel.link.controller;

import com.google.api.client.http.*;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.gson.Gson;
import com.pel.link.model.StandardResponse;
import com.pel.link.service.RouteService;

import java.net.ConnectException;

import static spark.Spark.*;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 2:46 PM
 */
public class RouteController {

    Gson gson = new Gson();

    public RouteController() {
        getRequest();
        postRequest();
        deleteRequest();
    }

    private void getRequest() {
        get("/api/*", (req, res) -> {
            try {
                HttpRequestFactory requestFactory = new NetHttpTransport().createRequestFactory();
                HttpRequest request = requestFactory.buildGetRequest(new GenericUrl(RouteService.matchRoute(req.url())));
                HttpResponse response = request.execute();
                if (response.getStatusCode() == 200) {
                    res.status(200);
                    res.body(StandardResponse.success(response.parseAsString()));
                }
                else {
                    res.status(response.getStatusCode());
                    res.body(StandardResponse.error(response.parseAsString()));
                }
            } catch (HttpResponseException exception) {
                res.status(exception.getStatusCode());
                res.body(StandardResponse.error(exception.getContent()));
            } catch (ConnectException exception) {
                res.status(500);
                res.body(StandardResponse.error("{\"message\": \"Connection error! Is the service online?\"}"));
            }
            return res;
        });
    }

    private void postRequest() {
        post("/api/*", (req, res) -> {
            try {
                HttpRequestFactory requestFactory = new NetHttpTransport().createRequestFactory();
                HttpRequest request = requestFactory.buildPostRequest(
                    new GenericUrl(RouteService.matchRoute(req.url())),
                    ByteArrayContent.fromString("application/json", req.body())
                );
                HttpResponse response = request.execute();
                if (response.getStatusCode() == 200) {
                    res.status(200);
                    res.body(StandardResponse.success(response.parseAsString()));
                }
                else {
                    res.status(response.getStatusCode());
                    res.body(StandardResponse.error(response.parseAsString()));
                }
            } catch (HttpResponseException exception) {
                res.status(exception.getStatusCode());
                res.body(StandardResponse.error(exception.getContent()));
            } catch (ConnectException exception) {
                res.status(500);
                res.body(StandardResponse.error("{\"message\": \"Connection error! Is the service online?\"}"));
            }
            return res;
        });
    }

    private void deleteRequest() {
        delete("/api/*", (req, res) -> {
            try {
                HttpRequestFactory requestFactory = new NetHttpTransport().createRequestFactory();
                HttpRequest request = requestFactory.buildDeleteRequest(
                        new GenericUrl(RouteService.matchRoute(req.url())));
                HttpResponse response = request.execute();
                if (response.getStatusCode() == 200) {
                    res.status(200);
                    res.body(StandardResponse.success(response.parseAsString()));
                }
                else {
                    res.status(response.getStatusCode());
                    res.body(StandardResponse.error(response.parseAsString()));
                }
            } catch (HttpResponseException exception) {
                res.status(exception.getStatusCode());
                res.body(StandardResponse.error(exception.getContent()));
            } catch (ConnectException exception) {
                res.status(500);
                res.body(StandardResponse.error("{\"message\": \"Connection error! Is the service online?\"}"));
            }
            return res;
        });
    }

}
