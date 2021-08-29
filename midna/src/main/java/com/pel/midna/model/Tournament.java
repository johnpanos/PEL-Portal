package com.pel.midna.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 1:23 PM
 */
public class Tournament {

    public Integer id;
    public String name;
    public String desc;
    public String game;
    public String type;
    public String division;
    public Timestamp registrationStart;
    public Timestamp registrationEnd;
    public Timestamp seasonStart;
    public Timestamp seasonEnd;
    public Timestamp playoffStart;
    public Timestamp createdAt;
    public Timestamp updatedAt;

    public List<Map<String, Object>> teams = new ArrayList<>();
}
