package com.pel.zelda.controller;

import com.google.gson.Gson;
import com.pel.zelda.model.User;
import com.pel.zelda.service.TeamService;
import com.pel.zelda.service.UserService;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import static spark.Spark.*;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 8:04 AM
 */
public class UserController {

    Gson gson = new Gson();

    public UserController() {
        getAllUsers();
        getUser();
        createUser();
//        updateUser();
        getAllUserTeams();
        addUserTeam();
        removeUserTeam();
        verifyUserTeam();
    }

    private void getAllUsers() {
        get("/users", (req, res) -> {
            res.body(gson.toJson(UserService.getAllUsers()));
            return res;
        });
    }

    private void getUser() {
        get("/users/:id", (req, res) -> {
            User user = UserService.getUser(req.params(":id"));
            if (user.id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested user could not be found\"}");
                return res;
            }
            res.body(gson.toJson(user));
            return res;
        });
    }

    private void createUser() {
        post("/users", (req, res) -> {
            User user = gson.fromJson(req.body(), User.class);
            user.createdAt = Timestamp.valueOf(LocalDateTime.now());
            user.updatedAt = Timestamp.valueOf(LocalDateTime.now());
            System.out.println("PARSED USER: " + gson.toJson(user));
            if (gson.toJson(user).contains("null")) {
                res.status(400);
                res.body("{\"message\": \"Request body missing or contains null values\"}");
                return res;
            }
            if (UserService.getUser(user.id).id != null) {
                res.status(409);
                res.body("{\"message\": \"User already exists with this id\"}");
                return res;
            }
            UserService.addUser(user);
            res.status(200);
            res.body(gson.toJson(user));
            return res;
        });
    }

//    private void updateUser() {
//        put("/api/users/:id", (req, res) -> {
//            User user = gson.fromJson(req.body(), User.class);
//            if (user.toString().contains("null")) {
//                res.status(400);
//                res.body(StandardResponse.error("Request body contains missing or null values", null));
//                return res;
//            }
//            if (UserService.getUser(req.params(":id")).toString().contains("null")) {
//                res.status(404);
//                res.body(StandardResponse.error("Requested user could not be found", null));
//                return res;
//            }
//            UserService.updateUser(user);
//            res.status(200);
//            res.body(StandardResponse.success("User was successfully updated!", null));
//            return res;
//        });
//    }

    private void getAllUserTeams() {
        get("/users/:id/teams", (req, res) -> {
            res.body(gson.toJson(UserService.getAllUserTeams(req.params(":id"))));
            return res;
        });
    }

    private void addUserTeam() {
        post("/users/:uid/teams/:tid", (req, res) -> {
            if (UserService.getUser(req.params(":uid")).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested user could not be found\"}");
                return res;
            }
            if (TeamService.getTeam(req.params(":tid")).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            UserService.addUserTeam(req.params(":uid"), Integer.parseInt(req.params(":tid")));
            res.body(gson.toJson(UserService.getAllUserTeams(req.params(":uid"))));
            return res;
        });
    }

    private void removeUserTeam() {
        delete("/users/:uid/teams/:tid", (req, res) -> {
            if (UserService.getUser(req.params(":uid")).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested user could not be found\"}");
                return res;
            }
            if (TeamService.getTeam(req.params(":tid")).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            UserService.removeUserTeam(req.params(":uid"), Integer.parseInt(req.params(":tid")));
            res.body(gson.toJson(UserService.getAllUserTeams(req.params(":uid"))));
            return res;
        });
    }

    private void verifyUserTeam() {
        post("/users/:uid/teams/:tid/verify", (req, res) -> {
            if (UserService.getUser(req.params(":uid")).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested user could not be found\"}");
                return res;
            }
            if (TeamService.getTeam(req.params(":tid")).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            UserService.verifyUserTeam(req.params(":uid"), Integer.parseInt(req.params(":tid")));
            res.body(gson.toJson(UserService.getAllUserTeams(req.params(":uid"))));
            return res;
        });
    }
}
