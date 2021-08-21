package com.pel.zelda.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 1:23 PM
 */
public class Team {

    public Integer id;
    public String name;
    public String logoUrl;
    public String game;
    public String avgRank;
    public Timestamp createdAt;
    public Timestamp updatedAt;

    public List<Map<String, Object>> users = new ArrayList<>();
}
