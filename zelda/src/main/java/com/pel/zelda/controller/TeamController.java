package com.pel.zelda.controller;

import com.google.gson.Gson;
import com.pel.zelda.model.Team;
import com.pel.zelda.service.TeamService;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import static spark.Spark.get;
import static spark.Spark.post;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 2:08 PM
 */
public class TeamController {

    Gson gson = new Gson();

    public TeamController() {
        getAllTeams();
        getTeam();
        createTeam();
//        updateUser();
    }

    private void getAllTeams() {
        get("/teams", (req, res) -> {
            res.body(gson.toJson(TeamService.getAllTeams()));
            return res;
        });
    }

    private void getTeam() {
        get("/teams/:id", (req, res) -> {
            Team team = TeamService.getTeam(Integer.parseInt(req.params(":id")));
            if (team.id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            res.body(gson.toJson(team));
            return res;
        });
    }

    private void createTeam() {
        post("/teams", (req, res) -> {
            Team team = gson.fromJson(req.body(), Team.class);
            System.out.println("PARSED TEAM: " + gson.toJson(team));
            if (team.id != null) {
                if (TeamService.getTeam(team.id).id == null) {
                    res.status(404);
                    res.body("{\"message\": \"Team id provided but no team with id exists\"}");
                    return res;
                }
                else {
                    team.updatedAt = Timestamp.valueOf(LocalDateTime.now());
                    TeamService.updateTeam(team);
                    team = TeamService.getTeam(team.id);
                    res.status(200);
                    res.body(gson.toJson(team));
                    return res;
                }
            }
            team.createdAt = Timestamp.valueOf(LocalDateTime.now());
            team.updatedAt = Timestamp.valueOf(LocalDateTime.now());
            team.id = TeamService.addTeam(team);
            res.status(200);
            res.body(gson.toJson(team));
            return res;
        });
    }

}
