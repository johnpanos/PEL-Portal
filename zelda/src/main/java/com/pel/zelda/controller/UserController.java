package com.pel.zelda.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
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
        getAllUserTeams();
        addUserTeam();
        removeUserTeam();
    }

    private void getAllUsers() {
        get("/users", (req, res) -> {
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(UserService.getAllUsers()));
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
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(user));
            return res;
        });
    }

    private void createUser() {
        post("/users", (req, res) -> {
            User user = gson.fromJson(req.body(), User.class);
            System.out.println("PARSED USER: " + new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(user));
            if (user.id == null && user.connections.userId == null && user.verification.userId == null) {
                res.status(400);
                res.body("{\"message\": \"User object missing id\"}");
                return res;
            }
            // weird ternary cuz system for determine which inner object to update is scuffed
            String userId = user.id != null ? user.id : user.connections.userId != null ? user.connections.userId : user.verification.userId;
            if (UserService.getUser(userId).id != null) {
                user.updatedAt = Timestamp.valueOf(LocalDateTime.now());
                UserService.updateUser(user);
                user = UserService.getUser(userId);
                res.status(200);
                res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(user));
                return res;
            }
            user.createdAt = Timestamp.valueOf(LocalDateTime.now());
            user.updatedAt = Timestamp.valueOf(LocalDateTime.now());
            UserService.addUser(user);
            res.status(200);
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(user));
            return res;
        });
    }

    private void getAllUserTeams() {
        get("/users/:id/teams", (req, res) -> {
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(UserService.getAllUserTeams(req.params(":id"))));
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
            if (TeamService.getTeam(Integer.parseInt(req.params(":tid"))).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            UserService.addUserTeam(req.params(":uid"), Integer.parseInt(req.params(":tid")));
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(UserService.getAllUserTeams(req.params(":uid"))));
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
            if (TeamService.getTeam(Integer.parseInt(req.params(":tid"))).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            UserService.removeUserTeam(req.params(":uid"), Integer.parseInt(req.params(":tid")));
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(UserService.getAllUserTeams(req.params(":uid"))));
            return res;
        });
    }

}
