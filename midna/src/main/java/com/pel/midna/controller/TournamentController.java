package com.pel.midna.controller;

import com.google.gson.GsonBuilder;
import com.pel.midna.model.Tournament;
import com.pel.midna.service.TournamentService;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

import static spark.Spark.*;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 2:08 PM
 */
public class TournamentController {

    public TournamentController() {
        getAllTournaments();
        getTournament();
        createTournament();
        getTeamTournaments();
        addTournamentTeam();
        removeTournamentTeam();
        addTournamentCode();
        getTournamentCodes();
    }

    private void getAllTournaments() {
        get("/tournaments", (req, res) -> {
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(TournamentService.getAllTournaments()));
            return res;
        });
    }

    private void getTournament() {
        get("/tournaments/:id", (req, res) -> {
            Tournament tournament = TournamentService.getTournament(Integer.parseInt(req.params(":id")));
            if (tournament.id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested team could not be found\"}");
                return res;
            }
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(tournament));
            return res;
        });
    }

    private void createTournament() {
        post("/tournaments", (req, res) -> {
            Tournament tournament = new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().fromJson(req.body(), Tournament.class);
            System.out.println("PARSED TOURNAMENT: " + new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(tournament));
            if (tournament.id != null) {
                if (TournamentService.getTournament(tournament.id).id == null) {
                    res.status(404);
                    res.body("{\"message\": \"Tournament id provided but no tournament with id exists\"}");
                    return res;
                }
                else {
                    tournament.updatedAt = Timestamp.valueOf(LocalDateTime.now());
                    TournamentService.updateTournament(tournament);
                    tournament = TournamentService.getTournament(tournament.id);
                    res.status(200);
                    res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(tournament));
                    return res;
                }
            }
            tournament.createdAt = Timestamp.valueOf(LocalDateTime.now());
            tournament.updatedAt = Timestamp.valueOf(LocalDateTime.now());
            tournament.id = TournamentService.addTournament(tournament);
            res.status(200);
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(tournament));
            return res;
        });
    }

    private void getTeamTournaments() {
        get("/tournaments/teams/:tid", (req, res) -> {
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(TournamentService.getTeamTournaments(Integer.parseInt(req.params(":tid")))));
            return res;
        });
    }

    private void addTournamentTeam() {
        post("/tournaments/:uid/teams/:tid", (req, res) -> {
            if (TournamentService.getTournament(Integer.parseInt(req.params(":uid"))).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested tournament could not be found\"}");
                return res;
            }
            TournamentService.addTournamentTeam(Integer.parseInt(req.params(":uid")), Integer.parseInt(req.params(":tid")));
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(TournamentService.getTeamTournaments(Integer.parseInt(req.params(":tid")))));
            return res;
        });
    }

    private void removeTournamentTeam() {
        delete("/tournaments/:uid/teams/:tid", (req, res) -> {
            if (TournamentService.getTournament(Integer.parseInt(req.params(":uid"))).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested tournament could not be found\"}");
                return res;
            }
            TournamentService.removeTournamentTeam(Integer.parseInt(req.params(":uid")), Integer.parseInt(req.params(":tid")));
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(TournamentService.getTeamTournaments(Integer.parseInt(req.params(":tid")))));
            return res;
        });
    }

    private void addTournamentCode() {
        post("/tournaments/:uid/codes", (req, res) -> {
            if (TournamentService.getTournament(Integer.parseInt(req.params(":uid"))).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested tournament could not be found\"}");
                return res;
            }
            List<String> codes = new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().fromJson(req.body(), List.class);
            for (int i = 0; i < codes.size(); i++) {
                TournamentService.addtTournamentCode(Integer.parseInt(req.params(":uid")), codes.get(i));
            }
            res.body("{\"message\": \"Added codes successfully!\"}");
            return res;
        });
    }

    private void getTournamentCodes() {
        get("/tournaments/:uid/codes", (req, res) -> {
            if (TournamentService.getTournament(Integer.parseInt(req.params(":uid"))).id == null) {
                res.status(404);
                res.body("{\"message\": \"Requested tournament could not be found\"}");
                return res;
            }
            res.body(new GsonBuilder().setDateFormat("yyyy-MM-dd hh:mm:ss.S").create().toJson(TournamentService.getAllTournamentCodes(Integer.parseInt(req.params(":uid")))));
            return res;
        });
    }

}
